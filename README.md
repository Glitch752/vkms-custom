# vkms-custom

A patchset and frontend for the VKMS (Virtual Kernel Mode Setting) driver in Linux, allowing it to set custom display resolutions and refresh rates for virtual displays that work across compositors.  

This is currently primarily a testground for modifying kernel modules, since I've never done it before! I'd like to soon make a full user-friendly tool for creating virtual displays. This readme is speculative, though I do use this driver for my own streaming setup.

## Use case: using Sunshine/Moonlight for straming second monitors

Upstream VKMS only supports a default set of resolutions, and not all compositors support virtual displays. I wanted to use Sunshine/Moonlight to allow my phone to act as a second monitor, but the default resolutions didn't work well for that. With this patchset, I can create a display with a custom resolution that works well for my phone.

## Use case: virtual displays for compositor development

Some of the VKMS driver's [todo items](https://docs.kernel.org/gpu/vkms.html#todo) are to support runtime configuration of display modes. I'm not quite there yet ;) but this gets a little closer to the intended use cases.