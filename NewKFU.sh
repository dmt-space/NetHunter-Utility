#!/bin/sh

printf '\033[8;27;100t'

###########################
###Device Selection Menu###
###########################
f_deviceselect(){
clear
echo "Please select your device:"
echo ""
echo "[1] Nexus  5  2013             [Hammerhead]"
echo "[2] Nexus  7  2012   Wifi      [Grouper]"
echo "[3] Nexus  7  2012   Cellular  [Tilapia]"
echo "[4] Nexus  7  2013   Wifi      [Flo]"
echo "[5] Nexus  7  2013   LTE       [Deb]"
echo "[6] Autodetect (Plug in before selecting)"
echo ""
read -p "" device

case $device in
	1) currentdevice=hammerhead; clear; f_menu;;
	2) currentdevice=grouper; clear; f_menu;;
	3) currentdevice=tilapia; clear; f_menu;;
	4) currentdevice=flo; clear; f_menu;;
	5) currentdevice=deb; clear; f_menu;;
	6) f_dl_tools; f_autodetect; f_menu;;
	*) clear; echo "Unknown selection, please try again"; f_device_select;;
esac
}

#######################
###Autodetect Script###
#######################
f_autodetect(){
aversion="$adb shell getprop ro.build.version.release"
}

###############
###Main Menu###
###############
f_menu(){
maindir=~/Kali
commondir=$maindir/All
devicedir=$maindir/$currentdevice
mkdir -p $devicedir
#----"####################################################################################################"
echo "Your current selected device is: $currentdevice"
echo ""
echo "Please make a selection:"
echo "[1] Install Everything                              [4] Just Download Files for manual install"
echo "[2] Just Unlock Bootloader                          [5] Delete All Existing Files"
echo "[3] Just Install MultiROM                           [6] Select A Different Device"
echo ""
echo "[Q] Exit"
read -p "" menuselection

case $menuselection in
	1) f_dl_tools; f_dl_multirom; f_dl_kalirom; f_dl_gapps; f_dl_su; f_dl_kali; f_dl_kalikernel; f_unlock; f_multirom; f_btr; f_kalirom; f_btr; f_gapps; f_btr; f_su; f_btr; f_kali; f_btr; f_kalikernel; f_menu;;
	2) f_dl_tools; f_unlock; f_menu;;
	3) f_dl_tools; f_dl_multirom; f_unlock; f_multirom; f_menu;;
	4) f_dl_tools; f_dl_multirom; f_dl_kalirom; f_dl_gapps; f_dl_su; f_dl_kali; f_dl_kalikernel; f_menu;;
	5) f_delete;;
	6) f_deviceselect;;
	q) clear; exit;;
	*) f_menu;;
esac

}

########################
###Download ADB Tools###
########################
f_dl_tools(){
clear
unamestr=`uname`
if [[ "$unamestr" == 'Darwin' ]];
then
echo "OS X operating system detected."
echo ""
echo "Downloading ADB (1/10)"
echo ""
curl -L -o ~/Kali/adb 'http://sourceforge.net/projects/kaliflashutility/files/Android%20Utilities/Mac/adb/download'
clear
echo "Downloading Fastboot (2/10)"
echo ""
curl -L -o ~/Kali/fastboot 'http://sourceforge.net/projects/kaliflashutility/files/Android%20Utilities/Mac/fastboot/download'
else
echo "Linux-based OS detected."
echo ""
echo "Installing cURL (Password may be required)"
sudo apt-get -qq update && sudo apt-get -qq -y install curl
echo ""
echo "Downloading ADB (1/10)"
echo ""
curl -L -o ~/Kali/adb 'http://sourceforge.net/projects/kaliflashutility/files/Android%20Utilities/Linux/adb/download'
clear
echo "Downloading Fastboot (2/10)"
echo ""
curl -L -o ~/Kali/fastboot 'http://sourceforge.net/projects/kaliflashutility/files/Android%20Utilities/Linux/fastboot/download'
fi
adb=$maindir/adb
fastboot=$maindir/fastboot
chmod 755 $adb
chmod 755 $fastboot

clear
}

