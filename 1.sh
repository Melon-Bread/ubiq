#!/bin/bash

echo "_____/\\\\________/\\\\___/\\\\\\\\\\\\\____/\\\\\\\\\\\\______/\\\\\\_________"        
echo  "____\/\\\\_______\/\\\\__\/\\\/////////\\\_\/////\\\\///____/\\\\\/\\\\\\______"     
echo   "____\/\\\\_______\/\\\\__\/\\\_______\/\\\_____\/\\\\_____/\\\\//\////\\\\\____"     
echo    "____\/\\\\_______\/\\\\__\/\\\\\\\\\\\\\\\_____\/\\\\____/\\\\\______\//\\\\___"   
echo     "____\/\\\\_______\/\\\\__\/\\\/////////\\\_____\/\\\\___\//\\\\\______/\\\\____"  
echo      "____\/\\\\_______\/\\\\__\/\\\_______\/\\\_____\/\\\\____\////\\\\\/\\\\\/_____"
echo       "____\//\\\\______/\\\\___\/\\\_______\/\\\_____\/\\\\______\////\\\\\\//_______"
echo        "_____\///\\\\\\\\\\//____\/\\\\\\\\\\\\\/___/\\\\\\\\\\\\_____\///\\\\\\\\_____"
echo         "_______\//////////_______\/////////////____\////////////________\////////______"

#### WELCOME!, Using the right hardware?

echo "Thank you for supporting the Ubiq network by running a node!"
echo
echo "This script is currently intended to handle Ubiq node setup for the following systems..."
echo
echo "...Raspberry Pi 2B, 3B, 3B+, 4B (or any Pi with >1GB of ram); running Raspbian or Raspbian Lite"
echo
echo "...Odroid C2 & Odroid XU4; running Armbian"
echo
echo "...Asus Tinkerboard, Tinkerboard S; running Armbian"
echo
echo "...Libre LePotato; running Armbian"
echo
read -p "Press enter to continue to setup."

#### Any hardware found to be compatible will be defined below...

hardware=unknown
if grep -q Raspberry < /proc/device-tree/model
then
	hardware=RaspberryPi
elif grep -q Tinker < /proc/device-tree/model
then
	hardware=Tinkerboard
elif grep -q Odroid XU4 < /proc/device-tree/model
then
	hardware=OdroidXU4
elif grep -q ODROID-C2 < /proc/device-tree/model
then
	hardware=OdroidC2
elif grep -q Libre < /proc/device-tree/model
then
	hardware=LibreLePotato
fi
clear
#### Let's make some helpful changes and additions...

if [ hardware=RaspberryPi ]
then
	echo
 	echo "Your new user will be called 'node'."
	echo
	echo "You will now be prompted to set a password for your new user..."
	echo
	echo "When prompted to fill in personal details, you may leave it blank." 
	echo
	echo "Welcome to Ubiq!"
  	echo
  	read -p "Press enter to continue..."
 	sudo adduser node
  	sudo usermod -G sudo node
  	sudo sed -i -e "s/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/" /etc/dphys-swapfile
  	sudo /etc/init.d/dphys-swapfile restart
  	sudo apt update -q
  	sudo apt upgrade -y -q
  	sudo apt dist-upgrade -q
  	sudo apt autoremove -y -q
  	sudo apt install ntp -y -q
  	sudo apt install htop -q
  	sudo apt install supervisor -y -q
  	sudo apt install git -y -q
  	sudo mkfs.ext4 /dev/sda -L UBIQ
  	sudo mkdir /mnt/ssd
  	sudo mount /dev/sda /mnt/ssd
	echo "/dev/sda /mnt/ssd ext4 defaults 0 0" | sudo tee -a /etc/fstab
elif [ hardware!=RaspberryPi ]
then
  	echo "If you are running Armbian you created the user called 'node' and set it's password on first boot."
  	echo "You also should have set up the network connection & adjusted timezone settings."
  	echo
  	echo "When the setup process is complete, your system will restart."
  	echo
  	echo "Welcome to Ubiq!"
  	echo
	sleep 15s
  	sudo apt update -q
	sudo apt upgrade -y -q
  	sudo apt dist-upgrade -q
  	sudo apt autoremove -y -q
  	sudo apt install ntp -y -q
  	sudo apt install htop -q
  	sudo apt install supervisor -y -q
  	sudo apt install git -y -q
  	sudo mkfs.ext4 /dev/sda -L UBIQ
  	sudo mkdir /mnt/ssd
  	sudo mount /dev/sda /mnt/ssd
  	echo "/dev/sda /mnt/ssd ext4 defaults 0 0" | sudo tee -a /etc/fstab
fi

#### Let's set up our Supervisor conf file so our node will keep itself online!

