#!/usr/bin/python3

import sys
import os
import json
import re
import importlib
import shutil
import subprocess
import asyncio
import site

APP_CONSTANTS_PATH = '/lib/utils/constants.dart'
ANDROID_MANIFEST_PATH = '/android/app/src/main/AndroidManifest.xml'
ANDROID_APP_BUILD_GRADLE_PATH = '/android/app/build.gradle'

PREVIEW_IMAGE_PATH = '/assets/images/plant.png'
DOWNLOADED_MAIN_ACTIVITY_IMAGE_PATH = '/plant.png'
DOWNLOADED_ICON_PATH = '/ic-launcher-web.png'
ANDROID_ICON_LAUNCHER_MDPI_PATH = '/android/app/src/main/res/mipmap-mdpi/ic_launcher_foreground.png'
ANDROID_ICON_LAUNCHER_HDPI_PATH = '/android/app/src/main/res/mipmap-hdpi/ic_launcher_foreground.png'
ANDROID_ICON_LAUNCHER_XHDPI_PATH = '/android/app/src/main/res/mipmap-xhdpi/ic_launcher_foreground.png'
ANDROID_ICON_LAUNCHER_XXHDPI_PATH = '/android/app/src/main/res/mipmap-xxhdpi/ic_launcher_foreground.png'
ANDROID_ICON_LAUNCHER_XXXHDPI_PATH = '/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png'
PREVIEW_IMAGE_PATH = '/assets/images/plant.png'
ICON_PATH = '/assets/images/ic-launcher-web.png'


PREVIEW_IMAGE_RESOLUTION = 960
ICON_IMAGE_RESOLUTION = 512
ANDROID_ICON_LAUNCHER_MDPI_RESOLUTION = 48
ANDROID_ICON_LAUNCHER_HDPI_RESOLUTION = 72
ANDROID_ICON_LAUNCHER_XHDPI_RESOLUTION = 96
ANDROID_ICON_LAUNCHER_XXHDPI_RESOLUTION = 144
ANDROID_ICON_LAUNCHER_XXXHDPI_RESOLUTION = 192


def isColor(color):
	string = re.findall('^#[0-9,a-f,A-F]{6}$', color)
	if not string:
		print('Wrong color code: ' + color)
		return False
	else:
		return True

def isImage(url):
	r = requests.get(url, allow_redirects=True)
	if(r.headers.get('content-type') == 'image/png'):
		return True
	else:
		print('Wrong image url: ' + url)
		return False

def isUrl(url):
	string = re.findall('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\), ]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', url)
	if not string:
		print('Wrong url: ' + url)
		return False
	else:
		return True

def downloadFile(url, file_path):
	try:
		r = requests.get(url, allow_redirects=True)
		open(file_path, 'wb').write(r.content)
		return True
	except Exception as e:
		print('File not downloaded from: ' + url)
		return False

def isImageResolutionCorrect(file_path, expected_width, expected_height):
	image = Image.open(file_path)
	width, height = image.size
	if image.size == (expected_width, expected_height):
		return True
	else:
		print('Wrong resolution of image ' + file_path)
		print(image.size)
		return False

def replaceLine(file_path, regex, new_content_regex):
	with open (file_path, 'r' ) as f:
		content = f.read()
		content_new = re.sub(regex, new_content_regex, content, flags = re.M)
	with open (file_path, "w") as f:
		f.write(content_new)

def getIntegerValueFromFile(file, regex):
	with open (file, 'r' ) as f:
		content = f.read()
	string = re.findall(regex, content)
	if string:
		num_string = re.findall("[0-9]+", string[0])
		if num_string:
			return int(num_string[0])
		else:
			return 0
	else:
		return 

def resizeAndMoveImage(file_path, new_file_path, width, height):
	with open(file_path, 'r+b') as f:
		with Image.open(f) as image:
			cover = resizeimage.resize_cover(image, [width, height])
			cover.save(new_file_path, image.format)

