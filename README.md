# OpenVAS / Greenbone 10.0.1 for Gentoo/Linux

This is not official Gentoo/Linux OpenVAS package.

You can find official Gentoo/Linux OpenVAS package: 
https://packages.gentoo.org/packages/net-analyzer/openvas

## Versions

    openvas                      10.0.1 (stable, latest)

---------------------------------------

    openvas-libraries            10.0.1 (stable, latest)
    openvas-scanner              6.0.1 (stable, latest)
    openvas-manager              8.0.1 (stable, latest)
    greenbone-security-assistant 8.0.1 (stable, latest)
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
    sync-uri = https://github.com/vulnbe/openvas-gentoo-overlay.git
    priority = 9999

Then run:

sync repo       --> `emerge --sync or eix-sync or emaint -a sync`
install package --> `emerge --ask net-analyzer/openvas`

You must disable network-sandbox in order to install GSA:
    
    FEATURES="-network-sandbox" emerge greenbone-security assistant

### via layman

    layman -o https://raw.github.com/vulnbe/openvas-gentoo-overlay/master/repositories.xml -f -a openvas-overlay

Then run:

    layman -s openvas-overlay

## Use Flags

    IUSE="extras gsa ospd ldap radius"

- extras     --> Required for docs, pdf results and fonts | Recommended
- gsa        --> Greenbone Security Agent (WebUI)
- ospd       --> Scanner wrappers which share the same communication protocol
- ldap       --> LDAP Support for Openvas-Libraries
- radius     --> Radius Support for OpenVAS-Libraries
- postgresql --> PostgreSQL backend

## PostgreSQL configuration

    su - postgres -c "createuser -DRS gvm";
    su - postgres -c "createdb -O gvm gvmd";
    su - postgres -c "psql gvmd -c 'create role dba with superuser noinherit; grant dba to gvm; create extension \"uuid-ossp\";'";
    
[Read more](https://github.com/greenbone/gvmd/blob/master/INSTALL.md#configure-postgresql-database-backend)

## User management

    su -s /bin/sh gvm -c "/usr/sbin/gvmd --create-user=admin --password=admin"

## Issues

- GVM stucks on NVT cache update

`psql -q --pset pager=off gvmd -c "DELETE FROM meta where name = 'nvts_feed_version' OR name = 'nvts_check_time';"`

- OpenVAS cache corruption

`redis-cli -s /tmp/redis.sock FLUSHALL`