sudo touch /etc/supervisor/conf.d/gubiq.conf
echo "[program:gubiq]" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "command=/usr/bin/gubiq --verbosity 3 --rpc --rpcaddr "127.0.0.1" --rpcport "8588" --rpcapi "eth,net,web3" --maxpeers 100 --ethstats "temporary:password@ubiq.darcr.us"" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "user=node" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "autostart=true" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "autorestart=true" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "stderr_logfile=/var/log/gubiq.err.log" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "stdout_logfile=/var/log/gubiq.out.log" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo
clear
#### Maybe you're in it for the glory. You can put your name on the wall....or not.

read -p "Would you like to list your node on the Ubiq Network Stats Page? This will make your node name & stats available on "https://ubiq.darcr.us'. (y/n)" CONT
if [ "$CONT" = "y" ]; then
  	echo "Type a name for your node to be displayed on the Network Stats website, then press Enter."
	echo
  	read varname
  	sudo sed -i -e "s/temporary/$varname/" /etc/supervisor/conf.d/gubiq.conf
  	echo
  	echo "Your node will be named $varname"
  	echo
  	sleep 4	
  	echo "Enter the secret to list your node on the Ubiq Stats Page, then press Enter."
  	echo
  	read varpass
  	sudo sed -i -e "s/password/$varpass/" /etc/supervisor/conf.d/gubiq.conf
  	echo
else
  	echo "Your node will not be listed on the public site"
fi
 
#### If you are using a Raspberry Pi, SSH is not enabled by default like it is on Armbian.

if [ hardware=RaspberryPi ]
then
	read -p "Would you like to enable SSH on this system? This will allow you to log in and operate your node from another machine on your network. (y/n)" CONT
if [ $CONT = y ]
then
  	sudo raspi-config nonint do_ssh 0
fi
else
  	echo "SSH will not be enabled on this system.  To enable SSH in the future, you can do so in the raspi-config menu."
  	sleep 8
fi

#### Got lot's of space on that SSD? Sync it all!  Data diet? Use Fast mode and only grab the vital bits...

echo
read -p "Would you like to set your node to "full" sync mode?  This will take more storage space and sync will take longer. (y/n)" CONT
if [ "$CONT" = "y" ]; then
  sudo sed -i -e "s/--maxpeers 100/--maxpeers 100 --syncmode "full" --gcmode "archive"/" /etc/supervisor/conf.d/gubiq.conf 
else
  echo "Your node will sync in 'fast' mode"
  sleep 4
fi

#### You have the option of letting your system re-fetch gubiq binaries once a month.  If there is an update, it'll sort itself out.

read -p "Would you like to allow your node to auto-fetch the gubiq binaries once per month?  This will keep your node on the latest release without your interaction. (y/n)" CONT
if [ "$CONT" = "y" ]
then
  cd
  sudo touch auto.sh
  echo "#!/bin/bash" | sudo tee -a auto.sh
  echo "" | sudo tee -a auto.sh
  echo "wget https://raw.githubusercontent.com/maaatttt/ubiq/master/gu.sh" | sudo tee -a auto.sh
  echo "chmod +x gu.sh" | sudo tee -a auto.sh
  echo "./gu.sh" | sudo tee -a auto.sh
  sudo chmod +x auto.sh
  echo "@monthly ./auto.sh" | crontab -
else
  echo "Your node will NOT automatically update gubiq.  All updates must be handled manually!"
  sleep 8
fi

#### Your system will pick the correct binary file to download based on how it was defined at the beginning of this script.

if [ hardware=RaspberryPi ]
then
  wget https://github.com/ubiq/go-ubiq/releases/download/v3.0.1/gubiq-linux-arm-7
  sudo cp ./gubiq-linux-arm-7 /usr/bin/gubiq
elif [ hardware=Tinkerboard ]
then
  wget https://github.com/ubiq/go-ubiq/releases/download/v3.0.1/gubiq-linux-arm-7
  sudo cp ./gubiq-linux-arm-7 /usr/bin/gubiq
elif [ hardware=OdroidXU4 ]
then
  wget https://github.com/ubiq/go-ubiq/releases/download/v3.0.1/gubiq-linux-arm-7
  sudo cp ./gubiq-linux-arm-7 /usr/bin/gubiq
elif [ hardware=OdroidC2 ]
then
  wget https://github.com/ubiq/go-ubiq/releases/download/v3.0.1/gubiq-linux-arm64
  sudo cp ./gubiq-linux-arm64 /usr/bin/gubiq
elif [ hardware=LibreLePotato ]
then
  wget https://github.com/ubiq/go-ubiq/releases/download/v3.0.1/gubiq-linux-arm64
  sudo cp ./gubiq-linux-arm64 /usr/bin/gubiq
fi

#### Lets put our stuff where it belongs and give it the power to do it's job.

sudo cp ./gubiq-linux-arm-7 /usr/bin/gubiq
sudo chmod +x /usr/bin/gubiq
sudo mv /home/node /mnt/ssd
sudo ln -s /mnt/ssd/node /home

#### ITS THE FINAL COUNTDOWWWWNNNNNNN

secs=$((1 * 8))
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done
sudo reboot