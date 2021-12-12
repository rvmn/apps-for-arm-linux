 #!/usr/bin/env bash

echo "Hello, a few questions will be asked first, before installing the tools and fixes, so please stay with me for a moment."
RCFILE="~/.bashrc"
if [[ -f ~/.zshrc ]];  then 
    read -p "You have ZSH installed, revert back to BASH (Y/n)? " yn
    if [[ "$yn" =~ "n" ]]; then echo "leaving ZSH installed"; else
        sudo apt-get purge -y armbian-zsh
        BASHLOCATION=$(grep /bash$ /etc/shells | tail -1)
        # change shell back to bash for future users
        sudo sed -i "s|^SHELL=.*|SHELL=${BASHLOCATION}|" /etc/default/useradd
        sudo sed -i "s|^DSHELL=.*|DSHELL=${BASHLOCATION}|" /etc/adduser.conf
        # change to BASH shell for root and all normal users
        sudo awk -F'[/:]' '{if ($3 >= 1000 && $3 != 65534 || $3 == 0) print $1}' /etc/passwd | xargs -L1 chsh -s $(grep /bash$ /etc/shells | tail -1)
        rm ~/.zshrc
        echo "\nYour default shell was switched to: \Z1BASH\Z0\n\nPlease reboot." 
        read -p "Would you like to quit this app now? (Y/n)" yn
        if [[ "$yn" =~ "n" ]]; then echo "continuing app"; else exit;fi
    fi
fi
read -p "Install git SSH-keypair for connecting your git account (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then GITADD=false;    else GITADD=true;fi

if [[ $(uname -n) =~ "JingOS" ]]; then
 read -p "Install Android support (japm) (Y/n)? " yn
 if [[ "$yn" =~ "n" ]]; then ANDROID=false;    else ANDROID=true;fi
fi

read -p "Install Ulauncher (launcher to type and do tasks) (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then ULAUNCHER=false;    else ULAUNCHER=true;fi

read -p "Install Docker (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then DOCKER=false;    else DOCKER=true;fi

read -p "Install Stremio (Streaming app) (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then STREMIO=false;    else STREMIO=true;fi

read -p "Install Inkscape (SVG editor) (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then INKSCAPE=false;    else INKSCAPE=true;fi

read -p "Install Boxy-SVG (SVG editor) (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then BOXYSVG=false;    else BOXYSVG=true;fi

read -p "Install Sublime Text (Code editor) (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then SUBLIME=false;    else SUBLIME=true;fi

read -p "Install Visual Studio Code (Code editor) (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then VSCODE=false;    else VSCODE=true;fi

read -p "Install Freetube (Ad-free YouTube streamer) (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then FREETUBE=false;    else FREETUBE=true;fi

read -p "Install NVM and NodeJS (JS V8 framework)  (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then NVM=false;    else NVM=true;fi

read -p "Install ZSH (Advanced shell)  (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then ZSH=false;    else ZSH=true;fi

read -p "Install Apt aliases (apt manager aliases, see ahelp)  (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then ALIASES=false;    else ALIASES=true;fi


# Pi-Apps needs to be reworked since it doesnt work OOB, but copying install links and manual installation works as its arm64 compatible

##   read -p "Install Pi-Apps (app installer) (Y/n)? " yn
#    if [[ "$yn" =~ "Y" ]]; then make install; fi
#   if [[ "$yn" =~ "n" ]]; then ; fi
#  echo "Answer Y/n."
#
read -p"Do you wish to install updates? (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then UPDATES=false;    else UPDATES=true; fi

# Fix OS-release  to be ubuntu for some repos
sudo sed -i 's/ID=jingos/ID=ubuntu/' /etc/os-release

# Fix auth for xserver to allow sudo running gui apps from cli like 'sudo gedit file.txt'
xhost + localhost

# Add armbian repo
echo "deb [arch=arm64] http://apt.armbian.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/armbian.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 9F0E78D5

