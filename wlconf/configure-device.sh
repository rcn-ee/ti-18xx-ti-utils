#!/bin/sh
# Script to run on the target to configure the wl18xx-conf.bin file to match the device capabilities and 
# antennae configuration. Takes as an argument the device name - wl1801,wl1805, wl1831, wl1835


binary_name="/lib/firmware/ti-connectivity/wl18xx-conf.bin"

# logic to be followed here is that if a device has a parameter with a value over 1 then there is a choice 
# that has to be made by user as to whether the feature will be used.
# eg a 2.4GHz MIMO capable device may only have a single antenna fitted
# assume that as 2.4GHz does not pass WFA test with 40MHz channels then we disable it for ALL devices
if [ $# -eq 1 ]; then
  case $1 in
    wl1801) number_2_4G_antenna=1; number_5G_antenna=0;ht40=0
      ;;
    wl1805) number_2_4G_antenna=1; number_5G_antenna=0;ht40=0
      ;;
    wl1807) number_2_4G_antenna=2; number_5G_antenna=1;ht40=0
      ;;
    wl1831) number_2_4G_antenna=2; number_5G_antenna=0;ht40=0
      ;;
    wl1835) number_2_4G_antenna=2; number_5G_antenna=0;ht40=0
      ;;
    wl1837) number_2_4G_antenna=2; number_5G_antenna=1;ht40=0
      ;;
   *) echo "Unknown device";exit ;;
  esac
fi

# For all MODULE devices low band component needs to be set to 0x2
low_band_component=0x2

# and board_type is 4
board_type=4

# ask if one or two antennae will be fitted in 2.4GHz band
NUM_ANTENNAE=-1;
while [ $NUM_ANTENNAE -eq -1 ]
do
  if [ $number_2_4G_antenna -gt 1 ]; then
        echo "Device is capable of supporting 2 antenna in 2.4Ghz band"
	read -p 'how many antennae are fitted? [1/2] : ' NUM_ANTENNAE
	case $NUM_ANTENNAE in
	    "1") number_2_4G_antenna=1;;
	    "2") number_2_4G_antenna=2;;
	    *)  echo "Please enter 1 or 2";NUM_ANTENNAE=-1;continue;;
        esac
  else
     # set to required number to exit loop
     NUM_ANTENNAE=$number_2_4G_antenna;
  fi
done

# ask if a 5GHz antenna will be fitted
NUM_ANTENNAE=-1;
while [ $NUM_ANTENNAE -eq -1 ]
do
  if [ $number_5G_antenna -eq 1 ]; then
        echo "Device is capable of supporting 5GHz"
	read -p 'how many 5GHz antennae are fitted? [0/1] : ' NUM_ANTENNAE
	case $NUM_ANTENNAE in
	    "0") number_5G_antenna=0;;
	    "1") number_5G_antenna=1;;
	    *)  echo "Please enter 0 or 1";NUM_ANTENNAE=-1;continue;;
        esac
  else
     # set to required number to exit loop
     NUM_ANTENNAE=$number_5G_antenna;

  fi
done

# ask if SISO40 should be enabled
SISO=-1;
while [ $SISO -eq -1 ]
do
 if [ $ht40 -eq 1 ]; then
        echo "Device is capable of supporting SISO40"
	read -p 'should it be enabled? [y/n] : ' SISO
	case $SISO in
	    "n") ht40=0;SISO=0;;
	    "N") ht40=0;SISO=0;;
	    "y") ht40=1;SISO=0;;
	    "Y") ht40=1;SISO=0;;
	    *)  echo "Please enter y or n";SISO=-1;continue;;
        esac
 else
    # set to required number to exit loop
    SISO=$ht40;
 fi
done


# Now check if a wl18xx-conf.bin file already exists and ask if a new one should be created from .ini
# ensure we are in correct directory for wlconf
MODIFY_CONF=0
modify_conf_file=0
rmmod wlcore_sdio

cd /usr/sbin/wlconf

if [ -e $binary_name ]; then
        echo "A wl18xx-conf.bin file already exists, do you want to modify it (y) or generate a clean one from .ini (n)"
	read -p 'modify it? [y/n] : ' MODIFY_CONF
	case $MODIFY_CONF in
	    "n") modify_conf_file=0;;
	    "N") modify_conf_file=0;;
	    "y") modify_conf_file=1;;
	    "Y") modify_conf_file=1;;
	    *)  echo "Please enter y or n: ";MODIFY_CONF=0;continue;;
        esac
fi

ini_file_name="official_inis/WL1835MOD_INI.ini"
INPUT_NAME=0

if [ $modify_conf_file -eq 0 ]; then 
   if [ -e $ini_file_name ]; then
      echo "Create clean wl18xx-conf.bin from $ini_file_name"
   else
      echo "$ini_file_name does not exist, "
      read -p 'enter another ini file name: ' INPUT_NAME
      ini_file_name=$INPUT_NAME
      if [ ! -e $ini_file_name ]; then
        echo "$ini_file_name does not exist in /usr/sbin/wlconf"
        exit 1
      fi
   fi
   
   # Now create clean file
   ./wlconf -o $binary_name -I $ini_file_name
fi   



#finally write values to binary
./wlconf -i $binary_name -o $binary_name -s wl18xx.phy.number_of_assembled_ant2_4=$number_2_4G_antenna
./wlconf -i $binary_name -o $binary_name -s wl18xx.phy.number_of_assembled_ant5=$number_5G_antenna
./wlconf -i $binary_name -o $binary_name -s wl18xx.ht.mode=$ht40
./wlconf -i $binary_name -o $binary_name -s wl18xx.phy.low_band_component=$low_band_component
./wlconf -i $binary_name -o $binary_name -s wl18xx.phy.board_type=$board_type



#reinsert ko
modprobe wlcore_sdio

