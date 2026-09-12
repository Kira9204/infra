#!/usr/bin/bash

exec /usr/bin/brave-origin-stable \
  --enable-features=UseOzonePlatform,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,VaapiOnNvidiaGPUs,VaapiIgnoreDriverChecks \
  --ozone-platform=wayland \
  "$@"
