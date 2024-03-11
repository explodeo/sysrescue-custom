# SystemRescue Customizer

This repository is a custom supplement to make building certain features in a SystemRescue bootable ISO a lot easier.
The SystemRescue documentation is very vast with not a huge amount of examples for all of the major customization options. This is supposed to fill that hole.

### Disclosure

I did not develop SystemRescue or the `sysrescue-customize` script in this git, nor do I have attribution to it other than freely using it per the GPLv3 license. Please see below for source material and references:
- SystemRescue Homepage: https://www.system-rescue.org/
- Sysrescue-Customize: https://www.system-rescue.org/scripts/sysrescue-customize/
- SystemRescue GitHub: https://gitlab.com/systemrescue/systemrescue-sources

Please support the official developers.

***

### Directory Structure

This repository uses the `build-sysrescue-iso` script which reduces the number of commands you have to write to build SRMs or customizations into the SysRescue image. 

This repo uses the following structure which holds the minimum necessary files/directories to make the build script work: 
- `SYSRESCUE.iso`: The SystemRescue ISO you want to customize
- `SYSRESCUE.iso.sha512`: A SHA512 hash used to verify the SystemRescue ISO
- `extracted-iso`: Empty directory which should be used if you are building using the manual process
- `output-dir`: The default directory for storing an output custom SystemRescue ISO 
- `preprocessing`: directory containing bash scripts for modifying variables using the `CHANGEME` prefix in configurations and scripts
    - `custom`: A file which contains default values for all `CHANGEME` instances
    - `defaults`: A file which contains custom values for all `CHANGEME` instances (overwrites default configs)