# Install basic packages
sudo apt update
sudo apt install -y git build-essential curl nano ca-certificates wget at-spi2-core ubuntu-restricted-extras unzip
if [[ $(uname -n) =~ "JingOS" ]]; then sudo apt install -y selinux-policy-default systemsettings; fi

# Fix SELinux setting to disabled, otherwise may cause misunderstanding in some programs (Sublime text f.e.)
sudo sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config

apt_shortcuts(){
    tee -a $RCFILE>>/dev/null <<EOT
# apt aliases
alias ai='echo "install package">/dev/null;sudo apt install -y'
alias au='echo "uninstall package">/dev/null;sudo apt remove'
alias al='echo "list all packages installed">/dev/null;sudo apt list --installed'
alias av='echo "list all versions of a package (regexable)">/dev/null;sudo apt-show-versions -a -r'
alias ahelp='echo "show help (this)">/dev/null;fahelp'
fahelp() { alias | grep 'alias a' | sed 's/^\([^=]*\)=[^"]*"\([^"]*\)">\/dev\/null.*/\1                =>                \2/'| sed "s/['|\']//g" | sort; }
EOT
}

japm_shortcuts(){
    tee -a $RCFILE>>/dev/null <<EOT
# japm aliases
alias ji='echo "install package">/dev/null;sudo japm install -i'
alias ju='echo "uninstall package">/dev/null;sudo japm uninstall'
alias jl='echo "list all packages installed">/dev/null;japm list -a'
alias jhelp='echo "show help (this)">/dev/null;fjhelp'
fjhelp() { alias | grep 'alias a' | sed 's/^\([^=]*\)=[^"]*"\([^"]*\)">\/dev\/null.*/\1                =>                \2/'| sed "s/['|\']//g" | sort; }
EOT
}

docker_shortcuts(){
    tee -a $RCFILE>>/dev/null <<EOT
# docker aliases
alias dq='echo "search docker ecosystem">/dev/null;docker search'
alias dl='echo "get latest container ID">/dev/null;docker ps -l -q'
alias dr='echo "run an image (daemonized)">/dev/null;fdr'
alias dp='echo "show running containers">/dev/null;docker ps'
alias dpa='echo "show all containers">/dev/null;docker ps -a'
alias di='echo "show all images">/dev/null;docker images'
alias din='echo "inspect a container">/dev/null;docker inspect'
alias din='echo "inspect a container">/dev/null;docker attach'
alias dms='echo "start monitoring container (ctrl-c to stop)">/dev/null;docker attach'
alias dii='echo "get a containers image">/dev/null;docker inspect --format "{{ .Config.Image }} "'
alias dip='echo "get a containers IP">/dev/null;docker inspect --format "{{ .NetworkSettings.IPAddress }} "'
alias dipl='echo "get last run containers IP">/dev/null;docker inspect --format "{{ .NetworkSettings.IPAddress }} $(dl)"'
alias dkd='echo "run daemonized container">/dev/null;docker run -d -P'
alias drmpf='echo "stop and remove all containers">/dev/null;docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'
alias dri='echo "remove an image">/dev/null;docker rmi'
alias drp='echo "remove a container">/dev/null;docker rm'
alias ds='echo "start a container">/dev/null;fds'
alias dst='echo "stop a container">/dev/null;fdst'
alias dsh='echo "run shell in a container or image">/dev/null;fdsh'   
alias dish='echo "run shell in an entrypoint container">/dev/null;fdish'
alias dind='echo "run command in an entrypoint container">/dev/null;fdind'
alias dcm='echo "commit a container to image">/dev/null;fdcm'
alias dsa='echo "start all containers">/dev/null;fdsa'
alias dsta='echo "stop all containers">/dev/null;fdsta'
alias dsav='echo "stop and save a container to an image">/dev/null;fdsav'
alias dsavi='echo "stop, save a container to an image, and start it again">/dev/null;fdsavi'
alias drmp='echo "remove all containers, except running ones">/dev/null;fdprm'
alias drmi='echo "remove all images, except ones used">/dev/null;fdrmi'
alias dbu='echo "build dockerfile">/dev/null;fdbu'
alias dalias='echo "add an alias">/dev/null;fdalias'
alias ralias='echo "rename an alias">/dev/null;fralias'
alias dhelp='echo "show all aliases(this)">/dev/null;fdhelp'
fds() { docker start $(echo ${1-$(dl)}); }
fdr() { docker run -itd $1; }
fdst() { docker stop $(echo ${1-$(dl)}); }
fdsh() { docker run -it $1 /bin/bash; }
fdish() { docker run --privileged -it --entrypoint=/bin/bash $1 -i; }
fdind() { docker run --privileged -it --entrypoint=$2 $1; }
fdcm() { docker commit $1 $2; }
fdsa() { docker start $(docker ps -a -q); }
fdsta() { docker stop $(docker ps -a -q); }
fdsav() { dst $([ -z $2 ] && echo $(dl) || echo $1); dcm $([ -z $2 ] && echo $(dl) || echo $1) $2; }
fdsavs() { dsav $([ -z $2 ] && echo $(dl) || echo $1) $2; ds $([ -z $2 ] && echo $(dl) || echo $1); }
fdsavi() { dst $1; dcm $(dl) $(din $()); }
fdprm() { docker rm $(docker ps -a -q); }
fdrmi() { docker rmi $(docker images -q); }
fdbu() { docker build -t=$1; }
fdhelp() { alias | grep 'alias d' | sed 's/^\([^=]*\)=[^"]*"\([^"]*\)">\/dev\/null.*/\1                =>                \2/'| sed "s/['|\']//g" | sort; }
fdalias() { grep -q $1 ~/.bashrc && sed "s/$1.*/$1(){ $2 ; }/" -i ~/.bashrc || sed "$ a\\$1(){ $2 ; }" -i ~/.bashrc; source ~/.bashrc; }
fralias() { sed -i "s/$1/$2/" ~/.bashrc; source ~/.bashrc; }
EOT
} 

