# ISH58driverforlinux

Driver Linux/CUPS per stampanti termiche iSH582 / Gprinter 581P, 581PW, 801P
e 801PW. Protocollo raster ESC/POS ricostruito dai parametri del driver
Windows: 203 dpi, GS `v 0`, 384 punti per 581 e 576 punti per 801.

## Installazione rapida

```bash
git clone https://github.com/TonnoConsorzio/ISH58driverforlinux.git
cd ISH58driverforlinux
sudo sh ./install.sh 581 usb
```

Per stampante 80 mm:

```bash
sudo sh ./install.sh 801 usb
```

Per rete RAW:

```bash
sudo sh ./install.sh 581 socket://192.168.1.200:9100
```

Installer rileva automaticamente USB tramite `lpinfo`, installa dipendenze
CUPS/Poppler per Debian/Ubuntu, Fedora/RHEL, Arch, openSUSE e Alpine, configura
PPD, filtro, coda e regole udev.

## Stampa PDF

```bash
lp -d ish582-581 documento.pdf
```

Il filtro rasterizza a 203 dpi, ritaglia margini bianchi del canvas PDF e scala
il contenuto alla larghezza nativa. Gestisce PDF A4/Letter, PDF OnlyOffice,
Chrome e Firefox. Ricevute lunghe vengono inviate a blocchi USB per evitare
il blocco della stampante.

La stampa silenziosa da una pagina web resta vincolata alle policy del browser;
il driver espone normalmente la coda CUPS `ish582-581`.

## Sviluppo

```bash
python3 -m unittest discover -s fedora/tests -v
sh -n install.sh fedora/install-fedora.sh fedora/cups/ish582-581-filter fedora/cups/ish582-801-filter
cupstestppd -W all fedora/cups/ish582-581.ppd fedora/cups/ish582-801.ppd
```

Nessun modulo kernel richiesto: USB è gestito dal backend standard CUPS.
