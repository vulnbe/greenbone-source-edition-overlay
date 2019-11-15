# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_MAKEFILE_GENERATOR="emake"
inherit cmake-utils systemd user
MY_PN="gsa"

DESCRIPTION="Greenbone Security Assistant for OpenVAS"
HOMEPAGE="http://www.openvas.org/"
SRC_URI="https://github.com/greenbone/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2+ BSD MIT"
KEYWORDS="~amd64 ~x86"
IUSE="extras"

DEPEND="
	dev-libs/libgcrypt:0=
	dev-libs/libxml2:2
	dev-libs/libxslt
	>=net-analyzer/openvas-libraries-10.0.1
	net-libs/gnutls:=[tools]
	net-libs/libmicrohttpd[messages]
	extras? ( dev-python/polib )"

RDEPEND="
	${DEPEND}
	>=net-analyzer/openvas-scanner-6.0.1
	>=net-analyzer/openvas-manager-8.0.1
	extras? ( dev-texlive/texlive-latexextra )"

BDEPEND="
	>=sys-apps/yarn-1.16.0
	>=net-libs/nodejs-11.14.0
	virtual/pkgconfig
	extras? ( app-doc/doxygen[dot]
		  app-doc/xmltoman
		  app-text/htmldoc
		  sys-devel/gettext
	)"

PATCHES=(
	"${FILESDIR}"/${MY_PN}-${PV}-remove-static.patch
	"${FILESDIR}"/${MY_PN}-${PV}-xss.patch
)

BUILD_DIR="${WORKDIR}/${MY_PN}-${PV}_build"
S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	if has network-sandbox $FEATURES; then
			ewarn
			ewarn "${CATEGORY}/${PN} requires 'network-sandbox' to be disabled in FEATURES"
			ewarn
			die "[network-sandbox] is enabled in FEATURES"
	fi
	cmake-utils_src_prepare
	if use extras; then
		doxygen -u "$S"/gsad/doc/Doxyfile_full.in || die
	fi
}

src_configure() {
	local mycmakeargs=(
		"-DCMAKE_INSTALL_PREFIX=${EPREFIX}/usr"
		"-DLOCALSTATEDIR=${EPREFIX}/var"
		"-DSYSCONFDIR=${EPREFIX}/etc"
		"-DCMAKE_BUILD_TYPE=Release"
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
	if use extras; then
		cmake-utils_src_make -C "${BUILD_DIR}" doc
    cmake-utils_src_make doc-full -C "${BUILD_DIR}" doc
		HTML_DOCS=( "${BUILD_DIR}"/gsad/doc/generated/html/. )
	fi
}

src_install() {
	cmake-utils_src_install

	insinto /etc/gvm/
	doins "${FILESDIR}"/gsad_log.conf

	insinto /etc/openvas/sysconfig
	doins "${FILESDIR}"/${MY_PN}-daemon.conf

	newinitd "${FILESDIR}/${MY_PN}.init" ${MY_PN}
	newconfd "${FILESDIR}/${MY_PN}-daemon.conf" ${MY_PN}

	insinto /etc/logrotate.d
	newins "${FILESDIR}/${MY_PN}.logrotate" ${MY_PN}

	systemd_newtmpfilesd "${FILESDIR}/${MY_PN}.tmpfiles.d" ${MY_PN}.conf
	systemd_dounit "${FILESDIR}"/${MY_PN}.service

	keepdir /var/log/gsa
}

pkg_postinst() {
	enewgroup gsa 503
	enewuser gsa 503 -1 -1 gsa
	fowners -R gsa /var/log/gsa
}