def moveFile(file_path, new_file_path):
	shutil.move(file_path, new_file_path)

def importModule(module_name):
	try:
		importlib.reload(site)
		globals()[module_name] = importlib.import_module(module_name)
		print("Imported succesfully module " + module_name)
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
		print("Installed succesfully package " + package_name)
		return True
	except Exception as e:
		print("Install package error: ")
		print(e)
		return False

def importModuleFrom(module_name, parent_module_name):
	try:
		importlib.reload(site)
		globals()[module_name] = importlib.import_module("." + module_name, package = parent_module_name)
		print("Imported succesfully module " + module_name + " from " + parent_module_name)
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

def isJavaInstalled():
	if os.system('java -version') != 0:
		return False
	else:
		return True

def isAndroidPathSet():
	if os.environ.get('ANDROID_HOME') is None:
		print('ANDROID_HOME not set')
		return False
	else:
		return True

def isFlutterInPath():
	try:
		output = subprocess.check_output("echo $PATH | grep -q flutter && echo directory exists", shell = True)
		print('Flutter Path found')
		return True
	except subprocess.CalledProcessError as e:
		print('Flutter not found in PATH')
		return False

def replaceData(dir, json_file_path):
	try:
		with open(json_file_path) as json_file:
			data = json.load(json_file)

			if not (isUrl(data['main_activity_image_url']) and isUrl(data['api_root_url']) and isImage(data['main_activity_image_url']) and 
				isUrl(data['icon_image_url']) and isColor(data['primary_color']) and isColor(data['primary_dark_color']) and isColor(data['accent_color'])):
				return False

			if not (downloadFile(data['main_activity_image_url'], dir + DOWNLOADED_MAIN_ACTIVITY_IMAGE_PATH) and downloadFile(data['icon_image_url'], dir + DOWNLOADED_ICON_PATH)):
				return False

			if not (isImageResolutionCorrect(dir + DOWNLOADED_MAIN_ACTIVITY_IMAGE_PATH, PREVIEW_IMAGE_RESOLUTION, PREVIEW_IMAGE_RESOLUTION) and isImageResolutionCorrect(dir + DOWNLOADED_ICON_PATH, ICON_IMAGE_RESOLUTION, ICON_IMAGE_RESOLUTION)):
				return

			replaceLine(dir + ANDROID_MANIFEST_PATH, 'android:label=\"(.+)\"', 'android:label=\"' + data['app_name'] + '\"')
			replaceLine(dir + APP_CONSTANTS_PATH, 'app_label = \"(.+)\";', 'app_label = \"' + data['main_activity_label'] + '\";')
			replaceLine(dir + APP_CONSTANTS_PATH, 'api_url = \"(.+)\";', 'api_url = \"' + data['api_root_url'] + '\";')
			replaceLine(dir + APP_CONSTANTS_PATH, 'post_endpoint = \"(.+)\";', 'post_endpoint = \"' + data["api_post_endpoint"] + '\";')


			replaceLine(dir + APP_CONSTANTS_PATH, 'primary_color = Color\(0xFF([0-9,A-F,a-f]*)\);', 'primary_color = Color(0xFF' + data["primary_color"][-6:] + ');')

			replaceLine(dir + APP_CONSTANTS_PATH, 'primary_dark_color = Color\(0xFF([0-9,A-F,a-f]*)\);', 'primary_dark_color = Color(0xFF' + data["primary_dark_color"][-6:] + ');')

			replaceLine(dir + APP_CONSTANTS_PATH, 'accent_color = Color\(0xFF([0-9,A-F,a-f]*)\);', 'accent_color = Color(0xFF' + data["accent_color"][-6:] + ');')

			replaceLine(dir + ANDROID_APP_BUILD_GRADLE_PATH, 'flutterVersionName = \'(.+)\'', 'flutterVersionName = \'' + data['version_name'] + '\'')

			version_code = getIntegerValueFromFile(dir + ANDROID_APP_BUILD_GRADLE_PATH, "flutterVersionCode = \'[0-9]+\'")
			if(version_code > 0):
				version_code += 1
				replaceLine(dir + ANDROID_APP_BUILD_GRADLE_PATH, "flutterVersionCode = \'[0-9]+\'", "flutterVersionCode = \'" + str(version_code) + "\'")

			resizeAndMoveImage(dir + DOWNLOADED_ICON_PATH, dir + ANDROID_ICON_LAUNCHER_MDPI_PATH, ANDROID_ICON_LAUNCHER_MDPI_RESOLUTION, ANDROID_ICON_LAUNCHER_MDPI_RESOLUTION)
			resizeAndMoveImage(dir + DOWNLOADED_ICON_PATH, dir + ANDROID_ICON_LAUNCHER_HDPI_PATH, ANDROID_ICON_LAUNCHER_HDPI_RESOLUTION, ANDROID_ICON_LAUNCHER_HDPI_RESOLUTION)
			resizeAndMoveImage(dir + DOWNLOADED_ICON_PATH, dir + ANDROID_ICON_LAUNCHER_XHDPI_PATH, ANDROID_ICON_LAUNCHER_XHDPI_RESOLUTION, ANDROID_ICON_LAUNCHER_XHDPI_RESOLUTION)
			resizeAndMoveImage(dir + DOWNLOADED_ICON_PATH, dir + ANDROID_ICON_LAUNCHER_XXHDPI_PATH, ANDROID_ICON_LAUNCHER_XXHDPI_RESOLUTION, ANDROID_ICON_LAUNCHER_XXHDPI_RESOLUTION)
			resizeAndMoveImage(dir + DOWNLOADED_ICON_PATH, dir + ANDROID_ICON_LAUNCHER_XXXHDPI_PATH, ANDROID_ICON_LAUNCHER_XXXHDPI_RESOLUTION, ANDROID_ICON_LAUNCHER_XXXHDPI_RESOLUTION)

			moveFile(dir + DOWNLOADED_MAIN_ACTIVITY_IMAGE_PATH, dir + PREVIEW_IMAGE_PATH)
			moveFile(dir + DOWNLOADED_ICON_PATH, dir + ICON_PATH)

			return True
	except Exception as e:
		print(e)
		return False

