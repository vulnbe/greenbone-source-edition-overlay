# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_MAKEFILE_GENERATOR="emake"
inherit cmake flag-o-matic toolchain-funcs

DESCRIPTION="Open Vulnerability Assessment Scanner"
HOMEPAGE="https://www.greenbone.net/en/"
SRC_URI="https://github.com/greenbone/openvas/archive/v${PV}.tar.gz -> ${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2 GPL-2+"
KEYWORDS="~amd64 ~x86"
IUSE="cron extras test"
RESTRICT="!test? ( test )"

DEPEND="
  =net-analyzer/gvm-libs-${PV}
	app-crypt/gpgme:=
	dev-db/redis
	dev-libs/glib
	dev-libs/libgcrypt:=
	dev-libs/libksba
	net-analyzer/net-snmp
	net-analyzer/nmap
	net-libs/gnutls:=[tools]
	net-libs/libpcap
	net-libs/libssh:="

RDEPEND="
	acct-user/gvm
	${DEPEND}"

BDEPEND="
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
	extras? (
		app-doc/doxygen[dot]
		app-doc/xmltoman
		app-text/htmldoc
		dev-perl/CGI
		dev-perl/SQL-Translator
	)
	test? ( dev-libs/cgreen )"

src_prepare() {
	cmake_src_prepare
	# QA-Fix | Correct FHS/Gentoo policy paths for 7.0.0
	einfo "sed -i -e s*/doc/openvas/*/doc/openvas-${PV}/*g $S/src/CMakeLists.txt"
	sed -i -e "s*/doc/openvas/*/doc/openvas-${PV}/*g" "$S"/src/CMakeLists.txt || die
	# QA-Fix | Remove !CLANG doxygen warnings for 7.0.0
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
		"-DSBINDIR=${EPREFIX}/usr/bin"
		"-DOPENVAS_RUN_DIR=${EPREFIX}/var/run/gvm"
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	if use extras; then
		cmake_build -C "${BUILD_DIR}" doc
		cmake_build doc-full -C "${BUILD_DIR}" doc
	fi
	cmake_build rebuild_cache
	if use test; then
		cmake_build tests
	fi
}

src_install() {
	if use extras; then
		local HTML_DOCS=( "${BUILD_DIR}"/doc/generated/html/. )
	fi
	cmake_src_install

	if use cron; then
		# Install the cron job if they want it.
		exeinto /etc/gvm
		doexe "${FILESDIR}/gvm-feed-sync.sh"
		fowners gvm:gvm /etc/gvm/gvm-feed-sync.sh

		insinto /etc/cron.d
		newins "${FILESDIR}"/gvm-feed-sync.cron gvm
	fi

	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate" "${PN}"

	# Set proper permissions on required files/directories
	keepdir /var/{log,run}/gvm
	fowners gvm:gvm /var/{log,run}/gvm
	
  keepdir /var/lib/openvas/{gnupg,plugins}
	fowners -R gvm:gvm /var/lib/openvas

	insinto /etc/openvas
	doins "${FILESDIR}/openvas.conf"

  keepdir /var/cache/openvas
}
