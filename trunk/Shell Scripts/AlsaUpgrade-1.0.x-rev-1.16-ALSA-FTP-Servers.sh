#!/bin/bash 
#
# AlsaUpgrade-1.0.x-rev-1.X.sh 
# Provided under the GNU General Public License version 2 or later or the GNU Free Documentation License version 1.2 or later, at your option.
# See http://www.gnu.org/copyleft/gpl.html for the Warranty Disclaimer.

# This script upgrades ALSA on Ubuntu systems with 2.6.24-28 (non)-ubuntu kernels and is not following 
# official Ubuntu/Debian Package handling rules

# This script is not compliant to Ubuntu official package handling. This script overwrites the existing files and modules.
# You won't see any changes on the revisions if you run e.g. Synaptics..
# If there are official ALSA updates supplied by Ubuntu repositories or kernel changes, these will overwrite your manual ALSA installation - 
# you need to re-run this script in this case.
# You can check the Alsa revision by typing "cat /proc/asound/version" or "alsactl --version" or the utils by "aplay --version" 
#
# Note: As usual  I'd like to recommend that you make a backup of your drive first. I don't guarantee for anything!
#
# The script compiles all drivers by default.
#
# The official thread connected to this script you'll find at: http://ubuntuforums.org/showthread.php?t=962695   
# 
# You might want to go through the script and try to understand what it is doing. It's not a must though. 
#
#  Changelog:
#
#  Rev: 1.00  01-01-2008 Temueijn 
#  Rev: 1.01  09-05-2008 soundcheck Changelog: Bugfixes/A bit of cleanup
#  Rev: 1.02  09-22-2008 soundcheck Changelog: A bit of cleanup/Intro of revison handling/Install drivers before libs/2.6.27 support/multiple alsa-rev support
#  Rev: 1.03  10-04-2008 soundcheck Changelog: PackageUpdate AlsaLib 1.0.17a
#  Rev: 1.04  10-05-2008 soundcheck Changelog: Output to logfile/different installation modes selectable/different alsa revisions stored on drive
#  Rev: 1.05  10-16-2008 soundcheck Changelog: Bugfix typo "sequencer"
#  Rev: 1.06  10-16-2008 soundcheck Changelog: introducing snddevices script, separate configure&make from make
#                                        install, to avoid corrupt installations if one module compilation/installation fails    
#  Rev: 1.07  10-17-2008 soundcheck Changelog: Using specific kernel headers for driver compilation, taking out soundevices
#  Rev: 1.08  10-17-2008 soundcheck Changelog: script cleanup and introduction of "compile only" (dry run) option, take out kernel-headers option in driver config
#  Rev: 1.09  10-25-2008 soundcheck Changelog: Added libasound2-dev to the package list. It seems that alsalib won't compile properly without it.
#  Rev: 1.11  10-29-2008 soundcheck Changelog: run "make install" on lib befoe compiling alsa-utils 
#  Rev: 1.12  11-12-2008 soundcheck Changelog: alsa-driver 1.018a changelog http://www.alsa-project.org/main/index.php/Changes_v1.0.18_v1.0.18a
#  Rev: 1.13-beta  11-30-2008 soundcheck Changelog: chmod of /devices; 2.6.28 kernel support, restore option, prepared for alsa-tools install
#  Rev: 1.14  12-15-2008 soundcheck Changelog: introduction of latest alsa-driver snapshot-install (option -snap), introduction of help menu, clean up
#  Rev: 1.15  12-16-2008 soundcheck Changelog: added asound.state workaround to get mixer-settings restored 
#  Rev: 1.16  01-21-2008 soundcheck Changelog: added kernel-headers compile option to alsa-driver/ support of 1.0.19

##--------------------------------------------------------------------------------------------------------------------------------------
# Below package variables need to be adapted according to available package ids at  http://www.alsa-project.org/main/index.php/Download 
# otherwise the script execution will fail!
##--------------------------------------------------------------------------------------------------------------------------------------

alsa1019 () {
PACKAGE=1.0.19
DRIVER=alsa-driver-1.0.19
FIRMWARE=alsa-firmware-1.0.19
LIB=alsa-lib-1.0.19
PLUGINS=alsa-plugins-1.0.19
UTILS=alsa-utils-1.0.19
TOOLS=alsa-tools-1.0.19
OSS=alsa-oss-1.0.17
}


#------------Ususally NO Changes to be done below this line-----------------------------------------------------------------------------------------

# script revision
REV="1.16"

#----supported kernels-----------------------------------------------------------------------------------------------------------------

KERNEL1="2.6.24" # Ubuntu kernel family
KERNEL2="2.6.26" # kernel family
KERNEL3="2.6.27" # kernel family
KERNEL4="2.6.28" # kernel family

