# [DEEP Recognition App APK Generator](#info)
This repository contains sources of DEEP Recognition App APK Generator project. With these sources it is possible to build a mobile application that can work on both iOS and Android. App allows to make predictions of given input. Whole project consist of:

* Mobile application written in [Flutter](https://flutter.dev/)
* Python script [apkgenerator.py](apkgenerator.py) 
 
It is possible to parametrize colors, urls and strings of the app by setting them in the config JSON file which is given as input of the  script. It builds app and on its output the APK file is received. This file can be installed directly on Android device or signed and uploaded to Google Play Store. For iOS it is necessary to build app from sources on your own.

For now mobile app works with seven types of DEEP API-V2:

* [Audio Classifier](https://marketplace.deep-hybrid-datacloud.eu/modules/deep-oc-audio-classification-tf.html)
* [Conus Species Classifier](https://marketplace.deep-hybrid-datacloud.eu/modules/deep-oc-conus-classification-tf.html)
* [Image Classifier](https://marketplace.deep-hybrid-datacloud.eu/modules/deep-oc-image-classification-tf.html)
* [Phytoplankton Species Classifier](https://marketplace.deep-hybrid-datacloud.eu/modules/deep-oc-phytoplankton-classification-tf.html)
* [Plants Species Classifier](https://marketplace.deep-hybrid-datacloud.eu/modules/deep-oc-plants-classification-tf.html)
* [Seed Species Classifier](https://marketplace.deep-hybrid-datacloud.eu/modules/deep-oc-seeds-classification-tf.html)
* [Dogs Breed Detector](https://marketplace.deep-hybrid-datacloud.eu/modules/deep-oc-dogs-breed-det.html)

## [Installation and Usage](#installation)
To properly build project and generate APK, it is necessary to install following tools:

* Python 3 and pip installer
* JDK 8
* Working Android SDK
* Working Flutter SDK
* Git client

### Configuration and installation for Linux users.
First install pip installer for Python 3 using apt:

```
sudo apt update
sudo apt install python3-pip
```

Java 8 install:

```
sudo add-apt-repository ppa:openjdk-r/ppa
sudo apt update
sudo apt-get install openjdk-8-jdk
```

Download and configure Android SDK. Full instruction [here](https://github.com/codepath/android_guides/wiki/Installing-Android-SDK-Tools#installing-the-android-sdk-manual-way):

```
wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
sudo apt install unzip
unzip sdk-tools-linux-4333796.zip
rm sdk-tools-linux-4333796.zip
mkdir android-sdk
mv tools android-sdk
android-sdk/tools/bin/./sdkmanager --update
android-sdk/tools/bin/./sdkmanager "platforms;android-29" "build-tools;29.0.3" "extras;google;m2repository" "extras;android;m2repository"
android-sdk/tools/bin/./sdkmanager --licenses
export ANDROID_HOME=/home/user/android-sdk
export PATH=$PATH:$ANDROID_HOME/tools 
export PATH=$PATH:$ANDROID_HOME/platform-tools
```
Download and configure Flutter SDK. Full instruction [here](https://flutter.dev/docs/get-started/install):

```
wget https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_v1.12.13+hotfix.8-stable.tar.xz
tar xf flutter_linux_v1.12.13+hotfix.8-stable.tar.xz
rm flutter_linux_v1.12.13+hotfix.8-stable.tar.xz
export FLUTTER_HOME=$HOME/flutter
export PATH=$PATH:$FLUTTER_HOME/bin
sudo apt-get install lib32stdc++6
flutter precache
```

Install git and clone repository:

```
sudo apt install git
git clone https://github.com/indigo-dc/deep-recognition-app-apk-generator.git
```
### Running script
There are two necessary arguments while running script. Succesfully generated APK file is located in `build/app/outputs/apk/release`

```
python3 apkgenerator.py {android_project_path} {json_path}
```

## Customization
There are 8 parameters for customizing the app. It's possible to set name, main label, version name, icon, swagger_url, main colors and icon of the app. 

### JSON Structure
JSON file with parameters to set in the app contains following fields:

* `app_name` - name of the app,
* `main_activity_label` - text displayed in the app's top bar,
* `primary_color` - hex code of the primary color,
* `primary_dark_color` - hex code of the primary dark color,
* `accent_color` - hex code of the accent color,
* `version_name` - name of the app version,
* `icon_image_url` - url of the png image app's icon (512x512),
* `swagger_url` - url of swagger.json file with api definition.

Example JSON file [here](example_test.json).

### Design Customization
Customization of design parameters on screenshots.

![alt text](https://box.psnc.pl/f/a7c56d3ff1/?raw=1)