nvm(){
    #Install nvm manager:
    export NVM_DIR="$HOME/.nvm"
    mkdir -p "$NVM_DIR"
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash || error "Failed to install nvm!"
    source "${DIRECTORY}/api"
    if [ "$arch" == 32 ];then
      #armhf, so patch nvm script to forcibly use armhf
      sed -i 's/^  nvm_echo "${NVM_ARCH}"/  NVM_ARCH=armv7l ; nvm_echo "${NVM_ARCH}"/g' "$NVM_DIR/nvm.sh"
    fi

    #remove original nvm stuff from bashrc
    sed -i '/NVM_DIR/d' ~/.bashrc
    echo 'if [ -s "$HOME/.nvm/nvm.sh" ] && [ ! "$(type -t __init_nvm)" = function ]; then
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
      declare -a __node_commands=("nvm" "node" "npm" "yarn" "gulp" "grunt" "webpack")
      function __init_nvm() {
        for i in "${__node_commands[@]}"; do unalias $i; done
        . "$NVM_DIR"/nvm.sh
        unset __node_commands
        unset -f __init_nvm
      }
      for i in "${__node_commands[@]}"; do alias $i="__init_nvm && "$i; done
    fi' > ~/.node_bashrc
    echo ". ~/.node_bashrc" >> $RCFILE

    # One time use, since `source ~/.bashrc` not working
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    # Install latest nodejs
    nvm install node || error "Failed to install node.js with nvm!"
}

inkscape(){
    sudo apt update
    sudo apt install -y inkscape
}

stremio(){
    wget -qO- https://raw.githubusercontent.com/rvmn/stremio-arm/main/stremio-build.sh | bash
}

 ulauncher(){
    sudo apt install -y https://github.com/Ulauncher/Ulauncher/releases/download/5.14.1/ulauncher_5.14.1_all.deb gir1.2-appindicator3-0.1 python3-distutils-extra python3-levenshtein python3-websocket
 }

