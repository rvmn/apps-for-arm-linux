# apps-for-arm-linux
Script for Ubuntu/Debian Linux ARM (arm64 or armhf) that installs usefull apps and adds some system fixes

## Apps included in installer
- Docker
- Stremio
- Sublime Text (REMOVED, uses snap so needs reboot making it not 'one-simple-install compatible', searching for alternatives)
- VSCode
- Ulauncher
- Freetube
- Inkscape
- Boxy-SVG
- Upgrades (firmware)
- Bash Aliases (quick type)
- Docker aliases
- ZSH
- NodeJS

- For Jingpad A1 (https://jingos-official.myshopify.com/): Android support (japm) and japm-aliases

## Run
```
wget -O - https://raw.githubusercontent.com/rvmn/apps-for-arm-linux/main/run.sh > /tmp/run.sh && sudo chmod +x /tmp/run.sh && /tmp/run.sh && sudo rm /tmp/run.sh
```
## Issues

Upgrade might download a lot and sometimes fails halfway with some error. As it is done last it doesnt cause any problem for other installs.

Just run 'sudo apt upgrade -y' again

## Credits

Pi-apps: https://github.com/Botspot/pi-apps
Armbian-config: https://github.com/armbian/config
