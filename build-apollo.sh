#!/bin/sh
# BUILD_CONFIG=build.config.apollo.gcc build/build.sh -j32
workdir="$HOME/Projects/android/apollo"
srcdir="$workdir/android_kernel_xiaomi_sm8250"
objdir="$srcdir/out/arch/arm64/boot"

PATH="$workdir/proton-clang-master/bin:$PATH"
export PATH
export KBUILD_BUILD_USER="LLJY"
export KBUILD_BUILD_HOST="ryzenpc"
export ARCH=arm64
${CROSS_COMPILE}ld -v

build() {
 make O=out clean
 make O=out vendor/apollo_defconfig
 make -j"$(nproc --all)" \
    O=out \
    CC="ccache clang" \
    CXX="ccache clang++" \
    AR="ccache llvm-ar" \
    AS="ccache llvm-as" \
    NM="ccache llvm-nm" \
    STRIP="ccache llvm-strip" \
    OBJCOPY="ccache llvm-objcopy" \
    OBJDUMP="ccache llvm-objdump"\
    OBJSIZE="ccache llvm-size" \
    READELF="ccache llvm-readelf" \
    HOSTCC="ccache clang" \
    HOSTCXX="ccache clang++" \
    HOSTAR="ccache llvm-ar" \
    HOSTAS="ccache llvm-as" \
    HOSTNM="ccache llvm-nm" \
    CROSS_COMPILE="aarch64-linux-gnu-" \
    CROSS_COMPILE_ARM32="arm-linux-gnueabi-"

}

name_zip() {
 kvstring="$(strings $objdir/Image | grep -m1 "Linux version")"

 kernelversion="$(cut -d' ' -f 3 <<< $kvstring)"
 glitchedversion="$(cut -d'-' -f 3 <<< $kernelversion)"

 buildcount=r"$(cat $srcdir/out/.version)"

 kernelname="$(cut -d'-' -f 2 <<< $kernelversion)"
 kernelname="${kernelname,,}"

 zipname="$kernelname-$buildcount"
}

package() {
 cd $workdir/AnyKernel3-master

 rm dtbo.img
 rm dtb
 rm *.zip

 python2 $workdir/mkdtboimg.py create dtbo.img $objdir/dts/vendor/qcom/*.dtbo

 cp $objdir/Image zImage
 cat $objdir/dts/vendor/qcom/*.dtb > dtb

 zip -r $zipname.zip *
}

build
name_zip
package