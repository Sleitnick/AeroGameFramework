import requests
import os
from pathlib import Path

def download():
	print("Downloading Selene binary...")
	url = "https://api.github.com/repos/Kampfkarren/selene/releases/latest"
	res = requests.get(url)
	res.raise_for_status()
	release_info = res.json()
	asset = list(filter(lambda asset: asset["name"] == "selene-linux", release_info["assets"]))[0]
	bin_path = os.path.join(Path.home(), ".cargo", "bin")
	selene_path = os.path.join(bin_path, "selene")
	download_res = requests.get(asset["browser_download_url"], stream=True)
	with open(selene_path, "wb") as f:
		f.write(download_res.content)
	os.chmod(selene_path, 755)
	print("Selene downloaded")

if __name__ == "__main__":
	download()