vscode(){
    sudo apt install -y https://aka.ms/linux-arm64-deb
}

boxysvg(){
    wget -qO- https://raw.githubusercontent.com/Botspot/Boxy-SVG-RPi/main/install.sh | bash
}

zsh(){
    sudo apt-get install -y armbian-zsh
    # add all non-root users to zsh
    awk -F'[/:]' '{if ($3 >= 1000 && $3 != 65534 || $3 == 0) print $1}' /etc/passwd | xargs -L1 sudo chsh -s $(grep /zsh$ /etc/shells | tail -1)
}

# Add git SSH creds to system
gitadd(){
    FILE="/home/$USER/.ssh/known_hosts"
    if [ -f "$FILE" ]; then rm $FILE; fi
    read -p "Enter your email address:" EMAIL 
    read -p "Enter your user name:" USER
    git config --global user.email $EMAIL
    git config --global user.name $USER
    ssh-keygen -t ed25519 -C $EMAIL
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    cat ~/.ssh/id_ed25519.pub
    read -p "Installed the SSH creds, copy the previous line fully and paste in the browser, click enter to open the browser"
    /usr/bin/chromium-browser-stable --new-window https://github.com/settings/keys
    echo "Remember to use the SSH URL (git@github.com/username/repo.git)"
}

# Install Docker
docker(){
    curl -fsSL "https://download.docker.com/linux/debian/gpg" | sudo apt-key add -qq - > /dev/null 2>&1
    debconf-sudo apt-progress -- sudo apt-get update
    echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu focal stable" > \
    /etc/sudo apt/sources.list.d/docker.list
    debconf-sudo apt-progress -- sudo apt-get install -y -qq --no-install-recommends docker.io
    read -p "Install Docker aliases (bash aliases, use command 'dhelp' to view them) (Y/n)? " yn
    if [[ "$yn" =~ "n" ]]; then echo '';  else docker_shortcuts;fi
}

# Install android
android(){
    sudo apt install -y jappmanagerd japm android-compatible-env
    read -p "Install japm aliases (bash aliases, use command 'ahelp' to view them) (Y/n)? " yn
    if [[ "$yn" =~ "n" ]]; then echo '';  else japm_shortcuts;fi
}

# Install Sublime Text
sublimetext(){
    sudo apt install -y snapd
    sudo systemctl enable snapd.service
    sudo systemctl start snapd.service
    sudo snap install sublime-text --classic
}


# Install Freetube
freetube(){
    sudo dpkg -i $(curl -w "%{filename_effective}" -LO https://sudo apt.raspbian-addons.org/debian/pool/main/f/freetube/$(curl -s https://sudo apt.raspbian-addons.org/debian/pool/main/f/freetube/ | egrep -io "freetube_.*_arm64.deb" | head -n 1 )) && rm freetube_*.deb
}

# Update system
updates(){
    sudo apt update && sudo apt upgrade
}
if $ZSH ; then zsh; fi
if [[ -f ~/.zshrc ]];  then RCFILE="~/.zshrc"; fi
if $GITADD ; then gitadd; fi
if $STREMIO ; then stremio; fi
if $SUBLIME; then sublimetext; fi
if $VSCODE ; then vscode; fi
if $ULAUNCHER ; then ulauncher; fi
if $INKSCAPE ; then inkscape; fi
if $FREETUBE ; then freetube; fi
if $BOXYSVG ; then boxysvg; fi
if $NVM; then nvm; fi
if $ALIASES; then apt_shortcuts; fi
if $DOCKER ; then docker; fi
if $ANDROID ; then android; fi 
if $UPDATES ; then updates; fi 

# fix scaling issues on Jingpad
#sudo replace "Exec=" "Exec=env QT_SCALE_FACTOR=1.2 GDK_DPI_SCALE=1.5 GDK_SCALE=1" /usr/share/applications/[^o].*.desktop

echo "Finished installing, have fun and see jingpad telegram group for help"
if $ZSH;then echo "Your default shell was switched to ZSH. Please reboot";fi