#TOOLSRC =" ac3dec as10k1 envy24control hdsploader hdspconf hdspmixer \
#	  mixartloader pcxhrloader rmedigicontrol sb16_csp seq sscape_ctl \
#	  us428control usx2yloader vxloader echomixer ld10k1 qlo10k1"
#


SRCDIR=/usr/src          # Sources will be stored here
ALSASRCDIR=${SRCDIR}/alsa  # Packages will be stored here
NOW=`date '+%m%d%y-%H.%M'`
DATE=`date`
LOGFILE=/var/log/AlsaUpgradeRev-$REV-$NOW.log
KERNEL=`uname -r` 
CURRENTPACKAGE=`cat /proc/asound/version | awk '{ print $7 }'`
ALSAPACKS=" alsa-base  alsa-oss  alsa-utils alsa-tools alsa-tools-gui libasound2 libasound2-dev libasound2-plugins aconnectgui "
KERNELPACKS=" `dpkg -l |  awk '{print $2}' | grep -e ${KERNEL}` "



#---------------------------------------------------------------------------------------------------------------------------------

#---You need to have root permissions to run the script----

if [ "$UID" -ne 0  ]
 then
 echo "Must be root to run this script..."
 exit 0
fi  

package () {
echo -n "Choose Alsa Package (1) 1.0.19 default[1]: " 
   read PACK
   case $PACK in
       		""  	) alsa1019 ;;
       		[1]     ) alsa1019 ;;
       		*	) alsa1019 ;;
esac

ALSASRCDIR=${SRCDIR}/Alsa-${PACKAGE}

}


header () {
echo
echo "-------------------------------------------------------------"
echo "-  ${1}"
echo "-------------------------------------------------------------"
echo

}

die () {
  echo "$1"
  exit 1 #error
}

greet () {
clear
echo
echo "--$DATE----Alsa-Upgrade-Script-$REV -----------------" 
echo "-  "
echo "- You'll be upgraded from $CURRENTPACKAGE to $PACKAGE. "
echo "- "
echo "- All script output is routed to $LOGFILE" 
echo "- Run tail -f <logfile> in a seperate terminal to follow the upgrade"
echo "- "
echo "- Reboot your machine afterwards."
echo "- "
echo "- Enjoy - meet you at ubuntuforums.org or diy-audio.com"
echo "- soundcheck"
echo "---------------------------------------------------------------------------"
echo
echo "Upgrade in progress..The process can take up to 15minutes.....Be patient!"

}


bye () {
header "Installation successfully finished!"
header "Your new ALSA version will be loaded after the next reboot..."

}

prep () {

header "Working on following Alsa packages..."
echo "Driver: $DRIVER"
echo "Library: $LIB"
echo "Plugins: $PLUGINS"
echo "Utils: $UTILS"
echo "Firmware: $FIRMWARE"
echo "OSS: $OSS"
#echo "Installing tools: $TOOLS"

#install necessary Linux packages
header "Installing packages required to build ALSA..."

apt-get install -y $ALSAPACKS
apt-get install -y build-essential libsysfs-dev libncurses5-dev gettext python-all-dev xmlto libpulse-dev libspeex-dev
apt-get install -y libavcodec-dev libavformat-dev libavutil-dev libmpeg4ip-dev liba52-0.7.4-dev
apt-get install -y linux-headers-$KERNEL  

}

download () {

cd $SRCDIR

header "Downloading and extracting ALSA packages..."
wget ftp://ftp.alsa-project.org/pub/driver/$DRIVER.tar.bz2 && tar -xjf $DRIVER.tar.bz2 
wget ftp://ftp.alsa-project.org/pub/firmware/$FIRMWARE.tar.bz2 && tar -xjf $FIRMWARE.tar.bz2 
wget ftp://ftp.alsa-project.org/pub/lib/$LIB.tar.bz2 && tar -xjf $LIB.tar.bz2 
wget ftp://ftp.alsa-project.org/pub/plugins/$PLUGINS.tar.bz2 && tar -xvf $PLUGINS.tar.bz2 
wget ftp://ftp.alsa-project.org/pub/utils/$UTILS.tar.bz2 && tar -xjf $UTILS.tar.bz2 
wget ftp://ftp.alsa-project.org/pub/tools/$TOOLS.tar.bz2 && tar -xjf $TOOLS.tar.bz2 
wget ftp://ftp.alsa-project.org/pub/oss-lib/$OSS.tar.bz2 && tar -xvf $OSS.tar.bz2 

rm alsa*.tar.bz2
rm -rf $ALSASRCDIR
mkdir -p $ALSASRCDIR && mv alsa-* $ALSASRCDIR

}


