# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit optfeature

DESCRIPTION="Greenbone Source Edition, previously named OpenVAS"
HOMEPAGE="https://www.greenbone.net/en/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE="+cron +gsa +openvas extras ldap radius"

RDEPEND="
	=net-analyzer/gvm-libs-${PV}[extras?,ldap?,radius?]
	=net-analyzer/gvmd-${PV}[extras?]
	gsa? ( =net-analyzer/greenbone-security-assistant-${PV}[extras?] )
	openvas? ( =net-analyzer/ospd-openvas-${PV}[cron?,extras?] )"

pkg_postinst() {
	elog "Additional support for extra checks can be get from"
	optfeature "Web server scanning and testing tool" net-analyzer/nikto
	optfeature "IPsec VPN scanning, fingerprinting and testing tool" net-analyzer/ike-scan
	optfeature "Application protocol detection tool" net-analyzer/amap
	optfeature "ovaldi (OVAL) — an OVAL Interpreter" app-forensics/ovaldi
	optfeature "Linux-kernel-based portscanner" net-analyzer/portbunny
	optfeature "Web application attack and audit framework" net-analyzer/w3af
}
