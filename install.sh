#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
MODEL=${1:-581}
URI=${2:-usb}

case "$MODEL" in
    581|801) ;;
    *) echo "Usage: sudo sh $0 [581|801] [usb|CUPS_URI]" >&2; exit 2 ;;
esac

if [ "$(id -u)" -ne 0 ]; then
    exec sudo sh "$0" "$@"
fi

if [ "${ISH582_NO_DEPS:-0}" != 1 ]; then
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get install -y cups cups-client cups-filters poppler-utils
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y cups cups-client cups-filters poppler-utils
    elif command -v pacman >/dev/null 2>&1; then
        pacman -Sy --needed --noconfirm cups cups-filters poppler
    elif command -v zypper >/dev/null 2>&1; then
        zypper --non-interactive install cups cups-filters poppler-tools
    elif command -v apk >/dev/null 2>&1; then
        apk add cups cups-filters poppler-utils
    else
        echo "Unsupported distribution: install CUPS, cups-filters and pdftoppm manually." >&2
    fi
fi

for command in lpadmin lpinfo cupsenable cupsaccept pdftoppm; do
    command -v "$command" >/dev/null 2>&1 || {
        echo "Missing command: $command" >&2
        exit 3
    }
done

if command -v systemctl >/dev/null 2>&1; then
    systemctl enable --now cups.service 2>/dev/null || systemctl start cups.service 2>/dev/null || true
fi

SERVERBIN=$(cups-config --serverbin 2>/dev/null || printf '%s' /usr/lib/cups)
DATADIR=$(cups-config --datadir 2>/dev/null || printf '%s' /usr/share/cups)
FILTER_DIR="$SERVERBIN/filter"
MODEL_DIR="$DATADIR/model"
install -d -m 0755 "$FILTER_DIR" "$MODEL_DIR"
install -m 0755 "$ROOT/fedora/cups/ish582-filter" "$FILTER_DIR/ish582-filter"
install -m 0755 "$ROOT/fedora/cups/ish582-$MODEL-filter" "$FILTER_DIR/ish582-$MODEL-filter"
install -m 0644 "$ROOT/fedora/cups/ish582-$MODEL.ppd" "$MODEL_DIR/ish582-$MODEL.ppd"

if [ -d /etc/udev/rules.d ]; then
    install -m 0644 "$ROOT/fedora/udev/70-ish582.rules" /etc/udev/rules.d/70-ish582.rules
    udevadm control --reload-rules 2>/dev/null || true
fi

if command -v restorecon >/dev/null 2>&1; then
    restorecon -v "$FILTER_DIR/ish582-filter" "$FILTER_DIR/ish582-$MODEL-filter" \
        "$MODEL_DIR/ish582-$MODEL.ppd" 2>/dev/null || true
fi

case "$URI" in
    usb)
        URI=$(lpinfo -v | awk '$1 == "direct" && $2 ~ /^usb:\/\// { print $2; exit }')
        [ -n "$URI" ] || { echo "No USB printer found. Run lpinfo -v." >&2; exit 4; }
        ;;
    *URI_COMPLETO*|*URI_RILEVATO*|*NUOVO_IP*)
        echo "Invalid placeholder URI." >&2
        exit 2
        ;;
esac

PAGE_SIZE=Roll58
[ "$MODEL" = 801 ] && PAGE_SIZE=Roll80
lpadmin -p "ish582-$MODEL" -E -v "$URI" -P "$MODEL_DIR/ish582-$MODEL.ppd" \
    -o printer-is-shared=false -o Resolution=203dpi \
    -o PageSize="$PAGE_SIZE" -o print-scaling=none
cupsenable "ish582-$MODEL"
cupsaccept "ish582-$MODEL"

echo "Installed ish582-$MODEL"
echo "URI: $URI"
echo "Print: lp -d ish582-$MODEL document.pdf"
