Instruction to deploy Joyn chat use case in Ubuntu 32-bit slave and Jenkins 

1. Export monkey runner path: 

1.1. export PATH=$PATH:$ANDROID_HOME/platform-tools
1.2. export PATH=$PATH:$ANDROID_HOME/tools

Note: Here we are assuming the ANDROID_HOME is already set. It should similar(not excatly same) as given below.
export ANDROID_HOME=/home/username/android-sdks

2. Export device variable and test server port name for the following:

2.1.  ADB_DEVICE_ARG
2.2.  ADB_DEVICE_ARG2
2.3.  TEST_SERVER_PORT
2.4.  TEST_SERVER_PORT2

3. How to install tesseract and python wrapper for tesseract
Installing tesseract is a bit tricky. Try to follow the below steps. But if this process fails, refer section 4. 

3.1. wget http://python-tesseract.googlecode.com/files/python-tesseract_0.7-1.4_i386.deb
 
3.2. sudo apt-get install tesseract-ocr

3.4. sudo dpkg -i python-tesseract_0.7-1.4_i386.deb

3.5. sudo apt-get -f install

If ubuntu machine says “Package libleptonica is not installed” then follow the steps till 3.12

If python wrapper for tesseract is installed correctly no need to follow the following steps. 

3.6. extract package contents

dpkg-deb -x python-tesseract_0.7-1.4_i386.deb python-tesseract_0.7-1.4_i386

3.7. extract CONTROL file from deb

dpkg-deb --control python-tesseract_0.7-1.4_i386.deb python-tesseract_0.7-1.4_i386/DEBIAN

3.8. replace libleptonica dependency with liblept3

sed -i "s/libleptonica/liblept3 (>= 1\.68)/g" python-tesseract_0.7-1.4_i386/DEBIAN/control

3.9.  rebuild package with correct dependencies

dpkg -b python-tesseract_0.7-1.4_i386 python-tesseract_0.7-1.4_i386new.deb

3.11. sudo dpkg -i python-tesseract_0.7-1.4_i386new.deb

3.12. sudo apt-get -f install



4. Installing tesseract the hard way:

Refer:
http://dudczak.info/dry/index.php/2011/01/tesseract-3-0-installation-on-ubuntu-10-10-server/

After installing, one may get a segmentation fault when running it:
actual_tessdata_num_entries_ <= TESSDATA_NUM_ENTRIES:Error:Assert failed:in file tessdatamanager.cpp, line 55
Segmentation fault

To fixed it, follow this link (replacing the language data file): http://ubuntuforums.org/showthread.php?t=1647350
 


4.0 Command to run calabash :

SCREENSHOT_VIA_USB=true calabash-android  run Joyn_v3.0.8_debug.apk features/chat.feature -v TEST_SERVER_PORT=${CFG_TEST_SERVER_PORT:-34777} TEST_SERVER_PORT2=${CFG_TEST_SERVER_PORT2:-34778} --format junit --out results --format html --out cucumber-reports-chat.html -f usage --out usage.txt

Note : Joyn_v3.0.8_debug.apk  should be installed in the devices under test