compile () {

header "Prepare for compilation and installation..."

test -d $ALSASRCDIR || die "$ALSASRCDIR not found"

cd $ALSASRCDIR

test -d $DRIVER || die "$DRIVER  not found"
test -d $FIRMWARE || die "$FIRMWARE not found"
test -d $LIB || die "$LIB not found"
test -d $PLUGINS || die "$PLUGINS not found"
test -d $UTILS || die "$UTILS not found" 
test -d $TOOLS || die "$TOOLS not found"
test -d $OSS || die "$OSS not found"


#alsa-driver Note: Driver to be installed before library
header "Compiling drivers..."
cd $ALSASRCDIR/$DRIVER
make clean
./configure --with-kernel=/usr/src/linux-headers-$KERNEL --with-cards=all --with-card-options=all --with-sequencer=yes --with-oss=yes --prefix=/usr || die "$DRIVER configure failed"
#./configure --with-cards=usb-audio,hda-intel,emu10k1,hrtimer,rtctimer,hpet --with-card-options=all --with-sequencer=yes --with-oss=yes --with-kernel=/usr/src/linux --prefix=/usr || die "$DRIVER configure failed"
make || die "$DRIVER make failed"

#alsa-lib
header "Compiling library..."
cd $ALSASRCDIR/$LIB
make clean
./configure --prefix=/usr || die "$LIB configure failed"
make || die "$LIB make failed"

#alsa-plugins
header "Compiling plugins..."
cd $ALSASRCDIR/$PLUGINS
make clean
./configure  --prefix=/usr || die "$PLUGINS configure failed"
make || die "$PLUGINS make failed"

#alsa-firmware
header "Compiling firmware..."
cd $ALSASRCDIR/$FIRMWARE
make clean
./configure --prefix=/usr || die "$FIRMWARE configure failed"
make || die "$FIRMWARE make failed"

## utils will be compiled and installed later on, since lib needs to be installed first

#alsa-oss
header "Compiling OSS..."
cd $ALSASRCDIR/$OSS
make clean
./configure --prefix=/usr || die "$OSS configure failed"
make || die "$OSS make failed"


#alsa-tools if you need any of the tools you need to select and install them one by one manually - look up the respective directory within /usr/src/alsa/alsa-tools*/
#header "Compiling tools..."

#
#cd $ALSASRCDIR/$TOOLS
#for i in $TOOLSRC ; do
# cd $i
# if [ -x ./configure ]; then \
#  make clean   
#  ./configure --prefix=/usr ||  die "$Tools $i configure failed"
#  make ||  die "$Tools $i make failed"
# fi


}

