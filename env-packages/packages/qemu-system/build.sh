PACKAGE_VERSION="5.1.0"
PACKAGE_SRCURL="https://download.qemu.org/qemu-${PACKAGE_VERSION}.tar.xz"
PACKAGE_SHA256="c9174eb5933d9eb5e61f541cd6d1184cd3118dfe4c5c4955bc1bdc4d390fa4e5"
PACKAGE_DEPENDS="curl, glib, libgcrypt, libjpeg-turbo, libpng, lzo, pixman, snappy, zlib"
PACKAGE_BUILD_IN_SRC="true"

builder_step_configure() {
	CFLAGS+=" $CPPFLAGS"
	CXXFLAGS+=" $CPPFLAGS"

	cp "$PACKAGE_INSTALL_PREFIX"/bin/libgcrypt-config \
		"$PACKAGE_TMPDIR"/libgcrypt-config
	export PATH="$PATH:$PACKAGE_TMPDIR"

	# Note: using --disable-stack-protector since stack protector
	# flags already passed by build scripts but we do not want to
	# override them with what QEMU configure provides.
	./configure \
		--prefix="$PACKAGE_INSTALL_PREFIX" \
		--cross-prefix="${PACKAGE_TARGET_PLATFORM}-" \
		--host-cc="gcc" \
		--cc="$CC" \
		--cxx="$CXX" \
		--objcc="$CC" \
		--disable-stack-protector \
		--smbd="/system/bin/smbd" \
		--enable-coroutine-pool \
		--enable-trace-backends=nop \
		--disable-guest-agent \
		--disable-gnutls \
		--disable-nettle \
		--enable-gcrypt \
		--disable-sdl \
		--disable-sdl-image \
		--disable-gtk \
		--disable-vte \
		--disable-curses \
		--disable-iconv \
		--enable-vnc \
		--disable-vnc-sasl \
		--enable-vnc-jpeg \
		--enable-vnc-png \
		--disable-xen \
		--disable-xen-pci-passthrough \
		--enable-virtfs \
		--enable-curl \
		--disable-fdt \
		--disable-kvm \
		--disable-hax \
		--disable-hvf \
		--disable-whpx \
		--disable-libnfs \
		--disable-libusb \
		--enable-lzo \
		--enable-snappy \
		--disable-bzip2 \
		--disable-lzfse \
		--disable-seccomp \
		--disable-libssh \
		--disable-libxml2 \
		--enable-bochs \
		--enable-cloop \
		--enable-dmg \
		--enable-parallels \
		--enable-qed \
		--enable-sheepdog \
		--target-list=x86_64-softmmu
}

builder_step_post_make_install() {
	local bindir

	case "$PACKAGE_TARGET_ARCH" in
		aarch64) bindir="arm64-v8a";;
		arm) bindir="armeabi-v7a";;
		i686) bindir="x86";;
		x86_64) bindir="x86_64";;
		*) echo "Invalid architecture '$PACKAGE_TARGET_ARCH'" && return 1;;
	esac

	install -Dm700 "$PACKAGE_INSTALL_PREFIX"/bin/qemu-system-x86_64 \
		"${BUILDER_SCRIPTDIR}/jniLibs/${bindir}/libqemu.so"
	"$STRIP" -s "${BUILDER_SCRIPTDIR}/jniLibs/${bindir}/libqemu.so"
}
