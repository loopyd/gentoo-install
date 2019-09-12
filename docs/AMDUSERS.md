# GentoDAD Documentation
## Notice for andgpu Users

### Why is my AMD graphis not currently supported?

I'm not hating on red team.  I'll just jump right into the technical details, as help as needed and a design proposal has been drawn up here.

``amdgpu`` users require dumping their graphics card firmware and add to their kernel and initramfs via the wiki entry here:

[AMDGPU Graphics Card Installation](https://wiki.gentoo.org/wiki/AMDGPU#Installation)

For firmware support for **all graphics cards** into the sustainable future, a firmware dumping facility is required.  This is not currently implimented, but a design proposal has been drawn up fo this feature **and** a hardware detection facility has been brought into existance in ``gentoo-hardwarehelper.sh``.  The repository owner does not own several AMD systems to test with, so support is being left up to the open source community.  To be the most agile about this automatic procedure as I possibly could, I'd like to impliment firmware the user has available already on their chipset.  This has been made possible due to the fact the fundamental core linux filesystem exposes firmware dumping facilities for graphics cards via AMD and NVidia's ``/dev`` and ``/proc`` nodes.  This is a procedure that can be reasonably automated by a purely bash-written execution fork ( ``gentoo-hardwarehelper.sh`` - tada!)

( If you think that is insane, don't look in ``gentoo-automakeconf.sh``'s sed blocks ``:^)`` )

Promising?  Well, have a look at the design proposal.

### Design proposal

GentooDAD automatic firmware loading facility for graphics cards.  This task has been deemed reasonably accomplishable in pure bash.  See ``gentoo-hardwarehelper.sh`` for the GentooDAD lspci/lsusb/cpuinfo lookup table model for an example of a working execution fork for different hardware and here in these scripts for the globbing case blocks as an example of how to use such a facility.  This automatic facility will:

1.  Dump andgpu firmware automatically by enabling AMD firmware read bit on /proc / /dev block device 
2.  Copy the .bin files to /lib/firmware to the proper folder via ``gentoo-hardwarehelper.sh`` execution fork.
3.  Sets the appropriate firmware loading facility options in the kernel .config file with sed in ``gentoo-kernelcompile.sh`` before compiling the kernel.
4.  Install itself as a sys-firmware/linux-firmware post-install portage hook which will copy the files properly to the proper location in ``/lib/firmware`` so that ``emerge @world`` doesn't break the system.

### Want to see working amdgpu support in GentooDAD?

I'm leaving that up to you. You can help this project get amdgpu support by:

1.  Committing to this repository a working sys-firmware/linux-firmware post install hook for amdgpu
2.  Donating a few AMD systems to test with that can ensure a working model which can be expanded upon in future commits for people reporting broken amdgpu configurations.

See [Contribution Guide](CONTRIBUTING.md) section of the documentation for details on how you can help.
