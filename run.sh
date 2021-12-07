#!/usr/bin/env bash

echo "Hello, a few questions will be asked first, before installing the tools and fixes, so please stay with me for a moment."

read -p "Install git SSH-keypair for connecting your git account (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then GITADD=false; else GITADD=true;fi

read -p "Install Android support (japm) (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then ANDROID=false; else ANDROID=true;fi

read -p "Install Docker (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then DOCKER=false;  else DOCKER=true;fi

read -p "Install Stremio (Streaming app) (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then STREMIO=false; else STREMIO=true;fi

read -p "Install Inkscape (SVG editor) (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then INKSCAPE=false; else INKSCAPE=true;fi

read -p "Install Freetube (Ad-free YouTube streamer) (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then FREETUBE=false; else FREETUBE=true;fi

# Pi-Apps needs to be remodeled since it doesnt work OOB, but copying install links and manual installation works as its arm64 compatible

#while true; do
#   read -p "Install Pi-Apps (app installer) (Y/n)? " yn
#    if [[ "$yn" =~ "Y" ]]; then make install; fi
#   if [[ "$yn" =~ "n" ]]; then ; fi
#  echo "Answer Y/n."
#done

read -p"Do you wish to install JingOS updates? (Y/n)? " yn
if [[ "$yn" =~ "n" ]]; then UPDATES=false;
else UPDATES=true; fi

# Fix OS-release  to be ubuntu for some repos
sudo sed -i 's|ID=jingos|ID=ubuntu' /etc/os-release

# Fix SELinux setting to disabled, otherwise may cause misunderstanding in some programs (Sublime text f.e.)
sudo sed -i 's|SELINUX=permissive|SELINUX=disabled'  /etc/selinux/config

if $GITADD ; then gitadd() ; fi
# Install basic packages
sudo apt update
sudo apt git build-essential curl nano  selinux-policy-default ca-certificates  wget -y
if $DOCKER ; then docker() ; fi
if $STREMIO ; then stremio() ; fi
if $INKSCAPE ; then inkscape() ; fi
if $FREETUBE ; then freetube() ; fi
if $ANDROID ; then android() ; fi    
if $UPDATES ; then updates() ; fi    

inkscape(){
    sudo apt update
    sudo apt install -y inkscape
}

stremio(){
    wget -qO- https://raw.githubusercontent.com/rvmn/stremio-arm/main/stremio-build.sh | bash
}

# Add git SSH creds to system
gitadd(){
    FILE="/home/$USER/.ssh/known_hosts"
    if [ -f "$FILE" ]; then rm $FILE; fi
    read -p "Enter your email address:" EMAIL 
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
    read -p "Install Docker shortcuts (bash aliases, use command 'dhelp' to view them) (Y/n)? " yn
    if [[ "$yn" =~ "n" ]]; then ;
    else docker_shortcuts();fi
}

# Install android
android(){
    sudo apt install jappmanagerd japm android-compatible-env
    read -p "Install japm shortcuts (bash aliases, use command 'ahelp' to view them) (Y/n)? " yn
    if [[ "$yn" =~ "n" ]]; then ; 
    else japm_shortcuts();fi
}

# Install Sublime Text
sublimetext(){
    sudo apt install snapd
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

japm_shortcuts{
    tee -a ~/.bashrc>>/dev/null <<EOT
# japm aliases
alias ai='echo "install package">/dev/null;sudo japm install -i'
alias au='echo "uninstall package">/dev/null;sudo japm uninstall'
alias al='echo "list all packages installed">/dev/null;japm list -a'
alias ahelp='echo "show help (this)">/dev/null;fahelp'
fahelp() { alias | grep 'alias a' | sed 's/^\([^=]*\)=[^"]*"\([^"]*\)">\/dev\/null.*/\1                =>                \2/'| sed "s/['|\']//g" | sort; }
EOT
}

docker_shortcuts{
    tee -a ~/.bashrc>>/dev/null <<EOT
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
echo "Finished installing, have fun and see jingpad telegram group for help"
