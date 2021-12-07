#!/usr/bin/bash
# check for root privileges
#
[ "$UID" -eq 0 ] || exec sudo bash "$@"

USER=$(ls /home/ |  egrep -io ".*$")

echo "Hello, a few questions will be asked first, before installing the tools and fixes, so please stay with me for a moment."
while true; do
    read -p "Is your regular user named: $USER  (${yesword} / ${noword})? " yn
    if [[ "$yn" =~ $noexpr ]]; then read -p "Give the name of user to install user-defined stuff on:  " USER;exit; fi
    echo "Answer ${yesword} / ${noword}."
done

GITADD=false
DOCKER=false
STREMIO=false
INKSCAPE=false
FREETUBE=false
UPDATES=false

# set local yes and no words
set -- $(locale LC_MESSAGES)
yesptrn="$1"; noptrn="$2"; yesword="$3"; noword="$4"

while true; do
    read -p "Install git SSH-keypair for connecting your git account (${yesword} / ${noword})? " yn
    if [[ "$yn" =~ $yesexpr ]]; then GITADD=true; exit; fi
    if [[ "$yn" =~ $noexpr ]]; then exit; fi
    echo "Answer ${yesword} / ${noword}."
done

while true; do
    read -p "Install Android support (japm) (${yesword} / ${noword})? " yn
    if [[ "$yn" =~ $yesexpr ]]; then ANDROID=true; exit; fi
    if [[ "$yn" =~ $noexpr ]]; then exit; fi
    echo "Answer ${yesword} / ${noword}."
done

while true; do
    read -p "Install Docker (${yesword} / ${noword})? " yn
    if [[ "$yn" =~ $yesexpr ]]; then DOCKER=true; exit; fi
    if [[ "$yn" =~ $noexpr ]]; then exit; fi
    echo "Answer ${yesword} / ${noword}."
done

while true; do
    read -p "Install Stremio (Streaming app) (${yesword} / ${noword})? " yn
    if [[ "$yn" =~ $yesexpr ]]; then STREMIO=true; exit; fi
    if [[ "$yn" =~ $noexpr ]]; then exit; fi
    echo "Answer ${yesword} / ${noword}."
done

while true; do
    read -p "Install Inkscape (SVG editor) (${yesword} / ${noword})? " yn
    if [[ "$yn" =~ $yesexpr ]]; then INKSCAPE=true; exit; fi
    if [[ "$yn" =~ $noexpr ]]; then exit; fi
    echo "Answer ${yesword} / ${noword}."
done

while true; do
    read -p "Install Freetube (Ad-free YouTube streamer) (${yesword} / ${noword})? " yn
    if [[ "$yn" =~ $yesexpr ]]; then FREETUBE=true; exit; fi
    if [[ "$yn" =~ $noexpr ]]; then exit; fi
    echo "Answer ${yesword} / ${noword}."
done

# Pi-Apps needs to be remodeled since it doesnt work OOB, but copying install links and manual installation works as its arm64 compatible

#while true; do
#   read -p "Install Pi-Apps (app installer) (${yesword} / ${noword})? " yn
#    if [[ "$yn" =~ $yesexpr ]]; then make install; exit; fi
#   if [[ "$yn" =~ $noexpr ]]; then exit; fi
#  echo "Answer ${yesword} / ${noword}."
#done

echo "Do you wish to install all JingOS updates?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) UPDATES=true; break;;
        No ) exit;;
    esac
done

# Fix OS-release  to be ubuntu for some repos
sed -i 's|ID=jingos|ID=ubuntu' /etc/os-release

# Fix SELinux setting to disabled, otherwise may cause misunderstanding in some programs (Sublime text f.e.)
sed -i 's|SELINUX=permissive|SELINUX=disabled'  /etc/selinux/config

if $GITADD ; then gitadd() ; fi
# Install basic packages
apt update
apt git build-essential curl nano  selinux-policy-default ca-certificates 
if $DOCKER ; then docker() ; fi
if $STREMIO ; then stremio() ; fi
if $INKSCAPE ; then inkscape() ; fi
if $FREETUBE ; then freetube() ; fi
if $ANDROID ; then android() ; fi    
if $UPDATES ; then updates() ; fi    

inkscape(){
    apt update
    apt install -y inkscape
}

stremio(){
    wget -qO- https://raw.githubusercontent.com/rvmn/stremio-arm/main/stremio-build.sh | bash
}

# Add git SSH creds to system
gitadd(){
    FILE="/home/$USER/.ssh/known_hosts"
    if [ -f "$FILE" ]; then rm $FILE; fi
    su - $USER -c 'read -p "Enter your email address:" EMAIL && ssh-keygen -t ed25519 -C $EMAIL &&  eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519 && cat ~/.ssh/id_ed25519.pub'
    read -p "Installed the SSH creds, copy the previous line fully and paste in the browser, click enter to open the browser"
    /usr/bin/chromium-browser-stable --new-window https://github.com/settings/keys
    echo "Remember to use the SSH URL (git@github.com/username/repo.git)"
}

# Install Docker
docker(){
    curl -fsSL "https://download.docker.com/linux/debian/gpg" | apt-key add -qq - > /dev/null 2>&1
    debconf-apt-progress -- apt-get update
    echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu focal stable" > \
    /etc/apt/sources.list.d/docker.list
    debconf-apt-progress -- apt-get install -y -qq --no-install-recommends docker.io
    while true; do
        read -p "Install Docker shortcuts (bash aliases, use command 'dhelp' to view them) (${yesword} / ${noword})? " yn
        if [[ "$yn" =~ $yesexpr ]]; then docker_shortcuts(); exit; fi
        if [[ "$yn" =~ $noexpr ]]; then exit; fi
        echo "Answer ${yesword} / ${noword}."
    done
}

# Install android
android(){
    apt install jappmanagerd japm android-compatible-env
    while true; do
        read -p "Install japm shortcuts (bash aliases, use command 'ahelp' to view them) (${yesword} / ${noword})? " yn
        if [[ "$yn" =~ $yesexpr ]]; then japm_shortcuts(); exit; fi
        if [[ "$yn" =~ $noexpr ]]; then exit; fi
        echo "Answer ${yesword} / ${noword}."
    done
}

# Install Sublime Text
sublimetext(){
    apt install snapd
    systemctl enable snapd.service
    systemctl start snapd.service
    snap install sublime-text --classic
}


# Install Freetube
freetube(){
    dpkg -i $(curl -w "%{filename_effective}" -LO https://apt.raspbian-addons.org/debian/pool/main/f/freetube/$(curl -s https://apt.raspbian-addons.org/debian/pool/main/f/freetube/ | egrep -io "freetube_.*_arm64.deb" | head -n 1 )) && rm freetube_*.deb
}

# Update system
updates(){
    apt update && apt upgrade
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

echo "Finished installing, have fun and see jingpad telegram group for help"