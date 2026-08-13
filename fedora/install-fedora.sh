#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
    echo "Esegui come root: sudo $0 [581|801] [URI]" >&2
    exit 1
fi

MODEL=${1:-581}
URI=${2:-}
case "$MODEL" in
    581|801) ;;
    *) echo "Modello non valido: usa 581 oppure 801" >&2; exit 2 ;;
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
    lpadmin -p ish582-$MODEL -E -v "$URI" -P /usr/share/cups/model/ish582-$MODEL.ppd
    cupsenable ish582-$MODEL
    cupsaccept ish582-$MODEL
    echo "Coda ish582-$MODEL configurata su $URI"
else
    echo "Driver installato. Configura la coda, ad esempio:"
    echo "  sudo lpadmin -p ish582-$MODEL -E -v socket://192.168.201.200:9100 -P /usr/share/cups/model/ish582-$MODEL.ppd"
fi
