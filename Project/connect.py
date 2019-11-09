import asyncio

async def main():
	reader, writer = await asyncio.open_connection('127.0.0.1', 12138)
	writer.write("IAMAT kiwi.cs.ucla.edu +34.068930-118.445127 1520023934.918963997\n".encode())
	data = await reader.readline()
	print('Received: {}'.format(data.decode()))
	writer.close()

	reader2, writer2 = await asyncio.open_connection('127.0.0.1', 12139)
	writer2.write("IAMAT taylor.cs.ucla.edu +35.068930-118.445127 1520023934.918963997\n".encode())
	data2 = await reader2.readline()
	print('Received: {}'.format(data2.decode()))
	writer2.close()

if __name__ == '__main__':
	asyncio.run(main())
