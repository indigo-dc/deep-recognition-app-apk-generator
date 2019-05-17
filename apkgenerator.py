import sys
import os
import json
import re
import importlib

APP_CONSTANTS_PATH = '/lib/utils/constants.dart'
PREVIEW_IMAGE_PATH = '/assets/images/plant.png'

DOWNLOADED_MAIN_ACTIVITY_IMAGE_PATH = "/plant.png"
DOWNLOADED_ICON_PATH = "/ic-launcher-web.png"

PREVIEW_IMAGE_RESOLUTION = 960
ICON_IMAGE_RESOLUTION = 512

def isColor(color):
	string = re.findall('^#[0-9,a-f,A-F]{6}$', color)
	if not string:
		print("Wrong color code: " + color)
		return False
	else:
		return True

def isImage(url):
	r = requests.get(url, allow_redirects=True)
	if(r.headers.get('content-type') == "image/png"):
		return True
	else:
		print("Wrong image url: " + url)
		return False

def isUrl(url):
	string = re.findall('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\), ]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', url)
	if not string:
		print("Wrong url: " + url)
		return False
	else:
		return True

def downloadFile(url, file_path):
	try:
		r = requests.get(url, allow_redirects=True)
		open(file_path, "wb").write(r.content)
		return True
	except Exception as e:
		print("File not downloaded from: " + url)
		return False

def isImageResolutionCorrect(file_path, expected_width, expected_height):
	image = Image.open(file_path)
	width, height = image.size
	if image.size == (expected_width, expected_height):
		return True
	else:
		print("Wrong resolution of image " + file_path)
		print(image.size)
		return False

def replaceLine(file_path, regex, new_content_regex):
	with open (file_path, 'r' ) as f:
		content = f.read()
		content_new = re.sub(regex, new_content_regex, content, flags = re.M)
	with open (file_path, "w") as f:
		f.write(content_new)

def importModule(module_name):
	try:
		globals()[module_name] = importlib.import_module(module_name)
		return True
	except Exception as e:
		#print("Import module error: ")
		print(e)
		return False

def installPackage(package_name):
	try:
		import pip 

		if hasattr(pip, 'main'):
			from pip import main
		else:
			from pip._internal import main
			
		main(['install', package_name])
		return True
	except Exception as e:
		print("Install package error: ")
		print(e)
		return False

def importModuleFrom(module_name, parent_module_name):
	try:
		globals()[module_name] = importlib.import_module("." + module_name, package = parent_module_name)
		return True
	except Exception as e:
		print(e)
		return False

def argsExists(args):
	if(len(args) == 3):
		return True
	else:
		print('Missing args ' + str(len(args)))
		return False

def androidFilesExists(dir):
	if (os.path.exists(dir + APP_CONSTANTS_PATH) and os.path.exists(dir + PREVIEW_IMAGE_PATH)):
		return True
	else:
		print('Wrong flutter project path')
		return False

def replaceData(dir, json_file_path):
	try:
		with open(json_file_path) as json_file:
			data = json.load(json_file)

			if not (isUrl(data['main_activity_image_url']) and isUrl(data["api_root_url"]) and isImage(data["main_activity_image_url"]) and 
				isUrl(data["icon_image_url"]) and isColor(data["primary_color"]) and isColor(data["primary_dark_color"]) and isColor(data["accent_color"])):
				return False

			if not (downloadFile(data['main_activity_image_url'], dir + DOWNLOADED_MAIN_ACTIVITY_IMAGE_PATH) and downloadFile(data["icon_image_url"], dir + DOWNLOADED_ICON_PATH)):
				return False

			if not (isImageResolutionCorrect(dir + DOWNLOADED_MAIN_ACTIVITY_IMAGE_PATH, PREVIEW_IMAGE_RESOLUTION, PREVIEW_IMAGE_RESOLUTION) and isImageResolutionCorrect(dir + DOWNLOADED_ICON_PATH, ICON_IMAGE_RESOLUTION, ICON_IMAGE_RESOLUTION)):
				return

			replaceLine(dir + STRINGS_PATH, "app_name\">(.+)</string>", "app_name\">" + app_name + "</string>")
			replaceLine(dir + STRINGS_PATH, "main.activity.label\">(.+)</string>", "main.activity.label\">" + main_activity_label + "</string>")
			replaceLine(dir + APP_PARAMETERS_PATH, "API_ROOT = \"(.+)\";", "API_ROOT = \"" + api_root_url + "\";")
			replaceLine(dir + APP_PARAMETERS_PATH, "API_POST_ENDPOINT = \"(.+)\";", "API_POST_ENDPOINT = \"" + api_post_endpoint + "\";")
			replaceLine(dir + COLORS_PATH, "primary\">(.+)</color>", "primary\">" + primary_color + "</color>")
			replaceLine(dir + COLORS_PATH, "primary_dark\">(.+)</color>", "primary_dark\">" + primary_dark_color + "</color>")
			replaceLine(dir + COLORS_PATH, "accent\">(.+)</color>", "accent\">" + accent_color + "</color>")
			replaceLine(dir + APP_BUILD_GRADLE_PATH, "versionName \"(.+)\"", "versionName \"" + version_name + "\"")

			return True
	except Exception as e:
		print(e)
		return False


def main():
	if not importModule("requests"):
		if installPackage("requests"):
			importModule("requests")
		else:
			exit()

	if not importModuleFrom("Image", "PIL"):
		if installPackage("Pillow"):
			importModuleFrom("Image", "PIL")
		else:
			exit()

	if not argsExists(sys.argv):
		exit()
	if not androidFilesExists(sys.argv[1]):
		exit()
	if not replaceData(sys.argv[1], sys.argv[2]):
		exit()


if __name__ == '__main__':
	main()