#!/bin/bash
# Monitorix installation script for Alpine Linux

set -e  # Exit on error

# Functions for output messages
print_info() {
    echo "[INFO] $1"
}

print_success() {
    echo "[SUCCESS] $1"
}

print_warning() {
    echo "[WARNING] $1"
}

print_error() {
    echo "[ERROR] $1"
}

SOURCE_DIR=.
BASE_DIR=/var/lib/monitorix/www

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    print_error "Source directory not found: $SOURCE_DIR"
    exit 1
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root"
    exit 1
fi

print_info "Installing Monitorix from $SOURCE_DIR with base_dir=$BASE_DIR"

# Create necessary directories
print_info "Creating directories..."
mkdir -p /usr/bin
mkdir -p /etc/monitorix/conf.d
mkdir -p /usr/lib/monitorix
mkdir -p /usr/share/doc/monitorix
mkdir -p /usr/share/man/man5
mkdir -p /usr/share/man/man8
mkdir -p /etc/init.d
mkdir -p /etc/logrotate.d
mkdir -p "$BASE_DIR"
mkdir -p "$BASE_DIR/cgi"
mkdir -p "$BASE_DIR/reports"
mkdir -p "$BASE_DIR/css"
mkdir -p "$BASE_DIR/usage"

# Install main program
print_info "Installing main program..."
if [ -f "$SOURCE_DIR/monitorix" ]; then
    cp "$SOURCE_DIR/monitorix" /usr/bin/
    chmod 755 /usr/bin/monitorix
    print_success "monitorix copied to /usr/bin/"
else
    print_warning "monitorix file not found in $SOURCE_DIR"
fi

# Install CGI
print_info "Installing CGI..."
if [ -f "$SOURCE_DIR/monitorix.cgi" ]; then
    cp "$SOURCE_DIR/monitorix.cgi" "$BASE_DIR/cgi/"
    chmod 755 "$BASE_DIR/cgi/monitorix.cgi"
    print_success "monitorix.cgi copied to $BASE_DIR/cgi/"
else
    print_warning "monitorix.cgi file not found in $SOURCE_DIR"
fi

# Install configuration file if not exists
print_info "Installing configuration..."
if [ -f "$SOURCE_DIR/monitorix.conf" ]; then
    if [ ! -f /etc/monitorix/monitorix.conf ]; then
        cp "$SOURCE_DIR/monitorix.conf" /etc/monitorix/
        chmod 644 /etc/monitorix/monitorix.conf
        print_success "monitorix.conf copied to /etc/monitorix/"
    else
        print_warning "/etc/monitorix/monitorix.conf already exists, not overwritten"
    fi
else
    print_warning "monitorix.conf file not found in $SOURCE_DIR"
fi

# Install Perl modules
print_info "Installing Perl modules..."
if [ -d "$SOURCE_DIR/lib" ]; then
    cp -r "$SOURCE_DIR/lib"/* /usr/lib/monitorix/
    chmod -R 644 /usr/lib/monitorix/*.pm
    print_success "Perl modules copied to /usr/lib/monitorix/"
else
    print_warning "lib directory not found in $SOURCE_DIR"
fi

# Install documentation
print_info "Installing documentation..."
for doc in Changes COPYING README README.BSD README.nginx; do
    if [ -f "$SOURCE_DIR/$doc" ]; then
        cp "$SOURCE_DIR/$doc" /usr/share/doc/monitorix/
        chmod 644 "/usr/share/doc/monitorix/$doc"
    fi
done

# Install example scripts and configs
if [ -d "$SOURCE_DIR/docs" ]; then
    for file in monitorix-alert.sh htpasswd.pl monitorix.spec; do
        if [ -f "$SOURCE_DIR/docs/$file" ]; then
            cp "$SOURCE_DIR/docs/$file" /usr/share/doc/monitorix/
            chmod 644 "/usr/share/doc/monitorix/$file"
        fi
    done
fi

# Install logrotate script
if [ -f "$SOURCE_DIR/docs/monitorix.logrotate" ]; then
    cp "$SOURCE_DIR/docs/monitorix.logrotate" /etc/logrotate.d/monitorix
    chmod 644 /etc/logrotate.d/monitorix
    print_success "logrotate script installed"
fi

# Install logos and favicon
print_info "Installing logos..."
for logo in logo_bot.png logo_top.png monitorixico.png; do
    if [ -f "$SOURCE_DIR/$logo" ]; then
        cp "$SOURCE_DIR/$logo" "$BASE_DIR/"
        chmod 644 "$BASE_DIR/$logo"
    fi
done

# Install man pages
print_info "Installing man pages..."
if [ -f "$SOURCE_DIR/man/man5/monitorix.conf.5" ]; then
    cp "$SOURCE_DIR/man/man5/monitorix.conf.5" /usr/share/man/man5/
    chmod 644 /usr/share/man/man5/monitorix.conf.5
    print_success "monitorix.conf.5 manpage installed"
fi

if [ -f "$SOURCE_DIR/man/man8/monitorix.8" ]; then
    cp "$SOURCE_DIR/man/man8/monitorix.8" /usr/share/man/man8/
    chmod 644 /usr/share/man/man8/monitorix.8
    print_success "monitorix.8 manpage installed"
fi

# Install HTML reports if available
if [ -d "$SOURCE_DIR/reports" ]; then
    cp -r "$SOURCE_DIR/reports"/* "$BASE_DIR/reports/" 2>/dev/null || true
    chmod -R 644 "$BASE_DIR/reports"/* 2>/dev/null || true
    print_success "HTML reports copied"
fi

# Install CSS files
print_info "Installing CSS themes..."
if [ -d "$SOURCE_DIR/css" ]; then
    cp -r "$SOURCE_DIR/css"/* "$BASE_DIR/css/" 2>/dev/null || true
    chmod -R 644 "$BASE_DIR/css"/* 2>/dev/null || true
    print_success "CSS files copied"
fi

# Install usage directory if available
if [ -d "$SOURCE_DIR/usage" ]; then
    cp -r "$SOURCE_DIR/usage"/* "$BASE_DIR/usage/" 2>/dev/null || true
    print_success "usage directory copied"
fi

# Create monitorix user if not exists
print_info "Creating user..."
if ! getent passwd monitorix >/dev/null 2>&1; then
    adduser -S -D -H -s /sbin/nologin -g "Monitorix user" monitorix
    print_success "monitorix user created"
fi

# Set correct ownership
print_info "Setting permissions..."
chown -R root:root /usr/bin/monitorix /usr/lib/monitorix /etc/monitorix
chown -R monitorix:monitorix "$BASE_DIR"
chmod 755 "$BASE_DIR"

# Create log directory
mkdir -p /var/log/monitorix
chown monitorix:monitorix /var/log/monitorix
chmod 755 /var/log/monitorix

print_success "Installation completed!"
echo
print_info "Installation paths:"
echo "  - Main binary: /usr/bin/monitorix"
echo "  - Configuration: /etc/monitorix/monitorix.conf"
echo "  - Modules: /usr/lib/monitorix/"
echo "  - Base directory: $BASE_DIR"
echo "  - CGI: $BASE_DIR/cgi/monitorix.cgi"
echo "  - Logs: /var/log/monitorix/"
echo
print_info "Next steps:"
echo "  1. Edit /etc/monitorix/monitorix.conf if needed"
echo "  2. Install the OpenRC script in /etc/init.d/monitorix"
echo "  3. Start the service: rc-service monitorix start"
echo "  4. Enable at boot: rc-update add monitorix default"
echo
print_info "Web interface available at: http://localhost:8080/cgi/monitorix.cgi"
