#!/bin/bash

HARDWARE_COMMAND="$1"

# Returns: CPU vendor of system
#     TODO: arm, armhf, armv6, ... (single board computers)
#           mips, bogo_mips, mips3, mips4 (industrial controllers, but why?  can your truck run
#                                          gentoo?  are you an angry person?)
#           powerpc (you're banned, you're SO banned from free ham sandwich day...)
function cpu_vendor () {
	local OS_CPU
	if cat /proc/cpuinfo | grep -i vendor_id | grep -i GenuineIntel >/dev/null ; then
		OS_CPU="intel"
	elif cat /proc/cpuinfo | grep -i vendor_id | grep -i AuthenticAMD >/dev/null ; then
		OS_CPU="amd"
	fi
	echo "${OS_CPU}"
}

# Returns: GPU vendor of system
# TODO: 3dfx, voodo, tandy, via, qxl (qemu/kvm), vbox_display (virtualbox 4+ w/ 3d accel)
#       cga and ecga cards of various flavour....
#       Some retroists have these other old cards, its currently on the backburner.
function gpu_vendors () {
	local OS_GPU
	if lspci -v | grep -i vga | grep -i nvidia >/dev/null ; then
		OS_GPU="nvidia ${OS_GPU}"
	fi
	if lspci -v | grep -i vga | grep -i amd >/dev/null && ! lspci -v | grep -i vga | grep -i amd | grep -i radeon >/dev/null ; then
		OS_GPU="amdgpu ${OS_GPU}"
	fi
	if lspci -v | grep -i 'vga' | grep -i radeon >/dev/null ; then
		OS_GPU="radeonsi ${OS_GPU}"
	fi
	if [[ $(cpu_vendor) =~ .*intel.* ]]; then
		OS_GPU="intel ${OS_GPU}"
	fi
	echo "${OS_GPU}"
}

# Returns: CPU architecture of system
function cpu_arch () {
	local OS_ARCH=
	
	# If you want to see more compatibility, commit to this table.
	# Entires must be in lowercase, here is the syntax of the field
	# match alogirthm:
	#
	#   [field_name],[contains], ...|[target_arch]
	#
	# You can perform multiple matches per target.
	# Entires will try to match using /proc/cpuinfo
	#
	CPU_TABLE=$(echo "amd64|flags,lm,vendor_id,genuineintel;"\
				     "x86|vendor_id,genuineintel;"\
					 "amd64|flags,lm,vendor_id,authenticamd;"\
					 "amd|vendor_id,authenticamd;"\
					 "armhf|model name,armv7;"\
					 "arm|model name,armv6")
	
	OS_CPU=$(IFS=';'
	for CPU_ENTRY in $CPU_TABLE
	do
		CPU_ARCH=$(echo "${CPU_ENTRY}" | cut -d'|' -f1)
		CPU_ENTRY=$(echo "${CPU_ENTRY}" | sed -e "s/^${CPU_ARCH}[|]//g")
		MATCH_RESULT=0
		while [[ "${CPU_ENTRY}x" != "x" ]]; do
			F1=$(echo "${CPU_ENTRY}" | cut -d ',' -f1)
			F2=$(echo "${CPU_ENTRY}" | cut -d ',' -f2)
			if cat /proc/cpuinfo | egrep -i "${F1}" | cut -d':' -f2 2>/dev/null | egrep -i "$F2" >/dev/null ; then
				MATCH_RESULT=1
			else
				MATCH_RESULT=0
			fi
			CPU_ENTRY=$(echo "${CPU_ENTRY}" | sed -e "s/^${F1}[,]${F2}[,]\?//g")
		done
		if [ $MATCH_RESULT -eq 1 ]; then
			echo -n "${CPU_ARCH}"
			break
		fi
	done
	IFS='')
	echo "${OS_CPU}"
}

function sound_vendors() {
	local OS_SOUND=
	
	# If you want to see more compatibility, commit to this table.
	# Entires must be in lowercase, a comma between the module name
	# and end with a semicolon (;)
	#
	# entires will try to match using lspci and lsusb.
	#
	# gentoo wiki: https://packages.gentoo.org/useflags/alsa_cards_emu10k1
	SOUND_TABLE=$(echo "audioscience asi,asihpi;"\
					  "cirrus logic cs4280,cs46xx;"\
					  "cirrus logic cs461,cs46xx;"\
					  "cirrus logic cs462,cs46xx;"\
					  "cirrus logic cs463,cs46xx;"\
					  "sb recon3d,ca0132;"\
					  "darla20,darla20;"\
					  "darla24,darla24;"\
					  "digigram mixart,mixart;"\
					  "digigram pcxhr,pcxhr;"\
					  "digigram vx222,vx222;"\
					  "e-mu 1212m pci,emu1212;"\
					  "e-mu 1616,emu1616;"\
					  "e-mu 1820m pci,emu1820;"\
					  "e-mu aps,emu10k1;"\
					  "echoaudio 3g,echo3g;"\
					  "echoaudio mia,mia;"\
					  "emu10k1x,emu10k1x;"\
					  "ensoniq soundscape,sscape;"\
					  "ess allegro,maestro3;"\
					  "ess maestro3,maestro3;"\
					  "gina20,gina20;"\
					  "gina24,gina24;"\
					  "icensemble ice1712,ice1712;"\
					  "indigo io,indigoio;"\
					  "indigo,indigo;"\
					  "korg 1212,korg1212;"\
					  "layla20,layla20;"\
					  "layla24,layla24;"\
					  "mona,mona;"\
					  "rme digi32,rme32;"\
					  "rme digi96,rme96"\
					  "rme hammerfall dsp audio,hdsp;"\
					  "rme hammerfall dsp madi,hdspm;"\
					  "sega dreamcast,aica;"\
					  "sb 16,sb16;"\
					  "sb audigy,emu10k1;"\
					  "sb awe,sbawe;"\
					  "sb live,emu10k1;"\
					  "tascam us,usb-usx2y;"\
					  "turtle beach maui,wavefront;"\
					  "turtle beach multisound,msnd-pinnacle;"\
					  "turtle beach tropez,wavefront;"\
					  "yamaha ymf,ymfpci;"\
					  "intel hd audio,hda-intel;")
	
	IFS=';'
	OS_SOUND=$(for SOUND_ENTRY in $SOUND_TABLE
	do
		SOUND_GREP=$(echo -n "${SOUND_ENTRY}" | cut -d',' -f1 | awk '{$1=$1};1')
		SOUND_MODULE=$(echo -n "${SOUND_ENTRY}" | cut -d',' -f2 | awk '{$1=$1};1')
		if lspci | egrep -i "$SOUND_GREP" >/dev/null || lsusb | egrep -i "$SOUND_GREP" >/dev/null ; then
			echo -n "$SOUND_MODULE "
		fi
	done)
	IFS=''
	echo "${OS_SOUND}"
}

#- ARGUMENT VALIDATION -#
if [[ "$HARDWARE_COMMAND x" == " x" ]]; then
	>&2 echo 'No hardware command specified, please check your gentoo-hardwarehelper.sh arguments'
fi

#- RUN THE COMMAND -#
case "$HARDWARE_COMMAND" in
	cpu_arch)
		cpu_arch
		;;
	cpu_vendor)
		cpu_vendor
		;;
	gpu_vendors)
		gpu_vendors
		;;
	sound_vendors)
		sound_vendors
		;;
	*)
		>&2 echo 'Invalid hardware command specified: ${HARDWARE_COMMAND}, please check your gentoo-hardwarehelper.sh arguments.'
		;;
esac
