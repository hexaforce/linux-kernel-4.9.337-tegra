# linux-kernel-4.9.337-tegra

## 1.download
### gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
* https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/

### public_sources.tbz2
* https://developer.nvidia.com/embedded/l4t/r32_release_v7.4/sources/t210/public_sources.tbz2

### sdkmanager_2.1.0-11682_amd64.deb
* https://developer.nvidia.com/sdk-manager


## 2.Docker build
```bash
docker build . -t hexaforce/linux-kernel-builder

docker run -it --rm hexaforce/linux-kernel-builder bash
# If you want to overwrite the SD card directly via USB
# docker run --privileged -it --rm -v {USB PATH}:/usb hexaforce/linux-kernel-builder

docker ps

docker exec -it {CONTAINER-ID} bash
```

## 3.Kernel build and install
* custom kernel config
```bash
make ARCH=arm64 O=$TEGRA_KERNEL_OUT menuconfig
```
* rebuild kernel
```bash
make ARCH=arm64 O=$TEGRA_KERNEL_OUT -j`nproc`
```

## 4.Override SD card image
```bash
sudo cp $TEGRA_KERNEL_OUT/arch/arm64/boot/Image /usb/boot/Image

sudo cp -r $TEGRA_KERNEL_OUT/arch/arm64/boot/dts/* /usb/boot/dtb

sudo make ARCH=arm64 O=$TEGRA_KERNEL_OUT modules_install INSTALL_MOD_PATH=/usb
```

# Appendix

### 1.Download SD card images
```bash
# sdkmanager --cli --query interactive
sdkmanager --cli install \
  --login-type devzone \
  --product Jetson \
  --target-os Linux \
  --version 4.6.4 \
  --host \
  --target JETSON_NANO_TARGETS \
  --select 'Jetson OS'
```

### 2.Copy build kernel and install
```bash
cp $TEGRA_KERNEL_OUT/arch/arm64/boot/Image $Linux_for_Tegra/kernel/Image

cp -r $TEGRA_KERNEL_OUT/arch/arm64/boot/dts/* $Linux_for_Tegra/kernel/dtb

sudo make ARCH=arm64 O=$TEGRA_KERNEL_OUT modules_install INSTALL_MOD_PATH=$Linux_for_Tegra/rootfs/
```
### 3.Creator SD card images
```bash
cd $Linux_for_Tegra

sudo ./apply_binaries.sh -r rootfs

sudo ./tools/jetson-disk-image-creator.sh -o sdcard.img -b jetson-nano -r 300
```

### 4.Get image (host machine)
```bash
docker ps

docker cp [CONTAINER-ID]:/home/openhd/nvidia/nvidia_sdk/JetPack_4.6.4_Linux_JETSON_NANO_TARGETS/Linux_for_Tegra/bootloader/system.img .
```