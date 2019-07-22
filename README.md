# APK Generator
Python script [apkgenerator.py](apkgenerator.py) is used to build and generate unsigned release apk file of [DEEP generic app]. It allows parametrize design, urls and strings by setting them in the JSON file.

## Installation and Usage
To properly build Android project and generate apk, it is necessary to install following tools:

* Python 3 and pip installer
* JDK 8
* Working Android SDK
* Working Flutter SDK
* Git client

### Instruction for Linux users.
First install pip installer for python3 using apt:

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
android-sdk/tools/bin/./sdkmanager "platforms;android-28" "build-tools;28.0.3" "extras;google;m2repository" "extras;android;m2repository"
android-sdk/tools/bin/./sdkmanager --licenses
export ANDROID_HOME=/home/user/android-sdk
export PATH=$PATH:$ANDROID_HOME/tools 
export PATH=$PATH:$ANDROID_HOME/platform-tools
```
Download and configure Flutter SDK. Full instruction [here](https://flutter.dev/docs/get-started/install):

```
wget https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_v1.5.4-hotfix.2-stable.tar.xz
tar xf flutter_linux_v1.5.4-hotfix.2-stable.tar.xz
rm flutter_linux_v1.5.4-hotfix.2-stable.tar.xz
export FLUTTER_HOME=$HOME/flutter
export PATH=$PATH:$FLUTTER_HOME/bin
sudo apt-get install lib32stdc++6
flutter precache
```

Install git, clone repository and checkout branch generic:

```
sudo apt install git
git clone https://git.man.poznan.pl/stash/scm/~skoba/deep_app.git 
cd deep_app
git checkout generic
```
### Running script
There are two necessary arguments while running script. Succesfully generated apk is located in `/app/build/outputs/apk/release`

```
python3 apkgenerator.py {android_project_path} {json_path}
```

## JSON Structure
JSON file with parameters to set in the app contains following fields:

* `app_name` - name of the app,
* `main_activity_label` - text displayed in the app's top bar,
* `main_activity_image_url` - url of the png image displayed in the main activity(960x960),
* `api_root_url` - root url of the api,
* `api_post_endpoint` - full path of the api's endpoint,
* `primary_color` - hex code of the primary color,
* `primary_dark_color` - hex code of the primary dark color,
* `accent_color` - hex code of the accent color,
* `version_name` - name of the app version,
* `icon_image_url` - url of the png image app's icon (512x512).

Example JSON [here](example_test.json).