# Alpine Monitorix

Install [Monitorix](https://www.monitorix.org) on Alpine Linux.

## Requirements

Make sure your system is up to date and install all necessary dependencies:

```sh
apk update
apk upgrade
apk add perl perl-cgi perl-libwww perl-mailtools perl-mime-lite perl-dbi \
        perl-xml-simple perl-xml-libxml perl-config-general \
        perl-http-server-simple perl-io-socket-ssl rrdtool perl-rrd
```

## Installation

1. Download the `.tar.gz` package of Monitorix from the official website:  
   👉 [https://www.monitorix.org](https://www.monitorix.org)

2. Extract the archive:

```sh
cd \tmp
tar -xzf monitorix-*.tar.gz
cd monitorix-*/
```

3. Download and run the installation script:

```sh
./install.sh
```

## OpenRC Configuration

1. Download the OpenRC init script and place it in `/etc/init.d/`, then set it as executable:

```sh
chmod +x /etc/init.d/monitorix
```

2. Enable Monitorix at boot:

```sh
rc-update add monitorix default
```

3. Edit the configuration file as needed:

```sh
vi /etc/monitorix/monitorix.conf
```

4. Start the service:

```sh
rc-service monitorix start
```

## Logrotate (Optional but recommended)

1. Ensure `logrotate` is installed, or install it:

```sh
apk add logrotate
```

2. Add a logrotate configuration for Monitorix in `/etc/logrotate.d/monitorix` (example):

```sh
/var/log/monitorix/monitorix.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 640 root adm
}
```
