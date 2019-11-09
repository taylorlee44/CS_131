import asyncio
import aiohttp
import time
import sys
import logging
import json

logging.basicConfig(filename = sys.argv[1] + "_log.txt", filemode = 'w', format='%(asctime)s - %(levelname)s: %(message)s', datefmt='%d-%b-%y %H:%M:%S', level=20)

port_dictionary = {'Goloman':12138, 'Hands': 12139, 'Holiday': 12140, 'Wilkes': 12141, 'Welsh': 12142}

communications = { 'Goloman': ['Hands', 'Holiday', 'Wilkes'], 
				   'Hands': ['Goloman', 'Wilkes'], 
				   'Holiday': ['Goloman', 'Wilkes', 'Welsh'],
				   'Welsh': ['Holiday'], 
				   'Wilkes': ['Goloman', 'Hands', 'Holiday']
				 }

locations = {}
mykey = 'AIzaSyBnmQNmA61BJG0L_okQYvsgMM4MLuJ7HjM'
#kiwi.cs.ucla.edu: ['Goloman', '+0.263873386', '+34.068930-118.445127', 1520023934.918963997, kiwi.cs.ucla.edu]

#parse the given input line into a list of arguments
async def parse_input(givenInput):
	inputSplit = givenInput.strip().split()
	inputCorrect = True
	#If leading argument is IAMAT, WHATSAT, or UPDATELOC
	if inputSplit[0] == 'IAMAT' or inputSplit[0] == 'WHATSAT':
		if len(inputSplit) != 4: #Wrong number of arguments
			inputCorrect = False	

		if inputSplit[0] == 'WHATSAT':
			try:
				inputSplit[2] = int(inputSplit[2])
				inputSplit[3] = int(inputSplit[3])
			except:
				logging.error("WHATSAT 2nd and 3rd arguments must be ints")
				inputCorrect = False
				return [givenInput]

			if  inputSplit[2] < 51 and inputSplit[3] < 21 and inputSplit[1] in locations:
				pass
			else:
				logging.error("WHATSAT 2nd and 3rd arguments must be less than 51 and 21 respectively.")
				inputCorrect = False
	elif inputSplit[0] == 'UPDATELOC': 
		pass
	#If leading argument is Neither: 
	else: 
		inputCorrect = False

	if inputCorrect == True:
		return inputSplit
	else:
		return[givenInput]

async def update_others(updateList, outputServer):
	#updateList: ['Goloman', +0.263873386', '+34.068930-118.445127', '1520023934.918963997', kiwi.cs.ucla.edu ]
	try: 
		reader, writer = await asyncio.open_connection('127.0.0.1', port_dictionary[outputServer])
		logging.info(f'Sending {updateList[4]} location at {updateList[2]} to {outputServer}.')
		stringReturn = f"UPDATELOC {updateList[0]} {updateList[1]} {updateList[2]} {updateList[3]} {updateList[4]}"
		#UPDATELOC Goloman +0.263873386 +34.068930-118.445127 1520023934.918963997 kiwi.cs.ucla.edu
		writer.write(stringReturn.encode())
		await writer.drain()
		writer.close()
	except: 
		logging.info(f"Port {outputServer} is down. Cannot send {updateList[4]} at {updateList[2]} to {outputServer}.")
    		#port is down. 

async def process_IAMAT(givenList):
	logging.info(f'Received IAMAT request from {givenList[1]} at {givenList[2]}')
	#calculate time difference
	current_time = time.time()
	time_difference = float(current_time) - float(givenList[3])  
	time_difference_string = ''
	if time_difference > 0:
		time_difference_string = "+"+str(time_difference)
	else: 
		time_difference_string = "-"+str(time_difference)

	#givenList: IAMAT kiwi.cs.ucla.edu +34.068930-118.445127 1520023934.918963997
	#locations: kiwi.cs.ucla.edu: ['Goloman', +0.263873386', '+34.068930-118.445127', '1520023934.918963997', kiwi.cs.ucla.edu]
	#Add location to dictionary. 
	locations[givenList[1]]= [sys.argv[1], time_difference_string, givenList[2], givenList[3], givenList[1]]

	#Update location to other servers concurrently
	taskList = []
	for i in communications[sys.argv[1]]:
		logging.info(f"Created Task for {i}.")
		taskList.append(asyncio.create_task(update_others(locations[givenList[1]], i)))
	for j in taskList:
		logging.info(f"Running Task.")
		await j

	logging.info(f"IAMAT RESPONSE:\nAT {sys.argv[1]} {time_difference_string} {givenList[1]} {givenList[2]} {givenList[3]}")
	return f"AT {sys.argv[1]} {time_difference_string} {givenList[1]} {givenList[2]} {givenList[3]}\n"
	

