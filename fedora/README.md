# Driver Fedora per iSH582 / 581P / 581PW / 801P

Questa è la versione Linux/CUPS ricostruita dai file Windows forniti. Il
driver Windows usa Unidrv e i file GPD, ma il protocollo è visibile nei GPD:

- raster ESC/POS GS v 0 (1d 76 30 00);
- risoluzione 203 dpi;
- 581P/581PW: 384 punti, tipicamente rotolo da 58 mm;
- 801P: 576 punti, tipicamente rotolo da 80 mm;
- IP predefinito del tool Windows: 192.168.201.200;
- il pacchetto indica USB, rete e seriale.

Il filtro converte il PDF CUPS in PBM monocromatico a 203 dpi e invia gli
stessi blocchi raster ESC/POS usati dal GPD Windows. Non usa DLL Windows.

## Installazione di rete

    cd fedora
    sudo sh ./install-fedora.sh 581 socket://192.168.201.200:9100
    sudo sh ./install-fedora.sh 801 socket://192.168.201.200:9100
    lp -d ish582-581 /percorso/documento.pdf

La porta TCP 9100 è la convenzione RAW delle stampanti ESC/POS; nel pacchetto
Windows non è memorizzata esplicitamente. Se fallisce, controllare IP e porta.

## USB o seriale

    lpinfo -v | grep -Ei 'usb|serial|ish|gprinter|terow'
    sudo sh ./install-fedora.sh 581 'usb://...'

Test diretto senza CUPS:

    sudo sh ./install-fedora.sh 581
    ish582-send tcp://192.168.201.200:9100 --model 581
    ish582-send /dev/usb/lp0 --model 581

La concentrazione/densità è esposta come density=0..9, in linea con i
comandi presenti nel GPD. Dopo aver modificato la concentrazione occorre
riavviare la stampante, come indicato nell'immagine di supporto.

Il pacchetto Windows non contiene sorgenti né un VID/PID USB esplicito: l'URI
USB va quindi rilevato sul computer Fedora. La verifica finale richiede la
stampante collegata.

    python3 -m unittest discover -s fedora/tests
