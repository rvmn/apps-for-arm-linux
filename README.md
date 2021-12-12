# apps-for-arm-linux
Script for Linux ARM (arm64 or armhf) that installs usefull apps and adds some system fixes

## Apps included in installer
- Docker
- Stremio
- Sublime Text
- VSCode
- Ulauncher
- Freetube
- Inkscape
- Boxy-SVG
- On Jingpad: Android support (japm)
- Upgrades (firmware)
- Bash Aliases (quick type)
- Docker aliases
- On Jingpad: Japm aliases
- ZSH
- NodeJS

## Run
```
wget -O /tmp/run.sh https://raw.githubusercontent.com/rvmn/jingpad-init/main/run.sh& sudo chmod +x /tmp/run.sh && /tmp/run.sh && sudo rm /tmp/run.sh
```
## Issues

sublime text requires snapd, it will install it if not found. But it will crash the script because it requires a reboot.
solution: reboot and rerun the script with the same settings

## Credits

Pi-apps: https://github.com/Botspot/pi-apps
Armbian-config: https://github.com/armbian/config
