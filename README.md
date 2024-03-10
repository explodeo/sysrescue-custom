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
- **SYSRESCUE.iso**: The SystemRescue ISO you want to customize
- **SYSRESCUE.iso.sha512**: A SHA512 hash used to verify the SystemRescue ISO
- **extracted-iso**: Empty directory which should be used if you are building using the manual process
- **output-dir**: The default directory for storing an output custom SystemRescue ISO 
- **preprocessing**: directory containing bash scripts for modifying variables using the `CHANGEME` prefix in configurations and scripts
    - **custom**: A file which contains default values for all `CHANGEME` instances
    - **defaults**: A file which contains custom values for all `CHANGEME` instances (overwrites default configs)
- **srm-dir**: A directory used **in manual mode** to store SRMs built from the `srm-source` directory.
- **work-dir**: A directory used by the `sysrescue-customize` script for temporary files
- **recipe-dir**: Directory containing an automated build "recipe" per the SystemRescue official docs.
    - **iso_delete**: Contains paths to dirs/files to delete. For example, put `.ssh` to recursively delete all `.ssh` folders in the iso. Use full paths if possible.
    - **iso_add**: Directory containing files/dirs to copy or overwrite in the ISO image. Currently limited to `sysrescue.d` and `autorun`. Use SRMs to modify folders like `/opt`
        - **autorun**: Directory containing autorun scripts once the ISO boots. Scripts in this folder can be named anything. 
          - **autorun1**: An example autorun script that sets the IP, hostname, and assigns a new root SSH key on boot. `Preprocessing` may be used to change these.
        - **sysrescue.d**: Directory containing YAML files (must use the `.yaml` extension) which overwrites the default SystemRescue configuration.  
            - **500-settings.yaml**: An example YAML file that causes SRMs to load, sets a US keyboard, and sets the DVD to boot into RAM with the GUI up. `Preprocessing` will cause a root password to be set here
    - **iso_patch_and_script**: Directory containing files to patch and scripts to run. Refer to the [Official Docs](https://www.system-rescue.org/scripts/sysrescue-customize/) on how to do this.
    - **build_into_srm**: The directory containing SRMs built from the `srm-source` directory.
- **srm-source**: Directory used by the automation script containing files to build into SRMs
    - **packages**: Directory containing a file structure used to store Pacman packages for updating the ISO. ***THIS IS NOT YET SUPPORTED VIA AUTOMATION***
    - **static**: Directory containing the file structure for files/plugins/scripts to add or overwrite in the booted file system. This directory acts as the `/` directory in a squashfs.

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

You can create as many autorun scripts with unique filenames. In this repo, the following example script named `autorun1` is used:

```sh
#!/bin/sh
nmcli con mod "Wired connection 1" ipv4.address CHANGEME-IP ipv4.method manual
hostname CHANGEME-HOSTNAME
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -q -N '' && cat /root/.ssh/id_rsa >> /root/.ssh/authorized_keys
```

This script uses `preprocessing` to set a default IP address and hostname. Since the SSH daemon is automatically started in the default SystemRescue image, a root SSH key is regenerated on every reboot.

### YAML Customization

### Preprocessing Variables

***

## Building the ISO 















***
***
***
***
### Some other notes below; Going to remove these.
When executing `sysrescue-customize`, run it the following way:
```sh
$ ./sysrescue-customize --auto -s <ISO_FILE> -d ./extracted-iso -r ./recipe-dir -w work-dir -o
```

the `srm-dir` should not be used unless you plan on manually building sysrescue.

the `work-dir` is solely used for processing and should not be touched. feel free to `rm -rf` everything in that directory between builds as the `sysrescue-customize` script only uses it to manage files during runtime.
