import sys
import os

APP_CONSTANTS_PATH = '/lib/utils/constants.dart'
PREVIEW_IMAGE_PATH = '/assets/images/plant.png'

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


def main():
	if not argsExists(sys.argv):
		exit()
	if not androidFilesExists(sys.argv[1]):
		exit()


if __name__ == '__main__':
	main()