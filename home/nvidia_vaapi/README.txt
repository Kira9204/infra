
# In order to get VAAPI to work on Nvidia cards we need to perform the following steps:

1. Install buld tools
```bash
sudo dnf install git meson ninja-build gcc gcc-c++ \
  libva-devel libdrm-devel gstreamer1-plugins-bad-free-devel \
  gstreamer1-plugins-bad-freeworld nv-codec-headers
```

2. Install this repo.
```bash
git clone https://github.com/elFarto/nvidia-vaapi-driver.git
cd nvidia-vaapi-driver

meson setup build --prefix=/usr
ninja -C build
sudo ninja -C build install
```

3. Add the following to your /etc/enviroment file:
```bash
LIBVA_DRIVER_NAME=nvidia
```

4. Use the following arguments when running any Chrome/Electron app, use the following arguments:
```bash
--enable-features=UseOzonePlatform,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,VaapiOnNvidiaGPUs,VaapiIgnoreDriverChecks \
  --ozone-platform=wayland
```
I recommend using the the brave-origin-wayland.sh and accompanying .desktop files in this repo.

