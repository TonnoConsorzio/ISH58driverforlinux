# ISH58driverforlinux

Linux/CUPS driver for iSH582 / Gprinter 581P, 581PW, 801P and 801PW thermal
printers. Raster protocol reconstructed from the Windows driver parameters:
203 dpi, ESC/POS GS `v 0`, 384 printhead dots for model 581 and 576 dots for model 801.

## Quick installation

```bash
git clone https://github.com/TonnoConsorzio/ISH58driverforlinux.git
cd ISH58driverforlinux
sudo sh ./install.sh 581 usb
```

For the 80 mm model:

```bash
sudo sh ./install.sh 801 usb
```

For a RAW network printer:

```bash
sudo sh ./install.sh 581 socket://192.168.1.200:9100
```

The installer automatically detects USB through `lpinfo`, installs CUPS and
Poppler dependencies on Debian/Ubuntu, Fedora/RHEL, Arch, openSUSE and Alpine,
then configures the PPD, filter, queue and udev rules.

## Printing PDFs

```bash
lp -d ish582-581 document.pdf
```

The 581 printer uses 56 mm media with approximately 48 mm printable width.
The 801 printer uses 80 mm media with approximately 72 mm printable width.
The filter rasterizes at 203 dpi, keeps receipt-sized PDF geometry, scales the
full page to printhead width, and trims only trailing white rows. Oversized
A4/Letter pages use ink cropping before scaling. This prevents Firefox from
cutting a 56 mm x 250 mm receipt while keeping receipt height variable.
OnlyOffice PDFs, images printed through Firefox, Chrome and Firefox output are
supported. Long receipts are sent in USB blocks to reduce printer lockups.

Silent printing from a normal web page remains controlled by browser security
policies; the driver exposes the standard CUPS queue `ish582-581`.

## Development

```bash
python3 -m unittest discover -s fedora/tests -v
sh -n install.sh fedora/install-fedora.sh fedora/cups/ish582-581-filter fedora/cups/ish582-801-filter
cupstestppd -W all fedora/cups/ish582-581.ppd fedora/cups/ish582-801.ppd
```

No kernel module is required: USB is handled by the standard CUPS backend.
