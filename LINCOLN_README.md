sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

https://developer.android.com/studio/install#linux

// This needs to be 3.3.5 for the current API settings

https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.3.5-stable.tar.xz

// older version of flutter needs jdk

https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb

// Need to copy contents of jbr into jre directory
~/Desktop/android-studio$ mkdir jre
~/Desktop/android-studio$ cp -r jbr/* jre/

https://docs.flutter.dev/get-started/install/linux/android?tab=download#verify-system-requirements

```
lthurlow@dev:/usr/bin/flutter$ flutter doctor
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.19.5, on Debian GNU/Linux 11 (bullseye) 5.10.0-27-amd64, locale en_US.UTF-8)
[!] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
    ✗ cmdline-tools component is missing
      Run `path/to/sdkmanager --install "cmdline-tools;latest"`
      See https://developer.android.com/studio/command-line for more details.
    ✗ Android license status unknown.
      Run `flutter doctor --android-licenses` to accept the SDK licenses.
      See https://flutter.dev/docs/get-started/install/linux#android-setup for more details.
[✓] Chrome - develop for the web
[✗] Linux toolchain - develop for Linux desktop
    ✗ GTK 3.0 development libraries are required for Linux development.
      They are likely available from your distribution (e.g.: apt install libgtk-3-dev)
[✓] Android Studio (version 2023.1)
[✓] Connected device (3 available)
[✓] Network resources

! Doctor found issues in 2 categories.
```

Go into android studio- under tools, and install command line tools


```
lthurlow@dev:/usr/bin/flutter$ flutter doctor
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.19.5, on Debian GNU/Linux 11 (bullseye) 5.10.0-27-amd64, locale en_US.UTF-8)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[✓] Chrome - develop for the web
[✓] Linux toolchain - develop for Linux desktop
[✓] Android Studio (version 2023.1)
[✓] Connected device (3 available)
[✓] Network resources

• No issues found!
```


go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init


Go back into android studios tool section and install NDK
- select version 21.1.6352462 (https://github.com/DefinedNet/mobile_nebula?tab=readme-ov-file#before-first-compile)


sudo gem install

cp env.sh.example env.sh

flutter build appbundle

Needed to modify android/app/build.gradle 

```
. ./test.env
```


Where the keystore is conifgured from android studio.


```
lthurlow@dev:~/Desktop/gocode/avoid/bundletool$ java -jar ./bundletool-all-1.15.6.jar build-apks --bundle=../mobile_nebula/build/app/outputs/bundle/release/app-release.aab --output=avoid.apks --mode=universal
INFO: The APKs will be signed with the debug keystore found at '/home/lthurlow/.android/debug.keystore'.
lthurlow@dev:~/Desktop/gocode/avoid/bundletool$ cp avoid.apks avoid.zip
lthurlow@dev:~/Desktop/gocode/avoid/bundletool$ unzip avoid.zip 
Archive:  avoid.zip
 extracting: toc.pb                  
 extracting: universal.apk         
```