def buildProject():
	try:	
		result = subprocess.run(['flutter', 'build', 'apk'], stdout=subprocess.PIPE).stdout.decode('utf-8')
		print("Output: " + result)
	except:
		print("Error while building app")

def main():
	if not importModule("requests"):
		print("Cannot import module requests. Installing package requests")
		if installPackage("requests"):
			print("Importing installed module requests")
			importModule("requests")
		else:
			print("Cannot install module requests")
			exit()

	if not importModuleFrom("resizeimage", "resizeimage") or not importModuleFrom("Image", "PIL"):
		print("Cannot import module resizeimage from resizeimage. Installing package python-resize-image")
		if installPackage("python-resize-image"):
			print("Importing installed module resizeimage from resizeimage")
			if not importModuleFrom("resizeimage", "resizeimage"):
				exit()
			print("Importing installed module Image from PIL")
			if not importModuleFrom("Image", "PIL"):
				exit()
		else:
			print("Cannot install module python-resize-image")
			exit()

	#if not importModuleFrom("Image", "PIL"):
	#	print("Cannot import module Image from PIL. Installing package Pillow")
	#	if installPackage("Pillow"):
	#		print("Importing installed module Image from PIL")
	#		if not importModuleFrom("Image", "PIL"):
	#			exit()
	#	else:
	#		print("Cannot install module Pillow")
	#		exit()

	if not argsExists(sys.argv):
		exit()
	if not androidFilesExists(sys.argv[1]):
		exit()
	if not isJavaInstalled():
		exit()
	if not isAndroidPathSet():
		exit()
	if not isFlutterInPath():
		exit()
	if not replaceData(sys.argv[1], sys.argv[2]):
		exit()
	buildProject()


if __name__ == '__main__':
	main()