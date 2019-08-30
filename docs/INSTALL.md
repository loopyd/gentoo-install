# GentoDAD Documentation
## Installation Guide

To use this script chain, and install gentoo using **GentoDAD**, follow this guide.

### Creating Gentoo Installation Media

Download a **Gentoo Linux Live Image** -> [link](https://www.gentoo.org/downloads/)

Use **Rufus** in ISO Image Mode.  Use UEFI / Non-CSM mode for the best compatibility with newer systems -> [link](https://rufus.ie/)

### Motherboard BIOS Configuration

When booting the system, you must make the following changes in BIOS:

- Keep **APCM/APCI** turned on.
- Turn off **CSM** to enable a pure UEFI boot environment.
> **Tip for Gigabyte motherboard owners:** - My motherboard requires **Enable Windows 8/10 Features** set to **Winows 8/10** and __NOT__ 
> **Other Os** to be able to turn **CSM** completely off.  This is confusiong, but that's Gigabyte for you.
- **USB** should be set to **XHCI hand-off** mode for Linux.

### Booting the installation media

To boot the installation media, insert the USB stick into your computer and power it on.
You may need to press **DEL** or **F12** dependent on your BIOS revision to select your boot device.

> **Problems:** If you experience problems booting (hanging at boot on udev), try disabling **Kernel Modesetting** from the grub menu that appears
> underneath the **Boot Options** menu.  This will forge graphics to a legacy mode for NVidia or AMD Graphics cards without drivers.

### Network Setup

You'll need to open an SSH connection to upload the script chain.

When reaching the prompt, enter the following commands:
   
   rc-service sshd start
   echo -e "yourpassword\nyourpassword" | passwd

You will need the IP address of the machine's main network adapter, you can first test your internet connection by running:

    ping -c3 google.com

If you have success, your machine's IP address can be obtained by running the following command:

	ifconfig

If you do not have a network configuration (ping fails), you will have to follow the [Guide](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking) on the Gentoo Wiki

You will need an **SSH client** to execute the script.

You can use **PuTty** -> [link](https://www.chiark.greenend.org.uk/~sgtatham/putty/) as an SSH client.

**Test your connection** with your SSH client at the IP address you obtained before continuing.

### Uploading the files

Follow the [customization guide](CUSTOM.md).

After having done so, **Upload** the ``.sh`` files to the host machine.

You can use **WinSCP** to do this -> [link](https://winscp.net/eng/download.php)

Your connetion type should be: **SSH**
Enter your **Username** and your **Password** into the fields
**Save** your settings as a profile, then **Connect**

WinSCP functions just like an FTP clinet.  The files should be transfered to the **/root** folder.

### **Run the installer**

You can run the installer by **Starting an SSH session**, and logging in as ``root`` with the password you set earlier.

The following commands should be issued after uploading the files.
	cd /root
	chmod +x ./*.sh
	./setup.sh
	
Hope for the best!  If you've made a configuration error, the script will exit and show you some output that may help.
