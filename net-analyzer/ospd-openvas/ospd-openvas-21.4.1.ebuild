# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )
DISTUTILS_USE_SETUPTOOLS=rdepend
inherit distutils-r1 systemd

DESCRIPTION="OSP server implementation to allow GVM to remotely control OpenVAS"
HOMEPAGE="https://github.com/greenbone/ospd-openvas"
SRC_URI="https://github.com/greenbone/ospd-openvas/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cron extras test"
RESTRICT="!test? ( test )"

DEPEND="
  =net-analyzer/ospd-${PV}[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/redis-py[${PYTHON_USEDEP}]
  dev-python/deprecated[${PYTHON_USEDEP}]
"
RDEPEND="
	${DEPEND}
  acct-user/gvm
	=net-analyzer/openvas-scanner-${PV}[cron?,extras?,test?]
  app-admin/sudo"
BDEPEND=""

distutils_enable_tests unittest

python_install() {
	distutils-r1_python_install

	insinto /etc/openvas
	doins "${FILESDIR}"/redis.conf.example
	doins "${FILESDIR}"/ospd.conf

	fowners -R gvm:gvm /etc/openvas

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"

  # add sudoers definitions for user gvm
	insinto /etc/sudoers.d/
	insopts -m 0600 -o root -g root
	doins "${FILESDIR}/gvm-sudoers"
}
