dbus-run-session flatpak run \
  --env=__NV_PRIME_RENDER_OFFLOAD=1 \
  --env=__GLX_VENDOR_LIBRARY_NAME=nvidia \
  --env=VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json \
  --env=PROTON_ENABLE_NVAPI=1 \
  com.valvesoftware.Steam
