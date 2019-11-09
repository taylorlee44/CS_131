import logging
import asyncio

logging.basicConfig(filename = "test3_log.txt", filemode = 'w', format='%(asctime)s: %(message)s', datefmt='%d-%b-%y %H:%M:%S', level=20)

async def nested(value):
	await asyncio.sleep(value)
	logging.info("Logging Message.")

async def main ():
	taskList = []
	for i in range(4): 
		taskList.append(asyncio.create_task(nested(i)))

	for j in taskList:
		await j

asyncio.run(main())