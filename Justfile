# Clone https://github.com/torvalds/linux/tree/028ef9c96e96197026887c0f092424679298aae8/drivers/gpu/drm/vkms
# using sparse checkout to save space and time.
clone:
    git clone --depth 1 --filter=blob:none --sparse https://github.com/torvalds/linux.git
    cd linux && git sparse-checkout set --no-cone drivers/gpu/drm/vkms
    cd linux && git fetch --depth=1 origin 028ef9c96e96197026887c0f092424679298aae8
    cd linux && git checkout 028ef9c96e96197026887c0f092424679298aae8

patch:
    cp patches/*.patch linux/
    cd linux && for patch in *.patch; do git apply $patch; done

# create a new patch in the format ts-description.patch
create-patch description:
    cd linux && git add drivers/gpu/drm/vkms
    cd linux && git commit -m "{{description}}"
    cd linux && git format-patch -1 HEAD --stdout > ../patches/$(date +%Y%m%d%H%M%S)-{{description}}.patch

CUSTOM_TREE := justfile_directory() + "/linux"

# We build against /lib/modules/$(uname -r)/build
build:
    cd /lib/modules/$(uname -r)/build && make M={{CUSTOM_TREE}}/drivers/gpu/drm/vkms clean
    cd /lib/modules/$(uname -r)/build && make M={{CUSTOM_TREE}}/drivers/gpu/drm/vkms modules

# Replace the running kernel module with our custom one
replace:
    # stop the graphical session
    # sudo systemctl stop display-manager

    # disable the current vkms module
    sudo modprobe -r vkms
    # or sudo rmmod vkms

    sudo insmod {{CUSTOM_TREE}}/drivers/gpu/drm/vkms/vkms.ko
    # sudo cp {{CUSTOM_TREE}}/drivers/gpu/drm/vkms/vkms.ko /lib/modules/$(uname -r)/extra/vkms.ko
    sudo depmod -a
    sudo modprobe vkms

    # restart the graphical session
    # sudo systemctl start display-manager

# use if overriding default vkms causes issues
blacklist-default-vkms:
    echo "blacklist vkms" | sudo tee /etc/modprobe.d/blacklist-vkms.conf
    sudo mkinitcpio -P
    sudo depmod -a
