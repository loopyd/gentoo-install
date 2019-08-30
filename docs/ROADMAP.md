# GentooDAD Documentation
## Roadmap

### Roadmap

This is a developer's tree of implimented features.  If you want a text-representation of what's going on in my repository, check this file ever so often.

```
	@ bootloader
		@ grub 
			+ x86_64-efi as target platform 
			- x86-efi as target platform
			- armhf as target platform (?) raspberry pi
		- efi stub
			- none implimented
		- kernel as uefi binary
			- none implimented
			
	+ initramfs
		+ dracut
			+ user module config
			+ user kernel module config
			+ firmware loading
	
	@ graphis (X)
		+ nvidia
			+ done
		- amd
			- not implimented
		- radeon
			- not implimeted
		- user_config
			- not implimented (for custom graphics, virtualbox, qemu, etc)

	@ sound:
		@ alsa
			@ beta, works somewhat, will properly load firmware into dracut initramfs
			  for cards that need it
		@ pulseaudio
			@ beta, works somewhat with kde. sound works with KDE control panel.  
			  not automatic.
		- jack
			- not implimented

	@ installer features
	
		@ make.conf autogenerator
			@ COMMON_FLAGS automatic - beta, hardcoded
			+ MAKEOPTS automatic
			+ CPU_FLAGS_X86 automatic
			@ VIDEO_CARDS automatic - beta
			@ ALSA_CARDS - beta, hardcoded
			@ USE flags - beta, hardcoded
		
		? portage wrapper
			? some tests where done, but nothing reliable yet.
	
		+ script wrapper
			+ done
	
		@ debugger
			@ beta, does not save log file for stdout, stderror thanks to new
			exception handler...
	
		@ bootkicker
			@ beta, requires user to log in as root, not fully unattended
		  	  requires implimentation of agetty backup/hack.  error handler
			  needs to be implimented post-chroot reboot.
			
	@ guis:
		+ kde plasma 5
			+ done
		- kde wayland
			@ partial, needs extra config
		- x session
			@ partial, needs manual monitor orientation config
		- gnome
			- not implimented
		- xfce
			- not implimented
	
	@ display managers:
		+ sddm
			+ done
		- xdm
			- not implimnted
		- lightdm
			- not implimented
```