async def process_UPDATELOC(updateList):
	#updateList: UPDATELOC Goloman +0.263873386 +34.068930-118.445127 1520023934.918963997 kiwi.cs.ucla.edu
	logging.info(f'Received UPDATELOC of {updateList[5]}.')
	taskList = []
	if updateList[5] in locations: 
		if locations[updateList[5]] == updateList[1:]: #Check to see if already received update
			logging.info(f'Location of {updateList[5]} is already updated at {updateList[3]}.')
		else: #hasn't received updated location
			logging.info(f'Location of {updateList[5]} updated to {updateList[3]}.')
			locations[updateList[5]] = updateList[1:]
			#concurrently call other servers
			for i in communications[sys.argv[1]]:
				logging.info(f"Created Task for {i}.")
				taskList.append(asyncio.create_task(update_others(locations[updateList[5]], i)))
			for j in taskList:
				logging.info(f"Running Task.")
				await j
	else:
		logging.info(f'Adding to Dictionary: {updateList[5]} at {updateList[3]}.')
		locations[updateList[5]] = updateList[1:]
		#concurrently call other servers
		for i in communications[sys.argv[1]]:
			logging.info(f"Created Task for {i}.")
			taskList.append(asyncio.create_task(update_others(locations[updateList[5]], i)))
		for j in taskList:
			logging.info(f"Running Task.")
			await j

async def convertLat(input):
	counter =0; 
	returnString = ''
	placeholder = 0 
	for i in range(len(input)):
		if input[i] == '-' or input[i]=='+':
			counter = counter +1
		if counter == 2:
			placeholder = i
			break
	returnString = input[:placeholder] + ',' + input[placeholder:]
	return returnString

async def process_WHATSAT(givenList):
	#givenList: WHATSAT kiwi.cs.ucla.edu 10 5
	#kiwi.cs.ucla.edu: ['Goloman', '+0.263873386', '+34.068930-118.445127', 1520023934.918963997, kiwi.cs.ucla.edu]
	listSample = locations[givenList[1]]
	returnString = f"AT {listSample[0]} {listSample[1]} {listSample[4]} {listSample[2]} {listSample[3]}\n"
	convertedLatLon= await convertLat(listSample[2])
	urlLink = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={convertedLatLon}&radius={givenList[2]}&key={mykey}"
	async with aiohttp.ClientSession() as session:
		async with session.get(urlLink) as resp:
			respResponse = await resp.json()
	respResponse["results"] = respResponse["results"][:int(givenList[3])]
	returnString = returnString + json.dumps(respResponse, indent =3) + "\n\n"
	logging.info(f"WHATSAT RESPONSE: \n {returnString}")
	return returnString

async def handle_connection(reader, writer):
	data = await reader.read()
	name = data.decode()
	logging.info(f"RECEIVED REQUEST:\n {name}")
	listArgs = await parse_input(name)#divides the string into a list
	toReturn = ''
	if len(listArgs) == 1: #Catches Faulty Input
		toReturn =  toReturn + "? " + name
	elif listArgs[0] == 'IAMAT': # 
		toReturn = toReturn + await process_IAMAT(listArgs)
	elif listArgs[0] == 'UPDATELOC':
		await process_UPDATELOC(listArgs)
	else: #Eqauls WHATSAT
		toReturn = toReturn + await process_WHATSAT(listArgs)
	
	writer.write(toReturn.encode())
	await writer.drain()
	writer.close()

async def main():
	if len(sys.argv) != 2: 
		logging.error('Incorrect number of command line inputs')
		raise SystemExit
	else:
		if sys.argv[1] not in port_dictionary:
			logging.error('Wrong Port Name Given')
			raise SystemExit

		logging.info("Server Created")
		givenPort = port_dictionary[sys.argv[1]]
		server = await asyncio.start_server(handle_connection, host='127.0.0.1', port = givenPort)
		await server.serve_forever()

if __name__ == '__main__':
	asyncio.run(main())