installation () {

header "Installing all modules..."

header "Installing driver..."
cd $ALSASRCDIR/$DRIVER
make install
header "Installing library..."
cd $ALSASRCDIR/$LIB
make install
header "Installing plugins..."
cd $ALSASRCDIR/$PLUGINS
make install
header "Installing firmware..."
cd $ALSASRCDIR/$FIRMWARE
make install
header "Installing OSS..."
cd $ALSASRCDIR/$OSS
make install

#
#alsa-utils need to be compiled after lib installation!!
#

header "Compiling utils..."
cd $ALSASRCDIR/$UTILS
make clean
header "Compiling utils..."
./configure --prefix=/usr 
make
header "Installing utils..."
make install

#
#alsa-tools not yet ready!!
#

#cd $ALSASRCDIR/$TOOLS
#for j in $TOOLSRC ; do
# cd $j
#  header "Installing tool $i"
#  make install
# fi

#
#copy modules to respective kernel!!
#


cd ${ALSASRCDIR}/${DRIVER}/

find ./ -name ''*.ko'' > /tmp/alsa_manifest

header "Copy modules to target directories..."

#This block of code works with 2.6.24-x Ubuntu standard kernels
if [ "`uname -a| grep ${KERNEL1} `" != "" ] ; then
 tar -cv -T /tmp/alsa_manifest -f /lib/modules/`uname -r`/ubuntu/sound/alsa-driver/${DRIVER}.tar
 cd /lib/modules/`uname -r`/ubuntu/sound/alsa-driver
fi

#This block of code works with 2.6.26-x kernels
if [ "`uname -a| grep ${KERNEL2} `" != "" ] ; then
 tar -cv -T /tmp/alsa_manifest -f /lib/modules/`uname -r`/kernel/sound/${DRIVER}.tar
 cd /lib/modules/`uname -r`/kernel/sound/
fi

#This block of code works with 2.6.27 kernels 
if [ "`uname -a| grep ${KERNEL3} `" != "" ] ; then
 tar -cv -T /tmp/alsa_manifest -f /lib/modules/`uname -r`/kernel/sound/${DRIVER}.tar
 cd /lib/modules/`uname -r`/kernel/sound/
fi

#This block of code works with 2.6.28 kernels 
if [ "`uname -a| grep ${KERNEL4} `" != "" ] ; then
 tar -cv -T /tmp/alsa_manifest -f /lib/modules/`uname -r`/kernel/sound/${DRIVER}.tar
 cd /lib/modules/`uname -r`/kernel/sound/
fi

#Extract new modules, overwriting old ones
tar -xvf ${DRIVER}.tar
rm *.tar

depmod -a

chmod a+rw /dev/dsp /dev/mixer /dev/sequencer /dev/midi /dev/snd/*

####alsa-utils patch for asound.state to avoid patching alsa-utils, see below debian patch - ####
##http://svn.debian.org/wsvn/pkg-alsa/trunk/alsa-utils/debian/patches/move_asound_state_to_var.patch?op=file&rev=0&sc=0

cd /var/lib/alsa
rm asound.state
ln -s /etc/asound.state asound.state

}


restorealsa () {
for y in ${KERNELPACKS} ; do
header "Package ${y} will be reinstalled" 
apt-get -y --reinstall install $y
done

for k in ${ALSAPACKS} ; do 
header "Package ${k} will be reinstalled" 
apt-get -y --reinstall install $k
done
depmod -a
}

downloadsnapshot () {
test -d $ALSASRCDIR || die "$ALSASRCDIR not found"
cd $ALSASRCDIR
test -d $DRIVER || die "$DRIVER  not found"
mv $DRIVER $DRIVER.old
wget ftp://ftp.kernel.org/pub/linux/kernel/people/tiwai/snapshot/alsa-driver-snapshot.tar.gz
test -f  alsa-driver-snapshot.tar.gz || die "Download of snapshot didn't work"
tar xvvf alsa-driver-snapshot.tar.gz
mv alsa-driver $DRIVER
rm alsa-driver-snapshot.tar.gz
}

usage() {
    echo "
Usage: $0 [OPTION]...

Available options:
   -di    Download (to /usr/src), compile and install the packages
          This option will compeletely upgrade your ALSA in one step
   -d     Download the packages only
          In case you want to tweak/patch the official packages or 
          you'd like to install the snapshot on top of the official 
          packages prior to compiling and installating them   
   -c     Compilation only 
          Kind of dry-run option to see if the configuration and compilation 
          works
   -i     Compilation and installation of packages
          Sources must exist under /usr/src. Run script with -d or -di options first.
          The option is useful to speed up your installation in case Ubuntu upgrades 
          have overwritten your ALSA installation. It is also useful if you want to 
          keep your patched version or snapshot version, when reinstalling the packages
   -r     Restore ALSA 
          Kernel and all ALSA relevant Ubuntu packages will be restored
          (done by re-installation of relevant packages)
   -snap  Download, compile and install of latest ALSA driver-sources-snapshot 
          Please run script using -d option first. Recommended for troubleshooting.
          (The snapshot is not an offical ALSA release or even pre-release,
           it is the latest snapshot taken from the design-tree!) 
   -h     Help - this page 

Please visit http://ubuntuforums.org/showthread.php?t=962695 
to report any issues you might encounter by using this script.
"
    exit 1;
}


#--- main ----

case "$1" in
  -di)
        header "Alsa will be downloaded and installed"
        package  
        greet
        exec 1>${LOGFILE} 2>&1
        prep
        download
        compile
        installation
        bye     
        ;;
  -d)
        header "Alsa will be downloaded only"
        package
        greet
        exec 1>${LOGFILE} 2>&1
        prep
        download    
        ;;
  -c)
        header "Alsa will be compiled"
        package
        greet
        exec 1>${LOGFILE} 2>&1
        prep
        compile
        ;;

  -i)
        header "Alsa will be compiled and installed"
        package
        greet
        exec 1>${LOGFILE} 2>&1
        prep
        compile
        installation
        bye
        ;;

  -r)   
        header "Alsa will be restored. You'll get a maiden version from Ubuntu repositories"
        exec 1>${LOGFILE} 2>&1
        restorealsa
        ;;
  
  -snap)
        header "The latest Alsa-driver snapshot will be downloaded,compiled and installed"
        package
        greet
        exec 1>${LOGFILE} 2>&1
        downloadsnapshot
        compile
        installation
        bye
        ;;
    
  -h)
        usage
        exit 1
        ;;
  *)
        usage
        exit 1
        ;;
esac

exit 0


##----Script End ----

