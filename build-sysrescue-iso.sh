#!/bin/sh

echo "WARNING: There are currently no safety checks in this script. Use at your own peril!"
sleep 8

USAGE-$(cat <<HELP
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
HELP
)

##### Root check #####
if [ "$EUID" -ne 0 ]; then
    echo "Please run this as root."
    echo "$USAGE"
fi

##### Setup Global Vars #####
PREPROCESS=false
BUILD_SRM_STATIC=false
BUILD_SRM_PACKAGES=false
ISO_FILE=
OUTPUT_PATH="./output-dir/RESCUE1100.iso"
HASHCHECK=false
CHECKSUM_FILE_FILE=

#### Main Method #####
main() {

    # Check source iso exists
    if ! [ -f "$ISO_FILE" && "$ISO_FILE" == "*.iso" ]; then
        exit 1
    fi

    # Check hash
    sha512sum --check "$HASH_FILE"
    if [ $? -ne 0 ]; then
        exit 1;
    fi

    # Setup loopback device for ISO extraction
    lo_device=`losetup -f | cut -d '/' -f 3`
    losetup -f $ISO_FILE
    umount_point=`lsblk | grep "$lo_device" | awk '{print $7}'`

    # Build SRMs
    if $BUILD_SRM_STATIC; then
        mksquashfs ./srm_source/static /srm_dir/static.srm
    fi

    if $BUILD_SRM_PACKAGES; then
        echo "NOT IMPLEMENTED YET"
    fi

    # Preprocess
    source ./preprocessing/defaults.sh
    source ./preprocessing/custom.sh

    # Rebuild ISO
    ./sysrescue-customize --auto -s "/dev/$lo_device" -d "$OUTPUT_PATH" -r ./recipe-dir -w work-dir -o -v


    # remove loopback device
    umount_point "$umount_point"
}


##### Process Arguments #####
while [[ $# -gt 0 ]]; do
    case $1 in 
        -h|--help)
            echo -e "\n$USAGE\n"
            exit 0
            ;;
        --src)
            ISO_FILE="${1#*=}"
            shift
            ;;
        --dest)
            OUTPUT_PATH="${1#*=}"
            shift
            ;;
        --preprocess)
            PREPROCESS=true
            shift
            ;;
        --add-srm)
            BUILD_SRM_STATIC=true
            shift
            ;;
        --add-packages)
            BUILD_SRM_PACKAGES=true
            exit 1 # NOT IMPLEMENTED YET
            shift
            ;;
        --verify-hash)
            HASHCHECK=true
            CHECKSUM_FILE="${1#*=}"
            shift
            ;;
        *)
            echo -e "\n$USAGE\n"
            exit 0
            ;;
    esac
done

main
