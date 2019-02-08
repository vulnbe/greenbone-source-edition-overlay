# OpenVAS 9.0.0 for Gentoo/Linux

This is not official Gentoo/Linux OpenVAS package.

You can find official Gentoo/Linux OpenVAS package: 
https://packages.gentoo.org/packages/net-analyzer/openvas

## Versions

    openvas                      9.0.0 (stable, latest)

---------------------------------------

    openvas-libraries            9.0.3 (stable, latest)
    openvas-scanner              5.1.3 (stable, latest)
    openvas-manager              7.0.3 (stable, latest)
    greenbone-security-assistant 7.0.3 (stable, latest)
    gvm-tools                    1.4.1 (stable, latest)
    ospd                         1.3.2 (stable, latest)

## What is OpenVAS

OpenVAS is a full-featured vulnerability scanner. Its capabilities include unauthenticated testing, authenticated testing, various high level and low level Internet and industrial protocols, performance tuning for large-scale scans and a powerful internal programming language to implement any type of vulnerability test.

    OpenVAS Community Edition --> https://github.com/greenbone
    OpenVAS HomePage          --> http://www.openvas.org/
    Greenbone HomePage        --> https://www.greenbone.net/en/

## Usage

### via local overlays

Copy "openvas-overlay.conf" from this repository into /etc/portage/repos.conf/ to use the portage sync capabilities.
Alternatively you can create a /etc/portage/repos.conf/openvas-overlay.conf file containing:

    [openvas-overlay]
    location = /usr/local/portage/openvas-overlay
    sync-type = git
    sync-uri = https://github.com/hsntgm/openvas-9-gentoo-overlay.git
    priority = 9999

Then run:

    sync repo       --> emerge --sync or eix-sync or emaint -a sync
    install package --> emerge --ask net-analyzer/openvas

### via layman

    layman -o https://raw.github.com/hsntgm/openvas-9-gentoo-overlay/master/repositories.xml -f -a openvas-overlay

Then run:

    layman -s openvas-overlay

## Use Flags

     IUSE="extras cli gsa ospd ldap radius"

 - extras     --> Required for docs, pdf results and fonts | Recommended
 - cli        --> Command Line Interfaces for OpenVAS-Scanner
 - gsa        --> Greenbone Security Agent (WebUI)
 - ospd       --> Scanner wrappers which share the same communication protocol
 - ldap       --> LDAP Support for Openvas-Libraries
 - radius     --> Radius Support for OpenVAS-Libraries

## Scripts

    Inspect the scripts. You never blindly run scripts you
    downloaded from the Internet, do you?
    
https://github.com/hsntgm/openvas-9-scripts