- `srm-dir`: A directory used **in manual mode** to store SRMs built from the `srm-source` directory.
- `work-dir`: A directory used by the `sysrescue-customize` script for temporary files
- `recipe-dir`: Directory containing an automated build "recipe" per the SystemRescue official docs.
    - `iso_delete`: Contains paths to dirs/files to delete. For example, put `.ssh` to recursively delete all `.ssh` folders in the iso. Use full paths if possible.
    - `iso_add`: Directory containing files/dirs to copy or overwrite in the ISO image. Currently limited to `sysrescue.d` and `autorun`. Use SRMs to modify folders like `/opt`
        - `autorun`: Directory containing autorun scripts once the ISO boots. Scripts in this folder can be named anything. 
          - `autorun1`: An example autorun script that sets the IP, hostname, and assigns a new root SSH key on boot. `Preprocessing` may be used to change these.
        - `sysrescue.d`: Directory containing YAML files (must use the `.yaml` extension) which overwrites the default SystemRescue configuration.  
            - `500-settings.yaml`: An example YAML file that causes SRMs to load, sets a US keyboard, and sets the DVD to boot into RAM with the GUI up. `Preprocessing` will cause a root password to be set here
    - `iso_patch_and_script`: Directory containing files to patch and scripts to run. Refer to the [Official Docs](https://www.system-rescue.org/scripts/sysrescue-customize/) on how to do this.
    - `build_into_srm`: The directory containing SRMs built from the `srm-source` directory.
- `srm-source`: Directory used by the automation script containing files to build into SRMs
    - `packages`: Directory containing a file structure used to store Pacman packages for updating the ISO. ***THIS IS NOT YET SUPPORTED VIA AUTOMATION***
    - `static`: Directory containing the file structure for files/plugins/scripts to add or overwrite in the booted file system. This directory acts as the `/` directory in a squashfs.

### Customizing SRMs

System Rescue Modules (SRMs) are squashfs images that overlay the root filesystem of a booted SystemRescue system. 

To have the build script automatically compile these, create a directory structure in `./srm-source/static` to put your static files.

#### Example:
```
./srm-source
└───static
    ├───etc
    │       hosts
    ├───opt
    │       example.sh
    └───usr
        └───bin
                serial.sh
```
This example will overwrite `/etc/hosts` and create the scripts `/opt/example.sh` and `/usr/bin/serial.sh`.

Note that overwriting the hosts file is easier here since you only have to copy/paste the file. Do not configure it in the `sysrescue.d` YAML files.

### Autorun Scripts

Autorun scripts can be used to dynamically change the SystemRescue environemnt or automate starting commonly-used processes on every boot.

You can create as many autorun scripts with unique filenames. Place autorun scripts in the `./recipe-dir/iso_add/autorun` folder.
#### Example:
```
./recipe-dir
└───iso_add
    ├───sysrescue.d
    │       ...
    └───autorun
            autorun1
```

The `autorun1` example script is shown below:

```sh
#!/bin/sh
nmcli con mod "Wired connection 1" ipv4.address CHANGEME-IP ipv4.method manual
hostname CHANGEME-HOSTNAME
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -q -N '' && cat /root/.ssh/id_rsa >> /root/.ssh/authorized_keys
```

This script uses `preprocessing` to set a default IP address and hostname. Since the SSH daemon is automatically started in the default SystemRescue image, a root SSH key is regenerated on every reboot.

### YAML Customization

YAML configurations are used for different scopes of configuration for the SystemRescue environment. YAML files are loaded in lexicographic order. Boot parameters can overwrite YAML file configurations as well. 

YAML configuration files are stored in `./recipe-dir/iso-add/sysrescue.d/` in this repo. You can add more YAML files, or overwrite the `100-defaults.yaml` entirely.

####Example:
```
./recipe-dir
└───iso_add
    ├───sysrescue.d
    │       200-castore.yaml
    │       500-settings.yaml
    └───autorun
            autorun1
```

For scope customizations, see the following documentation:
- [Global Scope](https://www.system-rescue.org/manual/Configuring_SystemRescue/)
- [SysConfig Scope](https://www.system-rescue.org/manual/Configuring_SystemRescue_sysconfig/)
- [AutoRun Scope](https://www.system-rescue.org/manual/Run_your_own_scripts_with_autorun/)
- [AutoTerminal](https://www.system-rescue.org/manual/autoterminal_scripts_on_virtual_terminal/)
- [GUI Autostart](https://www.system-rescue.org/manual/gui_autostart_Start_programs_on_graphical_desktop/)
- [Boot Options](https://www.system-rescue.org/manual/Booting_SystemRescue/)

Note that although you can use the YAML to autorun scripts, it is *a lot* easier to just create scripts in `./recipe-dir/iso_add/autorun/*`

### Preprocessing Variables

TODO: I haven't figured this out yet

***

## System Requirements

The `build-sysrescue-iso.sh` script is used for the automatic build process and requires a few requirements to work:
- The following directories exist:
  - s
- The `sysrescue-customize` script is stored in the same folder as `build-sysrescue-iso.sh`
- The `SystemRescue.iso` image is stored in the same folder as `build-sysrescue-iso.sh`
- The user running the build script is `root`. If the check is removed, make sure the user can create loopback devices to mount the original SystemRescue ISO.
- The following packages are installed (RHEL 9): 
  - `xorriso`
  - `squashfs-utils`
  - `patch`

Usage is below:

```YAML
usage: ./build-sysrescue-iso.sh --src <SYSRESCUE.ISO> [--dest <OUTPUT.ISO>] 
                                [--preprocess] [--add-srm] [--add-packages]
                                [--verify-hash <SHA512FILE>]
                                [--help|-h]
Required:
    --src <SYSRESCUE.ISO>   Path to the systemrescue ISO to customize (original is unmodified)

Optional Arguments:
    --dest <OUTPUT.ISO>     Path and name of the ISO to output (will overwrite!)
    --preprocess            Configures all CHANGEME items using variables defined in ./preprocessing/custom.sh
    --add-srm               Creates SRM from ./srm-source/ and puts it into ./srm-dir before bulding the iso
    --add-packages          TBD (builds rpms into SRM and adds autorun script for installing them)
    --verify-hash           Verifies systemrescue hash against a file containing its sha512sum
    --help|-h               Print this help and exit
```

***
***