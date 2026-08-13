# iSH582 Linux/CUPS driver

This directory contains the Linux/CUPS implementation for iSH582 / 581P,
581PW and 801P thermal printers. The Windows package used Unidrv and GPD files;
the printer protocol is visible in those GPD definitions:

- ESC/POS GS `v 0` raster command (`1d 76 30 00`)
- 203 dpi
- 581P/581PW: 56 mm media, 384 printable dots, approximately 48 mm
- 801P/801PW: 80 mm media, 576 printable dots, approximately 72 mm
- USB, RAW network and serial transports

The filter converts CUPS PDF input to monochrome PBM at 203 dpi. Receipt-sized
pages are scaled as complete pages to preserve margins and vertical geometry;
only trailing white rows are removed. Oversized pages are cropped to ink before
scaling. It emits the same raster blocks used by the GPD protocol and does not
use Windows DLLs.

## Recommended installation

From repository root:

```bash
sudo sh ./install.sh 581 usb
```

The installer supports Debian/Ubuntu, Fedora/RHEL, Arch, openSUSE and Alpine.
It installs dependencies, detects the USB URI, installs the PPD and configures
the CUPS queue.

## Network installation

```bash
sudo sh ./install.sh 581 socket://PRINTER_IP:9100
sudo sh ./install.sh 801 socket://PRINTER_IP:9100
lp -d ish582-581 document.pdf
```

TCP port 9100 is the usual RAW transport for ESC/POS printers. Verify the
printer IP and port if the connection fails.

## USB or serial diagnostics

```bash
lpinfo -v | grep -Ei 'usb|serial|ish|gprinter|terow'
sudo sh ./fedora/install-fedora.sh 581 'usb://REAL_URI'
```

Direct transport testing:

```bash
ish582-send tcp://PRINTER_IP:9100 --model 581
ish582-send /dev/usb/lp0 --model 581
```

Print density is exposed as `density=0..9`, matching the GPD commands. Restart
the printer after changing density settings.

## Tests

```bash
python3 -m unittest discover -s fedora/tests -v
cupstestppd -W all fedora/cups/ish582-581.ppd fedora/cups/ish582-801.ppd
```
