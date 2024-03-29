# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_MAKEFILE_GENERATOR="emake"
inherit cmake flag-o-matic systemd toolchain-funcs

DESCRIPTION="Greenbone vulnerability manager, previously named openvas-manager"
HOMEPAGE="https://www.greenbone.net/en/"
SRC_URI="https://github.com/greenbone/gvmd/archive/v${PV}.tar.gz -> ${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2+"
KEYWORDS="~amd64 ~x86"
IUSE="extras test"
RESTRICT="!test? ( test )"
MVER="21.0.0"

DEPEND="
	>=net-analyzer/gvm-libs-${MVER}
	net-analyzer/pg-gvm
	>=dev-db/postgresql-9.6[uuid]
	dev-libs/libgcrypt:0=
	dev-libs/libical
	net-libs/gnutls:=[tools]
	dev-libs/libxslt
	extras? (
		app-text/xmlstarlet
		dev-texlive/texlive-latexextra
		dev-perl/XML-Twig )"

RDEPEND="
	${DEPEND}
	acct-user/gvm"

BDEPEND="
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
	extras? (
		app-doc/doxygen[dot]
		app-doc/xmltoman
		app-text/htmldoc
	)
	test? ( dev-libs/cgreen )"

src_prepare() {
	cmake_src_prepare
	# QA-Fix | Use correct FHS/Gentoo policy paths for 9.0.0
	sed -i -e "s*share/doc/gvm/html/*share/doc/gvmd-${PV}/html/*g" "$S"/doc/CMakeLists.txt || die
	sed -i -e "s*/doc/gvm/*/doc/gvmd-${PV}/*g" "$S"/CMakeLists.txt || die
	# QA-Fix | Remove !CLANG Doxygen warnings for 9.0.0
	if use extras; then
		if ! tc-is-clang; then
		   local f
		   for f in doc/*.in
		   do
			sed -i \
				-e "s*CLANG_ASSISTED_PARSING = NO*#CLANG_ASSISTED_PARSING = NO*g" \
				-e "s*CLANG_OPTIONS*#CLANG_OPTIONS*g" \
				"${f}" || die "couldn't disable CLANG parsing"
		   done
		fi
	fi
}

src_configure() {
	CMAKE_BUILD_TYPE=Release
	local mycmakeargs=(
		"-DLOCALSTATEDIR=${EPREFIX}/var"
		"-DSYSCONFDIR=${EPREFIX}/etc"
		"-DDEFAULT_CONFIG_DIR=${EPREFIX}/etc/default"
		"-DLOGROTATE_DIR=${EPREFIX}/etc/logrotate.d"
		"-DLIBDIR=${EPREFIX}/usr/$(get_libdir)"
		"-DSBINDIR=${EPREFIX}/usr/bin"
		"-DGVM_RUN_DIR=${EPREFIX}/var/run/gvm"
		"-DOPENVAS_DEFAULT_SOCKET=${EPREFIX}/var/run/gvm/ospd-openvas.sock"
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	if use extras; then
		cmake_build -C "${BUILD_DIR}" doc
		cmake_build doc-full -C "${BUILD_DIR}" doc
	fi
	if use test; then
		cmake_build tests
	fi
	cmake_build rebuild_cache
}

src_install() {
	if use extras; then
		local HTML_DOCS=( "${BUILD_DIR}"/doc/generated/html/. )
	fi
	cmake_src_install

	fowners -R gvm:gvm /etc/gvm

	newinitd "${FILESDIR}/${PN}.init" "${PN}"
	newconfd "${FILESDIR}/${PN}-daemon.conf" "${PN}"

	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate" "${PN}"

	# Set proper permissions on required files/directories
	keepdir /var/lib/gvm/gvmd
	fowners -R gvm:gvm /var/lib/gvm
}
