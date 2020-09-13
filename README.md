# Greenbone Source Edition for Gentoo/Linux

This is not official Gentoo/Linux repository.

You can find official Gentoo/Linux package: 
https://packages.gentoo.org/packages/net-analyzer/gvm

## What is GSE

Greenbone Source Edition (GSE) is vulnerability management platform including a network security scanner with associated tools like a graphical user front-end. 
The core component is a server with a set of network vulnerability tests (NVTs) to detect security problems in remote systems and applications.

GSE was previously known as Open Vulnerability Assessment System (OpenVAS).

## Usage

### via local overlays

Copy `greenbone-source-edition-overlay.conf` from this repository into /etc/portage/repos.conf/ to use the portage sync capabilities.

Then run:

sync repo           --> `emerge --sync or eix-sync or emaint -a sync`
install metapackage --> `emerge --ask net-analyzer/gse[openvas,gsa,cron,extras,-ldap,-radius]`

### via layman

```
layman -o https://raw.github.com/vulnbe/greenbone-source-edition-overlay/master/repositories.xml -f -a greenbone-source-edition-overlay
```

Then run:

```
layman -s greenbone-source-edition-overlay
```

## Use Flags

gsa - Greenbone Security Assistant (WebUI)
openvas - OSPD OpenVAS scanner
cron - A cron job to update GSE's vulnerability feeds daily
extras - Extra fonts, pdf-results! and html docs support
ldap - LDAP support
radius - Radius support

## Certificates provision

```
sudo -u gvm gvm-manage-certs -a
```

## PostgreSQL initialization and configuration

```
emerge --config dev-db/postgresql:12

sudo -u postgres bash -c "createuser -DRS gvm; createdb -O gvm gvmd"
sudo -u postgres psql gvmd -c 'create role dba with superuser noinherit; grant dba to gvm; create extension "uuid-ossp"; create extension "pgcrypto";'
```

[Read more](https://github.com/greenbone/gvmd/blob/master/INSTALL.md#configure-postgresql-database-backend)

## Feeds syncing

```
sudo -u gvm greenbone-feed-sync --type GVMD_DATA
sudo -u gvm greenbone-feed-sync --type SCAP
sudo -u gvm greenbone-feed-sync --type CERT
```

## Scanner configuration

### Update scanner socket path

```
sudo -u gvmd --get-scanners
sudo -u gvm gvmd --modify-scanner=08b69003-5fc2-4037-a479-93b440211c73 --scanner-host /var/run/gvm/ospd-openvas.sock
sudo -u gvm gvmd --verify-scanner=08b69003-5fc2-4037-a479-93b440211c73
```

### Add osp scanner

```
sudo -u gvm gvmd --create-scanner="OSP Scanner" --scanner-host=127.0.0.1 --scanner-port=9391 \
    --scanner-type="OSP" --scanner-ca-pub=/var/lib/gvm/CA/cacert.pem \
    --scanner-key-pub=/var/lib/gvm/CA/clientcert.pem \
    --scanner-key-priv=/var/lib/gvm/private/CA/clientkey.pem
```

## User management

```
sudo -u gvm gvmd --create-user=admin --password=admin"
```

## Feed import owner configuration

```
sudo -u gvm gvmd --get-users --verbose
sudo -u gvm gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value UUID
```

## Issues

- Unable to connect to redis
  
review redis socket permissions (must be *770*)

- GVM stucks on NVT cache update

`psql -q --pset pager=off gvmd -c "DELETE FROM meta where name = 'nvts_feed_version' OR name = 'nvts_check_time';"`

- Cache corruption

`redis-cli -s /tmp/redis.sock FLUSHALL`
