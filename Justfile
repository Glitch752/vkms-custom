SRC_DIR := justfile_directory() + "/src"

# We build against /lib/modules/$(uname -r)/build
build:
    cd /lib/modules/$(uname -r)/build && make M={{SRC_DIR}} clean
    cd /lib/modules/$(uname -r)/build && make M={{SRC_DIR}} modules

# Replace the running kernel module with our custom one
replace:
    # stop the graphical session
    # sudo systemctl stop display-manager

    # disable the current vkms module
    sudo modprobe -r vkms
    # or sudo rmmod vkms

    sudo insmod {{SRC_DIR}}/vkms.ko
    # sudo cp {{SRC_DIR}}/vkms.ko /lib/modules/$(uname -r)/extra/vkms.ko
    sudo depmod -a
    sudo modprobe vkms

    # restart the graphical session
    # sudo systemctl start display-manager

# use if overriding default vkms causes issues
blacklist-default-vkms:
    echo "blacklist vkms" | sudo tee /etc/modprobe.d/blacklist-vkms.conf
    sudo mkinitcpio -P
    sudo depmod -a
