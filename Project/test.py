import asyncio
import aiohttp

async def testerF():
	#urlLink = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=+34.068930,-118.445127&radius=10&key=AIzaSyBnmQNmA61BJG0L_okQYvsgMM4MLuJ7HjM"
	urlLink = f"https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=Museum%20of%20Contemporary%20Art%20Australia&inputtype=textquery&fields=photos,formatted_address,name,rating,opening_hours,geometry&key=AIzaSyBnmQNmA61BJG0L_okQYvsgMM4MLuJ7HjM"

	async with aiohttp.ClientSession() as session:
		async with session.get(urlLink) as resp:
			sample = await resp.json()
			print(sample)

def main():
	testerF

if __name__ == '__main__':
	main()