#######################
###Download MultiROM###
#######################
f_dl_multirom(){
clear
echo "Is your existing ROM based off of" basekernel
echo "[1] AOSP"
echo "[2] CyanogenMod"
read -p "" basekernel
clear

echo "Downloading Multirom"
url="http://sourceforge.net/projects/kaliflashutility/files/${currentdevice}/multirom.zip/download"
curl -L -o $devicedir/multirom.zip $url
clear

if [[ "$basekernel" == '1' ]]; then
kerneltype=""
elif [[ "$basekernel" == '2' ]]; then
kerneltype=-cm
fi
echo "Downloading MultiROM Kernel"
echo ""
url="http://sourceforge.net/projects/kaliflashutility/files/${currentdevice}/base-kernel${kerneltype}.zip/download"
curl -L -o $devicedir/base-kernel$kerneltype.zip $url
clear

echo "Downloading TWRP"
url="http://sourceforge.net/projects/kaliflashutility/files/${currentdevice}/TWRP.img/download"
curl -L -o $devicedir/twrp.img $url
clear
}

#######################
###Download Kali ROM###
#######################
f_dl_kalirom(){
clear
echo "What ROM would you like?"
echo "[1] OmniROM"
echo "(More to come later)"
read -p "" romchoice
if [[ "$romchoice" == '1' ]]; then
rom="omni"
elif [[ "$romchoice" == '2' ]]; then
rom="paranoid"
fi
url="http://sourceforge.net/projects/kaliflashutility/files/${currentdevice}/${rom}.zip/download"
echo "Downloading ROM"
echo ""
curl -L -o $devicedir/$rom.zip $url
clear
}

####################
###Download GApps###
####################
f_dl_kalirom(){
clear
echo "Downloading GApps"
echo ""
curl -L -o $commondir/gapps.zip 'http://sourceforge.net/projects/kaliflashutility/files/All/gapps.zip/download'
clear
}

######################
###Download SuperSU###
######################
f_dl_su(){
clear
echo "Downloading SuperSU"
echo  ""
mkdir -p $commondir
cd $commondir
python << END
import urllib2
import urllib

class LatestRomUtil:

def __init__(self, device):
	self.changeDevice(device)
def __getPage(self, url, retRedirUrl = False):
	try:
		bOpener = urllib2.build_opener()
		bOpener.addheaders = [("User-agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.146 Safari/537.36")]
		pResponse = bOpener.open(url)
		if retRedirUrl == True:
			return pResponse.geturl()
		else:
			pageData = pResponse.read()
			return pageData
	except Exception:
		return ""		
def changeDevice(self, device):
	self.device = device.strip().lower()
def dlSuperSU(self):
	getUrl = self.__getPage("http://download.chainfire.eu/supersu", True)
	latestUrl = getUrl + "?retrieve_file=1"
	return latestUrl
	

# below is example usage
romUtil = LatestRomUtil("tf300t")

print "Latest SuperSU: " + romUtil.dlSuperSU()
print ""
print "Downloading to su.zip"
urllib.urlretrieve (romUtil.dlSuperSU(), "su.zip")
END
cd ~/
echo "Download complete"
sleep 1
clear
}

#############################
###Download Kali Utilities###
#############################
f_dl_su(){
clear
echo "Downloading Kali Utilities (This could take a while!)"
echo ""
curl -L -o $commondir/kali-utilities.zip 'http://sourceforge.net/projects/kaliflashutility/files/All/kali-utilities.zip/download'
clear
}

##########################
###Download Kali Kernel###
##########################
f_dl_kalikernel(){
clear
url="http://sourceforge.net/projects/kaliflashutility/files/${currentdevice}/kali-kernel.zip/download"
echo "Downloading Kernel for Kali"
echo ""
curl -L -o $devicedir/kali-kernel.zip $url
clear
}

###################
###Unlock Device###
###################
f_unlock(){
clear
echo "WARNING: This step will erase your device if your bootloader is locked!"
echo "If your bootloader is already unlocked, this will not affect your device."
echo ""
echo "Boot into the bootloader by turning off the device and holding the volume down and power button."
read -p "Press [Enter] to continue."
clear
$fastboot oem unlock
clear
echo "On the screen there is a prompt to erase the device, select yes. THIS ERASES YOUR DEVICE!!!"
read -p "Once the device finishes erasing, set up your device like normal before continuing"
clear
}

