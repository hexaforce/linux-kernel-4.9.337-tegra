# https://blog.kevmo314.com/compiling-custom-kernel-modules-on-the-jetson-nano.html
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
ENV TZ Etc/UTC

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y build-essential bc libncurses5 libncurses5-dev sudo vim kmod usbutils

COPY . .

#===============================================================================================
#=== cross compiler ============================================================================
#===============================================================================================
# cross compiler version
ENV LINARO gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu
# kernel suffix
ENV LOCALVERSION -tegra-OpenHD-2.5

# https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/
RUN tar xf $LINARO.tar.xz 
RUN rm -f $LINARO.tar.xz 
ENV CROSS_COMPILE /$LINARO/bin/aarch64-linux-gnu-

#===============================================================================================
#=== sdk manager ===============================================================================
#===============================================================================================
# sdk manager version
ENV SDKMANAGER sdkmanager_2.1.0-11682_amd64
# sdk installed component dir
ENV Linux_for_Tegra /home/openhd/nvidia/nvidia_sdk/JetPack_4.6.4_Linux_JETSON_NANO_TARGETS/Linux_for_Tegra

# https://developer.nvidia.com/sdk-manager
RUN apt-get install -y libcanberra-gtk-module locales libxshmfence1 libnss3 libatk-bridge2.0-0 libdrm2 libgtk-3-0 libgbm1 libcanberra-gtk3-module libx11-xcb1
RUN dpkg -i $SDKMANAGER.deb
RUN rm -f $SDKMANAGER.deb

#===============================================================================================
#=== kernel sources ============================================================================
#===============================================================================================
# kernel sources code dir
ENV Tegra_kernel_Sources /Linux_for_Tegra/source/public/kernel/kernel-4.9

# https://developer.nvidia.com/embedded/l4t/r32_release_v7.4/sources/t210/public_sources.tbz2
RUN tar -xjf public_sources.tbz2
RUN rm -f public_sources.tbz2
WORKDIR /Linux_for_Tegra/source/public
RUN tar -xjf kernel_src.tbz2
# build work dir
WORKDIR $Tegra_kernel_Sources

#===============================================================================================
#=== user ======================================================================================
#===============================================================================================
RUN useradd -m openhd && \
    echo 'openhd ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER openhd

#===============================================================================================
#=== kernel build ==============================================================================
#===============================================================================================
# build out dir
ENV TEGRA_KERNEL_OUT /home/openhd/t4l-kernel 
RUN mkdir -p $TEGRA_KERNEL_OUT

# default kernel config
RUN make ARCH=arm64 O=$TEGRA_KERNEL_OUT tegra_defconfig

# custom kernel config
# make ARCH=arm64 O=$TEGRA_KERNEL_OUT menuconfig

# build kernel
RUN make ARCH=arm64 O=$TEGRA_KERNEL_OUT -j`nproc`

ENTRYPOINT ["sh", "-c", "tail -f /dev/null"]
