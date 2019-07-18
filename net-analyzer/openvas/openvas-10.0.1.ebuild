# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils

DESCRIPTION="A remote security scanner"
HOMEPAGE="http://www.openvas.org/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE="+extras +gsa ldap +ospd radius +postgresql"

RDEPEND="
	>=net-analyzer/openvas-libraries-10.0.1[extras?]
	>=net-analyzer/openvas-scanner-6.0.1[extras?]
	extras? (
		postgresql? ( >=net-analyzer/openvas-manager-8.0.1[extras,postgresql] )
		!postgresql? ( >=net-analyzer/openvas-manager-8.0.1[extras] )
	)
	!extras? ( 
		postgresql? ( >=net-analyzer/openvas-manager-8.0.1[postgresql] )
		!postgresql? ( >=net-analyzer/openvas-manager-8.0.1 )
	)
	gsa? ( >=net-analyzer/greenbone-security-assistant-8.0.1[extras?] )
	ldap? ( >=net-analyzer/openvas-libraries-10.0.1[ldap] )
	ospd? ( >=net-analyzer/ospd-1.3.2[extras?] )
	radius? ( >=net-analyzer/openvas-libraries-10.0.1[radius] )"

pkg_postinst() {
	elog "----------------------------IMPORTANT----------------------------"
	elog " Please read important notes > /usr/share/openvas/OPENVAS.gentoo "
	elog "-----------------------------------------------------------------"
	elog "Additional support for extra checks can be get from"
	optfeature "Web server scanning and testing tool" net-analyzer/nikto
	optfeature "Portscanner" net-analyzer/nmap
	optfeature "IPsec VPN scanning, fingerprinting and testing tool" net-analyzer/ike-scan
	optfeature "Application protocol detection tool" net-analyzer/amap
	optfeature "ovaldi (OVAL) — an OVAL Interpreter" app-forensics/ovaldi
	optfeature "Linux-kernel-based portscanner" net-analyzer/portbunny
	optfeature "Web application attack and audit framework" net-analyzer/w3af
}
