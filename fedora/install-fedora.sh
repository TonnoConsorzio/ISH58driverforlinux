#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root: sudo $0 [581|801] [URI]" >&2
    exit 1
fi

MODEL=${1:-581}
URI=${2:-}
case "$MODEL" in
    581|801) ;;
    *) echo "Invalid model: use 581 or 801" >&2; exit 2 ;;
esac

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
install -d -m 0755 /usr/lib/cups/filter /usr/share/cups/model
install -m 0755 "$ROOT/cups/ish582-filter" /usr/lib/cups/filter/ish582-filter
install -m 0755 "$ROOT/cups/ish582-$MODEL-filter" /usr/lib/cups/filter/ish582-$MODEL-filter
install -m 0644 "$ROOT/cups/ish582-$MODEL.ppd" /usr/share/cups/model/ish582-$MODEL.ppd
install -m 0755 "$ROOT/bin/ish582-send" /usr/local/bin/ish582-send

if command -v restorecon >/dev/null 2>&1; then
    restorecon -v /usr/lib/cups/filter/ish582-filter /usr/lib/cups/filter/ish582-$MODEL-filter \
        /usr/share/cups/model/ish582-$MODEL.ppd /usr/local/bin/ish582-send || true
fi

if [ -n "$URI" ]; then
    PPD=/usr/share/cups/model/ish582-$MODEL.ppd
    PAGE_SIZE=Roll58
    [ "$MODEL" = 801 ] && PAGE_SIZE=Roll80
    lpadmin -p ish582-$MODEL -E -v "$URI" -P "$PPD" -o PageSize="$PAGE_SIZE" -o Resolution=203dpi
    cupsenable ish582-$MODEL
    cupsaccept ish582-$MODEL
    if lpstat -p ISH58 >/dev/null 2>&1; then
        lpadmin -p ISH58 -E -v "$URI" -P "$PPD" -o PageSize="$PAGE_SIZE" -o Resolution=203dpi
        cupsenable ISH58
        cupsaccept ISH58
        echo "Migrated legacy queue ISH58"
    fi
    echo "Queue ish582-$MODEL configured at $URI"
else
    echo "Driver installed. Configure the queue, for example:"
    echo "  sudo lpadmin -p ish582-$MODEL -E -v socket://192.168.201.200:9100 -P /usr/share/cups/model/ish582-$MODEL.ppd"
fi
