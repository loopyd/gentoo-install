# GemtooDAD
This is Loopy's customized Gentoo installer.  Use it at your own risk.  It has been uploaded to github for your observation and lurning purposes.

This script is not a fully working script.  But was designed with one computer in mind.  You can modify it to your heart's contennt.

Please do offer any forks with improvements to my code, I would appreciate them !

If you want to modify this code, you can do so under the DBAD License:  https://dbad-license.org/

----
## Customization

This script obviously doesn't work with your system.  So some configuration options have been added for you.  The contents of this repository contain a working model for a very particular setup.  To use it for yourself, you will need to customize it.

You'll need to perform the following steps from a working machine:

1.  Clone this repository
2.  Follow the rest of the customization guide to tailer the installer to your system.
3.  Run the script and keep tweaking till it works !

Before the hate mail comes, the fun of Gentoo is tweaking and messing around with Linux.
I have done a lot for you.  The rest is **up to you!**

### Customizing the package configuration

**Editing the injected configuration**
To edit the configuration, edit the here documents ( ``cat<<'EOF'`` ) lines in ``gentoo-injectconfig.sh``

> **Note**: Modifying the here documents that contain variable expansion is touchy.  They look like
> ``cat <<EOFDOC`` or similar (notice the lack of single quotation marks.  These are automatic heredocs
> so do so at your own risk.

### Adding your own custom kernel

To add your own custom kernel configuration, follow these steps:

1.  Replace the contents of kernel-config.txt with your own.
2.  Modify ``gentoo-config.sh`` underneath the initramfs section accordingly to load the kernel modules you need.
- ``DRACUT_KVER`` - Kernel version
- ``DRACUT_MODULES`` - Dracut modules which should load in addition to your host's configuration.
- ``DRACUT_KERNEL_MODULES`` - Modules from your kernel which should load accordingly.
3.  Replace according emerge line in ``gentoo-chroot-innerscript.sh`` to install the sources for the kernel you want to compile.  The default is ``ck-sources`` for **Linux-CK** for optimized desktop systems.

> **NOTE**: This script does no sanity checking whatsover, please make sure that your kernel compiles without
> help first !

----
## Contributions

You know, developing, testing, and maintaining a big project like this is hard.  Did you know the accumulated unit test time
for this script is just a little over **3 months**?  Would you like to make a contribution to help make this script better?

This section of the readme details how you can help.

### Want to contribute ?

Fork this repository, and submit a **Merge Pull Request** .

> **TIP:** Please make your changes very clear.  DBAD - You know what that means.

### Want to donate ?

There is no obligation to donate.  However, development of this script did take several months.  If you'd like to, the offer is always open.

**Thank You!**

[Developer PayPal.Me](https://www.paypal.com/paypalme/my/profile?locale.x=en_US&country.x=US)
----
