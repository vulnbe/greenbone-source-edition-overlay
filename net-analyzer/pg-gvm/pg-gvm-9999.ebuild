# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake git-r3

DESCRIPTION="Greenbone Library for GVM helper functions in PostgreSQL"
HOMEPAGE="https://www.greenbone.net/en/"
EGIT_REPO_URI="https://github.com/greenbone/pg-gvm"
EGIT_COMMIT="d477e45db9f8b66461342e55a0db04afe27ffebb"

SLOT="0"
LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"

DEPEND="
	>=net-analyzer/gvm-libs-20.8.0
	dev-libs/libical
	dev-libs/glib
	>=dev-db/postgresql-9.6"

RDEPEND="
	${DEPEND}"

BDEPEND="
	dev-vcs/git
	virtual/pkgconfig"

src_configure() {
	CMAKE_BUILD_TYPE=Release
	cmake_src_configure
}
