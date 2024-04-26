# Building and using a test environment


Using [docker-android](https://github.com/budtmo/docker-android).

```
docker run --rm -d -p 6080:6080 -e EMULATOR_DEVICE="Samsung Galaxy S10" -e WEB_VNC=true --device /dev/kvm --name android-container -v /home/lthurlow/Desktop/avoid/mobile_nebula/appium-testing:/data budtmo/docker-android:emulator_13.0
```

The important value here is the API for 33, as nebula doesnt have v34 support yet.

For now everything in appium-testing directory should be u+rwx because of the container permissions.

## Copying files over

The first section is showing how we use `adb shell` to find where the device storage is.  This version shows when we have an emulated device attached.

```
androidusr@d54c1a6a5db0:~$ adb shell ls  /storage/emulated/0
Alarms
Android
Audiobooks
DCIM
Documents
Download
Movies
Music
Notifications
Pictures
Podcasts
Recordings
Ringtones
androidusr@d54c1a6a5db0:~$ adb push /data/ca.crt  /storage/emulated/0/Download/
/data/ca.crt: 1 file pushed, 0 skipped. 0.0 MB/s (235 bytes in 0.006s)
androidusr@d54c1a6a5db0:~$ adb push /data/work-phone.orbitingaround.dyndns.org.key  /storage/emulated/0/Download/
/data/work-phone.orbitingaround.dyndns.org.key: 1 file pushed, 0 skipped. 0.0 MB/s (127 bytes in 0.006s)
androidusr@d54c1a6a5db0:~$ adb push /data/work-phone.orbitingaround.dyndns.org.crt  /storage/emulated/0/Download/
/data/work-phone.orbitingaround.dyndns.org.crt: 1 file pushed, 0 skipped. 0.1 MB/s (341 bytes in 0.006s)
androidusr@d54c1a6a5db0:~$ adb push /data/test.json  /storage/emulated/0/Download/
/data/test.json: 1 file pushed, 0 skipped. 2.6 MB/s (511 bytes in 0.000s)
```

## Maybe end it there

So looking at the networking there is a [virtual network](https://developer.android.com/tools/adb#forwardports) for handling these.  At the moment the container doesnt have telnet to add 5554 to adjust ports, and adb canoot do it.  So I'll need to rebuild this container from scratch and ditch any security settings to allow for development.


# Lets look at appium controlling physical device

[Appium Container](https://hub.docker.com/r/appium/appium/)

```
dmesg | grep -i "usb" 
[1499170.136345] usb 4-1.3.2: new high-speed USB device number 54 using xhci_hcd
[1499170.303933] usb 4-1.3.2: New USB device found, idVendor=18d1, idProduct=4ee8, bcdDevice= 5.04
[1499170.303938] usb 4-1.3.2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[1499170.303941] usb 4-1.3.2: Product: SM6375-QRD _SN:DE0597A8
[1499170.303943] usb 4-1.3.2: Manufacturer: OnePlus
[1499170.303944] usb 4-1.3.2: SerialNumber: de0597a8
[1499185.989863] usb 4-1.3.2: USB disconnect, device number 54
[1499186.524327] usb 4-1.3.2: new high-speed USB device number 55 using xhci_hcd
[1499186.678380] usb 4-1.3.2: New USB device found, idVendor=22d9, idProduct=2765, bcdDevice= 5.04
[1499186.678386] usb 4-1.3.2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[1499186.678389] usb 4-1.3.2: Product: SM6375-QRD _SN:DE0597A8
[1499186.678391] usb 4-1.3.2: Manufacturer: OnePlus
[1499186.678392] usb 4-1.3.2: SerialNumber: de0597a8
[1499191.907139] usb 4-1.3.2: reset high-speed USB device number 55 using xhci_hcd
[1499192.227025] usb 4-1.3.2: reset high-speed USB device number 55 using xhci_hcd
[1499192.632352] usb 4-1.3.2: device descriptor read/64, error -71
```

Then validate the device:
```
sudo ls /sys/bus/usb/devices/4-1.3.2/
```

```
docker run --rm --privileged -d -p 4723:4723 -v /dev/bus/usb:/dev/bus/usb --name appium-container appium/appium
```

Note that after this, it doesnt usually look like adb connects to the phone:

```
04-26 18:19:01.689    10    10 E adb     : usb_libusb.cpp:600 failed to claim adb interface for device 'de0597a8': LIBUSB_ERROR_BUSY
04-26 18:19:01.689    10    10 I adb     : transport.cpp:1150 de0597a8: connection terminated: failed to claim adb interface for device 'de0597a8': LIBUSB_ERROR_BUSY
```

So, what we do, is (have the phone on wifi).  Enable phone wifi debugging. [In developer mode settings]

```
adb tcpip 5555
adb connect <phone_ip>:5555
```

Getting phone ip from termux `ifconfig` on the phone itself.

```
adb devices -l
```

Should show the phone connected over tcpip.

Disconnect USB cable.

Exec back into container

```
lthurlow@dev:~/Desktop/gocode/avoid/mobile_nebula/appium-testing$ docker exec -it appium-container /bin/bash
androidusr@1f4d576f9fe5:~$ adb kill-server
cannot connect to daemon at tcp:5037: Cannot assign requested address
androidusr@1f4d576f9fe5:~$ adb connect 192.168.1.48:5555
* daemon not running; starting now at tcp:5037
* daemon started successfully
failed to authenticate to 192.168.1.48:5555
androidusr@1f4d576f9fe5:~$ 
androidusr@1f4d576f9fe5:~$ adb connect 192.168.1.48:5555
already connected to 192.168.1.48:5555
androidusr@1f4d576f9fe5:~$ adb devices -l
List of devices attached
192.168.1.48:5555      device product:CPH2513 model:CPH2513 device:OP5958L1 transport_id:1

```

### Creating python environment

Using [pyenv](https://github.com/pyenv/pyenv-virtualenv)

```
pyenv virtualenv 3.9.0 appium
```

`/home/lthurlow/Desktop/gocode/avoid/mobile_nebula/appium-testing/python-code`

```
pip3 install Appium-Python-Client
```

Back in, android settings, needed to go and set `Disable Permission Monitoring` to enabled.

Seemed a bit flaky, so I ended up turning on wifi debugging as well.

Then used these settings:

```
docker run --rm -d -p 4723:4723 -e REMOTE_ADB=true -e ANDROID_DEVICES=192.168.1.48:5555 -e REMOTE_ADB_POLLING_SEC=60 --name appium-container appium/appium
```

And a pop-up came on the phone to allow device for debugging.

Sometimes, we lose connectivity to the phone, we need to make sure that the host system has a adb connection, and then magically the container will pick back up on the adb connection.







