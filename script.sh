#!/bin/bash
set -e

# https://docs.kernel.org/gpu/vkms.html

vkms=$(lsmod | grep vkms)
if [ -z "$vkms" ]; then
    # Install custom vkms
    sudo insmod ./linux/drivers/gpu/drm/vkms/vkms.ko
    echo "vkms module loaded."
fi

# Kill sunshine if running
if pgrep -x "sunshine" > /dev/null; then
    pkill -x "sunshine"
    echo "sunshine process killed."
fi

# Start sunshine
sunshine &
# Open the sunshine web interface
xdg-open https://localhost:47990

if [ ! -d "/config" ]; then
    sudo mkdir -p /config
    sudo mount -t configfs none /config
    echo "configfs mounted at /config."
fi

# turn off param:create_default_dev in vkms to prevent it from creating a default display
echo 0 | sudo tee /sys/module/vkms/parameters/create_default_dev

# Create a virtual display
if [ ! -d "/config/vkms/virtual0" ]; then
    sudo mkdir -p /config/vkms/virtual0
    sudo mkdir /config/vkms/virtual0/planes/plane0
    # -> plane0/type is 0 (overlay), but we want 1 (primary). 2 is cursor
    # 1 primary plane is required for the display to be detected by the system
    echo 1 | sudo tee /config/vkms/virtual0/planes/plane0/type

    sudo mkdir /config/vkms/virtual0/crtcs/crtc0
    # crtcs are the display controllers

    # encoder
    sudo mkdir /config/vkms/virtual0/encoders/encoder0
    
    # connector
    sudo mkdir /config/vkms/virtual0/connectors/connector0
    # -> connector0/status can be 1 (connected), 2 (disconnected), or 3 (unknown)
    # it's 1 by default so we're fine

    # now we need to link them together
    # plane0 can be used by crtc0
    sudo ln -s /config/vkms/virtual0/crtcs/crtc0 /config/vkms/virtual0/planes/plane0/possible_crtcs
    # encoder0 can be used by crtc0
    sudo ln -s /config/vkms/virtual0/crtcs/crtc0 /config/vkms/virtual0/encoders/encoder0/possible_crtcs
    # connector0 can be used by encoder0
    sudo ln -s /config/vkms/virtual0/encoders/encoder0 /config/vkms/virtual0/connectors/connector0/possible_encoders

    echo "Virtual display 'virtual0' created."
fi

# enable/disable the display
# no arguments: show status
# "on": enable the display
# "off": disable the display

if [ "$1" == "on" ]; then
    echo 1 | sudo tee /config/vkms/virtual0/enabled
    echo "Virtual display 'virtual0' enabled."
elif [ "$1" == "off" ]; then
    echo 0 | sudo tee /config/vkms/virtual0/enabled
    echo "Virtual display 'virtual0' disabled."
else
    status=$(cat /config/vkms/virtual0/enabled)
    if [ "$status" == "1" ]; then
        echo "Virtual display 'virtual0' is currently enabled."
    elif [ "$status" == "0" ]; then
        echo "Virtual display 'virtual0' is currently disabled."
    else
        echo "Virtual display 'virtual0' status is unknown."
    fi
fi