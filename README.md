# zebra-plugin-btprint
Print to Zebra over bluetooth from Android and iOS

How to use:
1. Connect to printer: 
2. Print command: 

Guide to print layout: http://labelary.com/viewer.html

**Dynabrain setup**

- Download Zebra Printer setup utilities here -> https://www.zebra.com/gb/en/support-downloads/printer-software/printer-setup-utilities.html
- Connect via USB your printer
- Start Zebra Printer Setup and select your current printer
- Select "Configure Printer Connettivity" and select BLUETOOTH
- Select Country code: Click on "Open Communication with Printer", put the code ```! U1 setvar "wlan.country_code" "europe"``` and click "Send to printer"
- Restart printer
- Search the printer with the iOS base Bluetooth device finder and pair the printer
- Start the application, the printer will be visible and the print can be requested

Initialize has this parameters : 
- delay: int 
- wildcard: string | search for bluetooth device with this pattern
- printername: string | autoconnect with the device 
- cancelButtonName: string | cancel button name

the event 'deviceSelected' return selected device name for connection


Guide to print layout: http://labelary.com/viewer.html