####################
###Flash MultiROM###
####################
f_multirom(){
clear
echo "Boot into the bootloader by turning off the device and holding the volume down and power button."
echo ""
read -p "Press [Enter] to continue."
clear
echo "Please wait. Your device will reboot a few times. Dont touch your device until told to do so."
echo ""
echo "Flashing TWRP"
$fastboot flash recovery $devicedir/twrp.img
clear
echo "Please wait. Your device will reboot a few times. Don't touch your device until told to do so."
echo ""
echo "Booting into recovery"
$fastboot boot $devicedir/twrp.img
clear
echo "Please wait. Your device will reboot a few times. Don't touch your device until told to do so."
echo ""
echo "Booting into recovery (again)"
sleep 15
$adb reboot recovery
sleep 15
clear
echo "Please wait. Your device will reboot a few times. Don't touch your device until told to do so."
echo ""
echo "Moving files to device to install"
$adb push $devicedir/base-kernel${kerneltype}.zip /sdcard/kali/base-kernel.zip
$adb push $devicedir/multirom.zip /sdcard/kali/multirom.zip
$adb shell "echo -e 'print ##################################\nprint #####Installing MultiROM#####\nprint ##################################\ninstall /sdcard/Kali/multirom.zip\nprint ###########################\nprint #####Installing Kernel#####\nprint ###########################\ninstall /sdcard/Kali/basekernel.zip\ncmd reboot recovery\n' > /cache/recovery/openrecoveryscript"
$adb reboot recovery
sleep 90
$adb shell rm -rf /sdcard/kali/base-kernel.zip
$adb shell rm -rf /sdcard/kali/multirom.zip
$adb reboot
clear
}

######################
###Boot To Recovery###
######################
f_btr(){
clear
echo "Boot into recovery by turning the device off and pressing and holding volume up and power."
echo "If you are already in recovery, make sure you are at the home screen."
echo ""
read -p "Press [Enter] to continue."
clear
}

####################
###Flash Kali ROM###
####################
f_kalirom(){
clear
echo "Tap Advanced > MultiROM > Add ROM > Next > ADB Sideload"
echo ""
read -p "Press [Enter] to continue."
clear
echo "Flashing ROM"
echo ""
$adb sideload $devicedir/$rom.zip
echo ""
read -p "Press [Enter] when complete."
clear
}

################
###Rename ROM###
################
f_rename(){
clear
echo "Tap Advanced > MultiROM > List ROMs > Sideload > Rename > Rename it to Kali"
echo ""
read -p "Press [Enter] to continue."
clear
}

###################
###Install GApps###
###################
f_gapps(){
clear
echo "Tap Advanced > MultiROM > List ROMs > Kali > Sideload"
echo ""
read -p "Press [Enter] to continue"
clear
echo "Flashing GApps"
echo ""
$adb sideload $commmondir/gapps.zip
echo ""
read -p "Press [Enter] when complete"
clear
}

#####################
###Install SuperSU###
#####################
f_su(){
clear
echo "Tap Advanced > MultiROM > List ROMs > Kali > Sideload"
echo ""
read -p "Press [Enter] to continue"
clear
echo "Flashing SuperSU"
echo ""
$adb sideload $commmondir/su.zip
echo ""
read -p "Press [Enter] when complete"
clear
}

################
###Flash Kali###
################
f_kali(){
clear
echo "Tap Advanced > MultiROM > List ROMs > Kali > Sideload"
echo ""
read -p "Press [Enter] to continue"
clear
echo "Flashing Kali utilities (This could take a while!)"
echo ""
$adb sideload $commondir/kali-utilities.zip
echo ""
read -p "Press [Enter] when complete"
clear
}

#########################
###Install Kali Kernel###
#########################
f_kalikernel(){
clear
echo "Tap Advanced > MultiROM > List ROMs > Kali > Sideload"
echo ""
read -p "Press [Enter] to continue"
clear
echo "Flashing Kali Kernel"
echo ""
$adb sideload $devicedir/kali-kernel.zip
echo ""
read -p "Press [Enter] when complete"
clear
}

######################
###Delete all files###
######################
f_delete(){
clear
read -p "Are you want to delete all of the files? (Y/N)" del
case $del in
Y|y ) 
clear
echo "Deleting files..."
rm -rf $maindir
sleep 2
clear
echo "Deleted"
sleep 2
clear
f_menu;;
N|n )
clear
echo "Keeping files..."
sleep 2
clear
f_menu;;
esac
}

f_deviceselect