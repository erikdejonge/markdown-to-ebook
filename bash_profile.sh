#!/usr/bin/env bash
# Set CLICOLOR if you want Ansi Colors in iTerm2
export CLICOLOR=1

# Set colors to match iTerm2 Terminal Colors
export TERM=xterm-256color
export LC_ALL=en_US.UTF-8
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=15000
export HISTFILESIZE=15000

export PYTHONIOENCODING=utf-8
export PS2="$ "
export EDITOR=/usr/bin/vi
export BLOCKSIZE=1k
export BOTO_PATH="$HOME/.boto"
export GCD_1_PORT_8080_TCP_ADDR=127.0.0.1
export LDFLAGS='-L/usr/local/opt/openssl/lib'
export CPPFLAGS='-I/usr/local/opt/openssl/include'

export GOROOT=/usr/local/opt/go/libexec
export GOPATH=$HOME/go
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/Applications/VMware\ Fusion.app/Contents/Library:$GOPATH/bin:$HOME/workspace/kubernetes/osx_amd64:$PATH
export PATH=$PATH:~/Library/depot_tools
export CXX="clang++-3.7 -stdlib=libc++"
export CXXFLAGS="$CXXFLAGS -nostdinc++ -I/usr/local/opt/llvm37/lib/llvm-3.7/include/c++/v1"
export LDFLAGS="$LDFLAGS -L/usr/local/opt/llvm37/lib/llvm-3.7/lib"

export GO_OPENCL=1

if [ $(hostname) == "cilicia.local" ]; then
	echo "cilicia.local, setting pyenv_root"
    export PYENV_ROOT=/usr/local/var/pyenv
fi

shopt -s histappend
ulimit -n 10000

if which pyenv > /dev/null; then
    eval "$(pyenv init -)";
    eval "$(pyenv virtualenv-init -)"
fi

function _httpheaders() {
     http --pretty all $1
}

function globalpython3 () {
    python3  $@
}

function _wget() {
    wget -c "$1"
}

function _allsafe() {
    if [ "" == "$1" ]; then
        path="."
    else
        path=$1
    fi
    globalpython3 ~/workspace/devenv/safefilenames.py $path
}

function _recursive_allsafe () {
    if [ "" == "$1" ]; then
        path="."
    else
        path=$1
    fi
    globalpython3 ~/workspace/devenv/safefilenames.py -r 1 $path
}

function _fixwrappedmd() {
    globalpython3 ~/workspace/ghresearch/fix_wrapped_params.py $@
}


function _cwds() {
    echo -e "\033[33mcwd='`cat ~/.cwds`'"
    echo -e "\033[37mcwd1='`cat ~/.cwds1`'"
    echo -e "\033[33mcwd2='`cat ~/.cwds2`'"
    echo -e "\033[37mcwd3='`cat ~/.cwds3`'"
    echo -e "\033[33mcwd4='`cat ~/.cwds4`'"
    echo -e "\033[37mcwd5='`cat ~/.cwds5`'\033[0m"
}

function _sorter() {
    cwd=$(pwd)
    cd ~/Desktop
    globalpython3 ~/workspace/research/clean/sorter.py
    cd ~/Documents
    globalpython3 ~/workspace/research/clean/sorter.py
    cd ~/Downloads
    globalpython3 ~/workspace/research/clean/sorter.py
    cd `echo $cwd`
}

function _firewalloff() {
    sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 0
    sudo launchctl unload /System/Library/LaunchAgents/com.apple.alf.useragent.plist
    sudo launchctl unload /System/Library/LaunchDaemons/com.apple.alf.agent.plist
}

function _firewallon() {
    sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
    sudo launchctl load /System/Library/LaunchAgents/com.apple.alf.useragent.plist
    sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist
}

function _renice_audio() {
    list="$(
        sudo ps -A \
        | grep -iE '([h]ear|[f]irefox|[b]lue|[c]oreaudiod)' \
        | cut -c 1-90
        )"

    pids=$( cut -c 1-6 <<< "$list" )
    echo sudo renice -5 $pids
    sudo renice -5 $pids
}

function _nohuptempsens() {
    scwd=`pwd`
    cd /Users/rabshakeh/workspace/research/tempsens;
    sudo nohup /Users/rabshakeh/.pyenv/versions/3.5.2/bin/python checktemp.py 79 10 </dev/null >/dev/null 2>&1 & # completely detached from terminal
    cd `echo $scwd`
}

function _tempsens() {
    scwd=`pwd`
    cd /Users/rabshakeh/workspace/research/tempsens;
    sudo /Users/rabshakeh/.pyenv/versions/3.5.2/bin/python checktemp.py 79 10

    cd `echo $scwd`
}

function _hide_file() {
    chflags hidden $@
}

function _unhide_file() {
    chflags nohidden $@
}

function _overloadsite() {
    cd /Users/rabshakeh/workspace/research/ddos;

    #open $1
    #wait 0.5
    globalpython3 hulk.py $1
}

function _sync2ssditem() {
    if [ $(hostname) == "lycia" ]; then
        echo -e "\033[31mrsync with deletions\033[0m"
        rsync -auP --del $1 $2
    else
        echo -e "\033[92mrsync without deletion\033[0m"
        rsync -auP $1 $2
    fi
}

function _syncfromssditem() {
    if [ $(hostname) == "lycia" ]; then
        echo -e "\033[92mrsync without deletion\033[0m"
        rsync -iauP $1 $2
    else
        echo -e "\033[31mrsync with deletions\033[0m"
        rsync -iauP --del $1 $2
    fi
}

function _sf() {
    _setlastpath
    #ditto "/Users/rabshakeh/Dropbox (Personal)/Camera Uploads" "/Users/rabshakeh/Dropbox (Personal)/Camera Uploads2"
    cd $HOME/workspace/sort_photo;
    python3 $HOME/workspace/sort_photo/sort_pers.py
    #globalpython3 $HOME/workspace/sort_photo/sort_a8.py

    #rm -Rf "/Users/rabshakeh/Dropbox (Personal)/Camera Uploads2"
    _cdlastpath
}

function _synctossd() {
    if [ $(hostname) == "lycia" ]; then
        _sync2ssditem ~/Library  /Volumes/samsungssd &
        _sync2ssditem ~/vms  /Volumes/samsungssd &
        _sync2ssditem ~/.1484.padl /Volumes/samsungssd/dot &
        _sync2ssditem ~/.497873.padl /Volumes/samsungssd/dot &
        _sync2ssditem ~/.AppCode33 /Volumes/samsungssd/dot &
        _sync2ssditem ~/.BuildServer /Volumes/samsungssd/dot &
        _sync2ssditem ~/.CFUserTextEncoding /Volumes/samsungssd/dot &
        _sync2ssditem ~/.CLion12 /Volumes/samsungssd/dot &
        _sync2ssditem ~/.DS_Store /Volumes/samsungssd/dot &
        _sync2ssditem ~/.JAuth.rc /Volumes/samsungssd/dot &
        _sync2ssditem ~/.PyCharm50 /Volumes/samsungssd/dot &
        _sync2ssditem ~/.Trash /Volumes/samsungssd/dot &
        _sync2ssditem ~/.active8 /Volumes/samsungssd/dot &
        _sync2ssditem ~/.adobe /Volumes/samsungssd/dot &
        _sync2ssditem ~/.android /Volumes/samsungssd/dot &
        _sync2ssditem ~/.ansible /Volumes/samsungssd/dot &
        _sync2ssditem ~/.appCode31 /Volumes/samsungssd/dot &
        _sync2ssditem ~/.armitage.prop /Volumes/samsungssd/dot &
        _sync2ssditem ~/.atom /Volumes/samsungssd/dot &
        _sync2ssditem ~/.bash_history /Volumes/samsungssd/dot &
        _sync2ssditem ~/.bash_profile /Volumes/samsungssd/dot &
        _sync2ssditem ~/.bash_profile.backup /Volumes/samsungssd/dot &
        _sync2ssditem ~/.bash_profile.pysave /Volumes/samsungssd/dot &
        _sync2ssditem ~/.bash_sessions /Volumes/samsungssd/dot &
        _sync2ssditem ~/.boot2docker /Volumes/samsungssd/dot &
        _sync2ssditem ~/.bro /Volumes/samsungssd/dot &
        _sync2ssditem ~/.bundle /Volumes/samsungssd/dot &
        _sync2ssditem ~/.bundler /Volumes/samsungssd/dot &
        _sync2ssditem ~/.bzr.log /Volumes/samsungssd/dot &
        _sync2ssditem ~/.cache /Volumes/samsungssd/dot &
        _sync2ssditem ~/.cocoapods /Volumes/samsungssd/dot &
        _sync2ssditem ~/.coffee_history /Volumes/samsungssd/dot &
        _sync2ssditem ~/.config /Volumes/samsungssd/dot &
        _sync2ssditem ~/.cookiecutters /Volumes/samsungssd/dot &
        _sync2ssditem ~/.cpan /Volumes/samsungssd/dot &
        _sync2ssditem ~/.cups /Volumes/samsungssd/dot &
        _sync2ssditem ~/.cwd /Volumes/samsungssd/dot &
        _sync2ssditem ~/.cwds /Volumes/samsungssd/dot &
        _sync2ssditem ~/.cwds1 /Volumes/samsungssd/dot &
        _sync2ssditem ~/.cwds2 /Volumes/samsungssd/dot &
        _sync2ssditem ~/.cwds3 /Volumes/samsungssd/dot &
        _sync2ssditem ~/.cwds4 /Volumes/samsungssd/dot &
        _sync2ssditem ~/.cwds5 /Volumes/samsungssd/dot &
        _sync2ssditem ~/.designer /Volumes/samsungssd/dot &
        _sync2ssditem ~/.dir_colors /Volumes/samsungssd/dot &
        _sync2ssditem ~/.docker /Volumes/samsungssd/dot &
        _sync2ssditem ~/.done.txt /Volumes/samsungssd/dot &
        _sync2ssditem ~/.dropbox /Volumes/samsungssd/dot &
        _sync2ssditem ~/.ethash /Volumes/samsungssd/dot &
        _sync2ssditem ~/.foreui /Volumes/samsungssd/dot &
        _sync2ssditem ~/.gem /Volumes/samsungssd/dot &
        _sync2ssditem ~/.ghpwd /Volumes/samsungssd/dot &
        _sync2ssditem ~/.gitbook /Volumes/samsungssd/dot &
        _sync2ssditem ~/.gitconfig /Volumes/samsungssd/dot &
        _sync2ssditem ~/.gitignore_global /Volumes/samsungssd/dot &
        _sync2ssditem ~/.gnupg /Volumes/samsungssd/dot &
        _sync2ssditem ~/.gpgpasswd /Volumes/samsungssd/dot &
        _sync2ssditem ~/.grip /Volumes/samsungssd/dot &
        _sync2ssditem ~/.grsync /Volumes/samsungssd/dot &
        _sync2ssditem ~/.gsutil /Volumes/samsungssd/dot &
        _sync2ssditem ~/.hgignore_global /Volumes/samsungssd/dot &
        _sync2ssditem ~/.historybashconfig /Volumes/samsungssd/dot &
        _sync2ssditem ~/.historybashstl /Volumes/samsungssd/dot &
        _sync2ssditem ~/.httpie /Volumes/samsungssd/dot &
        _sync2ssditem ~/.hue-cli /Volumes/samsungssd/dot &
        _sync2ssditem ~/.hushlogin /Volumes/samsungssd/dot &
        _sync2ssditem ~/.iStats /Volumes/samsungssd/dot &
        _sync2ssditem ~/.idlerc /Volumes/samsungssd/dot &
        _sync2ssditem ~/.ipynb_checkpoints /Volumes/samsungssd/dot &
        _sync2ssditem ~/.ipython /Volumes/samsungssd/dot &
        _sync2ssditem ~/.itmstransporter /Volumes/samsungssd/dot &
        _sync2ssditem ~/.jupyter /Volumes/samsungssd/dot &
        _sync2ssditem ~/.kivy /Volumes/samsungssd/dot &
        _sync2ssditem ~/.lastpath /Volumes/samsungssd/dot &
        _sync2ssditem ~/.ldappassword /Volumes/samsungssd/dot &
        _sync2ssditem ~/.ldappasswordlocal /Volumes/samsungssd/dot &
        _sync2ssditem ~/.lesshst /Volumes/samsungssd/dot &
        _sync2ssditem ~/.links /Volumes/samsungssd/dot &
        _sync2ssditem ~/.matplotlib /Volumes/samsungssd/dot &
        _sync2ssditem ~/.motd /Volumes/samsungssd/dot &
        _sync2ssditem ~/.netatmo.json /Volumes/samsungssd/dot &
        _sync2ssditem ~/.netatmo.txt /Volumes/samsungssd/dot &
        _sync2ssditem ~/.netatmo_last.json /Volumes/samsungssd/dot &
        _sync2ssditem ~/.node-gyp /Volumes/samsungssd/dot &
        _sync2ssditem ~/.node_repl_history /Volumes/samsungssd/dot &
        _sync2ssditem ~/.npm /Volumes/samsungssd/dot &
        _sync2ssditem ~/.nx /Volumes/samsungssd/dot &
        _sync2ssditem ~/.openmacapp /Volumes/samsungssd/dot &
        _sync2ssditem ~/.openmacapp.swp /Volumes/samsungssd/dot &
        _sync2ssditem ~/.oracle_jre_usage /Volumes/samsungssd/dot &
        _sync2ssditem ~/.parallel /Volumes/samsungssd/dot &
        _sync2ssditem ~/.pgadmin_histoqueries /Volumes/samsungssd/dot &
        _sync2ssditem ~/.pgpass /Volumes/samsungssd/dot &
        _sync2ssditem ~/.pip /Volumes/samsungssd/dot &
        _sync2ssditem ~/.ppslideshow /Volumes/samsungssd/dot &
        _sync2ssditem ~/.psql_history /Volumes/samsungssd/dot &
        _sync2ssditem ~/.puf /Volumes/samsungssd/dot &
        _sync2ssditem ~/.putty /Volumes/samsungssd/dot &
        _sync2ssditem ~/.pyenv /Volumes/samsungssd/dot &
        _sync2ssditem ~/.pylint.d /Volumes/samsungssd/dot &
        _sync2ssditem ~/.pypirc /Volumes/samsungssd/dot &
        _sync2ssditem ~/.python-eggs /Volumes/samsungssd/dot &
        _sync2ssditem ~/.python_history /Volumes/samsungssd/dot &
        _sync2ssditem ~/.pythonhist /Volumes/samsungssd/dot &
        _sync2ssditem ~/.qt /Volumes/samsungssd/dot &
        _sync2ssditem ~/.quake2 /Volumes/samsungssd/dot &
        _sync2ssditem ~/.random_fortune_lock_file /Volumes/samsungssd/dot &
        _sync2ssditem ~/.rediscli_history /Volumes/samsungssd/dot &
        _sync2ssditem ~/.rnd /Volumes/samsungssd/dot &
        _sync2ssditem ~/.searchfiles /Volumes/samsungssd/dot &
        _sync2ssditem ~/.sh_history /Volumes/samsungssd/dot &
        _sync2ssditem ~/.sonic-pi /Volumes/samsungssd/dot &
        _sync2ssditem ~/.speedtest.txt /Volumes/samsungssd/dot &
        _sync2ssditem ~/.ssh /Volumes/samsungssd/dot &
        _sync2ssditem ~/.startbartender.sh /Volumes/samsungssd/dot &
        _sync2ssditem ~/.subversion /Volumes/samsungssd/dot &
        _sync2ssditem ~/.todo.txt /Volumes/samsungssd/dot &
        _sync2ssditem ~/.tor /Volumes/samsungssd/dot &
        _sync2ssditem ~/.ts2_spaces_configs /Volumes/samsungssd/dot &
        _sync2ssditem ~/.turbo /Volumes/samsungssd/dot &
        _sync2ssditem ~/.userpwd.txt /Volumes/samsungssd/dot &
        _sync2ssditem ~/.vagrant.d /Volumes/samsungssd/dot &
        _sync2ssditem ~/.vim /Volumes/samsungssd/dot &
        _sync2ssditem ~/.viminfo /Volumes/samsungssd/dot &
        _sync2ssditem ~/.vimrc /Volumes/samsungssd/dot &
        _sync2ssditem ~/.vnc /Volumes/samsungssd/dot &
        _sync2ssditem ~/.wget-hsts /Volumes/samsungssd/dot &
        _sync2ssditem ~/.yjp /Volumes/samsungssd/dot &
        _sync2ssditem ~/.ytpw /Volumes/samsungssd/dot &
    fi
    _sync2ssditem ~/Desktop /Volumes/samsungssd &
    _sync2ssditem ~/Documents /Volumes/samsungssd &
    _sync2ssditem ~/Downloads /Volumes/samsungssd &
    _sync2ssditem ~/Movies /Volumes/samsungssd &
    _sync2ssditem ~/Music /Volumes/samsungssd &
    _sync2ssditem /Applications /Volumes/samsungssd &
    _sync2ssditem ~/workspace /Volumes/samsungssd &

    wait
}

function _syncfromssd() {
    if [ $(hostname) == "xanthos" ]; then
        rsync -auP ~/Library  /Volumes/samsungssd &
    fi
    _syncfromssditem /Volumes/samsungssd/Desktop ~ &
    _syncfromssditem /Volumes/samsungssd/Documents ~ &
    _syncfromssditem /Volumes/samsungssd/Downloads ~ &
    _syncfromssditem /Volumes/samsungssd/Movies ~ &
    _syncfromssditem /Applications / &
    _syncfromssditem /Volumes/samsungssd/workspace ~ &

    wait
}

function _brew() {

    echo -e "\033[91mbrewing by first checking /usr/local for writability\033[0m"
    touch /usr/local/test 2> /dev/null
    if [ $? != 0 ]; then
        echo -e "\033[33mmake /usr/local writable by setting owner\033[0m"
        sudo chown -R  `whoami` /usr/local
    fi
    touch /usr/local/test 2> /dev/null
    if [ $? != 0 ]; then
        echo -e "\033[33error\033[0m"
        return
    fi
    rm /usr/local/test
    echo -e "\033[92mbrew   $@\033[0m"
    /usr/local/bin/brew $@
}

function _clock() {
    echo -e "\033[32m"&&toilet -f wideterm -W $(date +'%H:%M:%S')&&echo -e "\033[0m"
}

function _screensaverphotodelay() {
    sudo /usr/libexec/PlistBuddy -c "set ':JustASlide:mainDuration' $1" /System/Library/PrivateFrameworks/Slideshows.framework/Versions/A/Resources/Content/EffectDescriptions.plist
}

function _superlocate() {
    sudo find / | grep $1 2> /dev/null
}

function _restart() {
    echo "shutdown now!";
    _stopvms
    globalpython3 /Users/rabshakeh/workspace/research/swapbaseloginimg.py;
    (sleep 10&&echo 'sudo reboot'&&sudo reboot) &
    echo "restart";
    osascript -e 'tell app "System Events" to restart'
}

function _genindex(){
    find . -type f -depth 1 | puf "['<a href=\"'+x+'\">'+str(x).replace('./', '').replace('.html', '').replace('.HTML', '')+'</a><br />' for x in lines]"
}

function _kp() {
    sudo killall globalpython3 2> /dev/null
    sudo killall Python 2> /dev/null
    sudo killall globalpython3 2> /dev/null
    sudo killall Python 2> /dev/null
    sudo killall pypy 2> /dev/null
    sudo killall globalpython3 2> /dev/null
    sudo killall Python3 2> /dev/null
    sudo killall globalpython3 2> /dev/null
    sudo killall Python3 2> /dev/null
    sudo killall pypy3 2> /dev/null

    stty sane;
    echo "kp done"
}

function _subl() {
    if [ ! -f $1 ]; then
        touch $1
    fi
    /usr/bin/open -a /Applications/Sublime\ Text.app $1
}

function sani() {
    puf "' '.join([str(x) for x in [str(consoleprinter.colorize_for_print(y))+'\n' for y in lines]]).strip()"
}

function _diskuse() {
    unset IFS
    IFS=$'\n'
    if [ "" == "$1" ]; then

        /bin/ls -a | xargs du -sh | gsort -h | puf "[str('\033[33m{}\033[0m'.format(l.split('\t')[0])+' -> \033[92m'+l.split('\t')[1]+'\033[0m') for l in lines]"
    else
        /bin/ls -a $1 | xargs du -sh | gsort -h
    fi
    echo -e "\n`df -h | puf "'\033[31mUsed: '+cols[1][1]+'\n\033[92mFree: '+cols[3][1]"`\033[0m"
    stty sane
    unset IFS
}

function _new_python_file() {
    globalpython3 /Users/rabshakeh/workspace/devenv/new_python_file.py $1 $2
    echo -ne "\033[92m"
    read -p "Show file? (y|Y)? " yn
    case $yn in
        [Yy]* ) _ccat $2 ;;
        * ) echo -e "\033[31mok, bye";
            return;
            ;;
    esac
    echo -e "\033[0m"
}

function _move_in_folders() {
    _allsafe
    globalpython3 ~/workspace/research/clean/move_in_folders.py 100
}

function _safestring() {
    echo $@|puf "[consoleprinter.get_safe_filename_string(os.path.basename(x)).replace(' ', '_').replace('-', '_').replace('__', '_').replace('___', '_').replace('..', '.').replace('._', '_').lower().replace('|', '_').replace('\'', '').replace('__', '_').lower().strip('_') for x in lines]"
}

function _recursive_safestring() {
    echo $@|puf "[consoleprinter.get_safe_filepath_string(x).replace(' ', '_').replace('-', '_').replace('__', '_').replace('___', '_').replace('..', '.').replace('._', '_').lower().replace('|', '_').replace('\'', '').lower().strip('_') for x in lines]"
}

function _safename() {
    afile=$@
    filename=`_safestring $1`
    if [ "$afile" == "$filename" ]; then
        x=4
    elif [ "$afile" == "./$filename" ]; then
        x=4
    else

        echo -e "\nchanging:" "$afile -> $filename"
        echo mv -f "'"$afile"'" "'"$filename"'" | sh
    fi
}

function _recursive_safename() {
    afile=$@
    filename=`_recursive_safestring $1`
    if [ "$afile" == "$filename" ]; then
        x=4
    elif [ "$afile" == "./$filename" ]; then
        x=4
    else

        echo -e "\nchanging:" "$afile -> $filename"
        echo mv -f "'"$afile"'" "'"$filename"'" | sh
    fi
}

function _allsafe2 () {
    unset IFS
    IFS=$'\n'

    for afile in $(find . -maxdepth 1 -not -path '*/\.*' -not -path '*recycle*')
        do
            _safename $afile
        done
    stty sane
    unset IFS
}

function _docx2md() {
    _safename $1
}

function _throttlepid() {
    sudo /usr/local/Cellar/cputhrottle/20100515/bin/cputhrottle $1 10 &
}

function _dash() {

    #   echo "'"$@"'"
    #echo "'"$@"'"| puf '",".join(lines[0].split())'

    query=$(echo $@| puf '",".join(lines[0].split())')
    keys='manpages,python,python,django,coffeescript,redis,emoji,css,bootstrap,couchdb,docker'

    #echo $keys
    cmd='dash-plugin://keys='$keys'&query='$query
    echo $cmd
    open $cmd

    #open 'dash://'$query
}

function _gdash() {
    _google $@
    _dash $@
}

function lwr() {
    tr '[:upper:]' '[:lower:]'
}

function _isrunning() {
    search=$(echo $1|lwr)
    ps x | lwr | grep $search | puf "cols[0]" | puf 'os.system("ps -xo pid,user,command -p "+",".join(lines)+">pstmp")' > /dev/null
}

function _psex() {

    for x in `ps -ef| awk '{ print $2 }'`;
        do
            echo `ls /proc/$x/fd 2> /dev/null | wc -l` $x `/bin/cat /proc/$x/cmdline 2> /dev/null`;
        done | sort -n -r | head -n 20
}

function _upgrade() {
    sudo date;

    #/usr/local/bin/brew list | puf '["/usr/local/bin/brew link --overwrite "+x for x in lines]' | sh
    #brew doctor;
    #sudo date;

    # echo -e "\033[92m"
    # read -p "Continue upgrade? (y|Y)? " yn
    # case $yn in
    #     [Yy]* ) ;;
    #     * ) echo -e "\033[31mCancelled";
    #         echo -e "\033[0m"

    #         return;
    #         ;;

    # esac
    # echo -e "\033[0m"
    sudo date;
    _brew update;
    brew cask update;

    brew upgrade --all;
    /usr/local/bin/brew cask list | puf '["/usr/local/bin/brew cask install --force "+x.strip(" (!)") for x in lines]' | sh
    brew cleanup -s --force;

    #globalpython3 $HOME/workspace/research/list_python_packages2.py > $HOME/workspace/research/upgrade_python_packs2.sh;
    #globalpython3 $HOME/workspace/research/list_python_packages3.py > $HOME/workspace/research/upgrade_python_packs3.sh;

    #$HOME/workspace/research/upgrade_python_packs2.sh;
    #$HOME/workspace/research/upgrade_python_packs3.sh;

    #gcloud -q components update;
    brew doctor
}

function _button() {
    scr='tell application "System Events" to click (first button of (every window of (application process "'$2'")) whose role description is "'$1' button")'

    #echo "'"$scr"'"
    /usr/bin/osascript -e "$scr"
}

function _hide(){
    /usr/bin/osascript -e 'tell application "Finder" to set visible of process "'$1'" to false'
}

function _unhide() {
 /usr/bin/osascript -e 'tell application "Finder" to set visible of process "'$1'" to true'
}

function _running_procs() {
    ps -Aeo pid,pcpu,command  | grep -v 0.0 | sort -k2 -r | grep -v '\-bash'
}

function _uniqfolder() {
    if [ "$1" == "" ]; then
        foldernametmp='folder'
    else
        foldernametmp=$1
    fi
    foldername=$foldernametmp
    timestamp=$(date +%y%m%d%H)
    mkdir $timestamp"_$foldername"
}

function update_terminal_cwd() {

    # Identify the directory using a "file:" scheme URL,
    # including the host name to disambiguate local vs.
    # remote connections. Percent-escape spaces.
    local SEARCH=' '
    local REPLACE='%20'

    local PWD_URL="file://$HOSTNAME${PWD//$SEARCH/$REPLACE}"
    printf '\e]7;%s\a' "$PWD_URL"
}

function _pipinstall() {
    pip uninstall $1
    pip install $1
}

function _ytplayl() {
    sn=$(_safestring $1)
    echo $sn
    mkdir $sn
    cd $sn
    globalpython3 ~/Movies/youtube/process_youtube.py -p $2 downloadprocess;
    _ofi

    #globalpython3 process_youtube.py podcast;
    #osascript -e "tell application \"Google Chrome\" to open location \"https://www.youtube.com/playlist?list=$1\""&&osascript -e "tell application \"Google Chrome\" to activate"
}

function _uriel_ldifs() {
    echo "run backups"
    ssh uriel.a8.nl
    scp -r uriel.a8.nl:./ldifsgz .

    timestamp=$(date +%y%m%d%H)
    mkdir ~/Desktop/$timestamp"_uriel"
    mv /Users/rabshakeh/Desktop/ldifsgz/* ~/Desktop/$timestamp"_uriel"
    rmdir ldifsgz
}

function _abigail_logs() {
    cd ~/Desktop
    ssh abigail.a8.nl  "echo 'delete previous'; \
                        rm -f /home/rabshakeh/abigail_logs.tar.gz; \
                        sudo rm -Rf /home/rabshakeh/abigail_logs; \
                        echo 'copy data'; \
                        sudo mkdir -p /home/rabshakeh/abigail_logs; \
                        sudo cp -R /tmp ./abigail_logs; \
                        sudo cp /var/log/nginx/error.log /home/rabshakeh/abigail_logs; \
                        sudo cp /var/log/nginx/www_governet_nl.access.log /home/rabshakeh/abigail_logs; \
                        sudo cp /var/log/nginx/access.log /home/rabshakeh/abigail_logs; \

                        echo 'tar'; \
                        sudo chown -R rabshakeh /home/rabshakeh/abigail_logs; \
                        tar -cf /home/rabshakeh/abigail_logs.tar /home/rabshakeh/abigail_logs; \
                        echo 'zip'; \
                        pigz --best abigail_logs.tar"

    echo 'scp'
    scp abigail.a8.nl:./abigail_logs.tar.gz .;
    tar -xvf abigail_logs.tar.gz;
    rm abigail_logs.tar.gz
    ssh abigail.a8.nl "rm -f /home/rabshakeh/abigail_logs.tar.gz; \
                       rm -Rf /home/rabshakeh/abigail_logs"

    timestamp=$(date +%y%m%d%H)
    mkdir ~/Desktop/$timestamp"_abigail_logs"
    mv home/rabshakeh/abigail_logs/* ~/Desktop/$timestamp"_abigail_logs"
    cd ~/Desktop/$timestamp"_abigail_logs"

    #rm -Rf home/rabshakeh
    #rm -Rf home
}

function _abigail_sp_logs() {
    cd ~/Desktop
    ssh abigail.a8.nl  "echo 'delete previous'; \
                        rm -f /home/rabshakeh/abigail_sp_logs.tar.gz; \
                        sudo rm -Rf /home/rabshakeh/abigail_sp_logs; \
                        echo 'copy data'; \
                        sudo mkdir -p /home/rabshakeh/abigail_sp_logs; \
                        sudo cp -R /tmp/governetsp.log ./abigail_sp_logs; \
                        echo 'tar'; \
                        sudo chown -R rabshakeh /home/rabshakeh/abigail_sp_logs; \
                        tar -cf /home/rabshakeh/abigail_sp_logs.tar /home/rabshakeh/abigail_sp_logs; \
                        echo 'zip'; \
                        pigz --best abigail_sp_logs.tar"

    echo 'scp'
    scp abigail.a8.nl:./abigail_sp_logs.tar.gz .;
    tar -xvf abigail_sp_logs.tar.gz;
    rm abigail_sp_logs.tar.gz
    ssh abigail.a8.nl "rm -f /home/rabshakeh/abigail_sp_logs.tar.gz; \
                       rm -Rf /home/rabshakeh/abigail_sp_logs"

    timestamp=$(date +%y%m%d%H)
    mkdir ~/Desktop/$timestamp"_abigail_sp_logs"
    mv ~/Desktop/home/rabshakeh/abigail_sp_logs/* ~/Desktop/$timestamp"_abigail_sp_logs"
    cd ~/Desktop/$timestamp"_abigail_sp_logs"
}

function _jophiel_logs() {
    cd ~/Desktop
    ssh jophiel.a8.nl  "rm -f error_log.gz; \
                        sudo cp -v /var/log/httpd/error_log /home/rabshakeh/; \
                        gzip error_log; \
                        sudo chown rabshakeh error_log.gz"

    echo 'scp'
    scp jophiel.a8.nl:./error_log.gz .
    ssh jophiel.a8.nl "rm -f error_log.gz";

    rm -f error_log.log;
    gzip -d error_log.gz

    echo "mv"
    mv error_log error_log.log
    /bin/cat error_log.log | grep -v 'auth.py:329 Continue.saml2checks()): saml2: value cn=' > error.log

    #rm error_log.log
    #_killall logr
    open error.log
    open error_log.log
}

function _jophiel_download() {
    echo -e "\n\033[92m"$2"\033[0m"
    cd ~/Desktop
    ssh jophiel.a8.nl  "echo 'delete previous'; \
                        rm -Rf /home/rabshakeh/$1; \
                        rm -f /home/rabshakeh/$1.tar.gz; \

                        echo 'copy data'; \
                        sudo cp -r $2 /home/rabshakeh/; \
                        sudo chown -R rabshakeh /home/rabshakeh/$1; \
                        echo 'tar'; \
                        tar -cf /home/rabshakeh/$1.tar /home/rabshakeh/$1; \
                        echo 'zip'; \
                        pigz --best /home/rabshakeh/$1.tar"

    scp jophiel.a8.nl:./$1.tar.gz .
    ssh jophiel.a8.nl "rm -f /home/rabshakeh/$1.tar.gz; \
                       rm -Rf /home/rabshakeh/$1";

    rm -Rf $1;
    pigz -d $1.tar.gz
    tar -xf $1.tar

    rm $1.tar
    mv ~/Desktop/home/rabshakeh/$1 .
    rm -Rfd ~/Desktop/home/rabshakeh
    cd ~/Desktop/$1
}

function _ipsilon_dl() {
    _jophiel_download idp /var/lib/ipsilon/idp
    mv ~/Desktop/idp ~/Desktop/ipsilon_idp
    _jophiel_download ipsilon /usr/lib/python/site-packages/ipsilon
    mv ~/Desktop/ipsilon ~/Desktop/ipsilon_usr_lib_python7_site_packages;
    _jophiel_download ipsilon /usr/share/ipsilon;
    mv ~/Desktop/ipsilon ~/Desktop/ipsilon_usr_share;
    _jophiel_download ipsilon /etc/ipsilon;
    mv ~/Desktop/ipsilon ~/Desktop/ipsilon_etc;
    cd ~/Desktop
    timestamp=$(date +%y%m%d%H)
    mkdir ~/Desktop/$timestamp"_jophiel_ipsilon"
    mv ~/Desktop/ipsilon_* ~/Desktop/$timestamp"_jophiel_ipsilon"
    cd ~/Desktop/$timestamp"_jophiel_ipsilon"

    mv ipsilon_httpd_log/error_log ipsilon_httpd_log/error.log
    _ofi
}

function _sso_logs() {
    _jophiel_download httpd /var/log/httpd
    mv ~/Desktop/httpd ~/Desktop/ipsilon_httpd_log
    _abigail_sp_logs
    cd ~/Desktop
    timestamp=$(date +%y%m%d%H)
    mkdir ~/Desktop/$timestamp"_logs"
    mv ~/Desktop/ipsilon_* ~/Desktop/$timestamp"_logs"
    cd ~/Desktop/$timestamp"_jophiel"

    mv ipsilon_httpd_log/error_log ipsilon_httpd_log/error.log
    _ofi
}

function _governet_download_all() {
    _abigail_sp_logs &
    _jophiel_logs &

    wait
    _ipsilon_dl &
    _abigail_logs &

    wait
}

function _cdlastpath() {
    if [ -f $HOME/.lastpath ]; then
        cpath=`/bin/cat $HOME/.lastpath`;
    else
        echo $cpath > $HOME/.lastpath;
    fi;
    lastpath=`/bin/cat $HOME/.lastpath`
    if [ -d "$lastpath" ]; then
        cd "$lastpath"
    fi
}

function _tls() {
    todo ls | puf "'\n'.join(lines).split('--')[0].strip()" | puf "[x.strip().replace(' ', '. ', 1) for x in lines if x]"
}

function _todo() {
    if [ "" == "$1" ]; then
        _tls
    elif [ "-h" == "$1" ]; then
        todo helps
    else
        /usr/local/bin/todo $@
    fi
}

function _gettempstats() {
    iStats cpu temp | puf "'\033[30m'+' '.join(lines[0].split(' ')[:-1]).replace(' temp', '').strip()" > ~/.cpu &
    iStats battery temp | puf "lines[0].replace(' temp', '').strip()"> ~/.bat &
    istats scan TCXP | puf "['TXCP: {0:.2f}°C'.format(float(' '.join(x.split('=')[1:]).strip())).strip() for x in lines]"> ~/.tcxp &
    iStats fan speed | puf "[' '.join(x.split(' ')[:-1]).replace(' speed', '').strip() for x in lines]"> ~/.fan &

    wait
    echo -e '\033[0m' >> ~/.fan
}

function _printtempstats() {
    /bin/cat ~/.cpu
    /bin/cat ~/.bat
    /bin/cat ~/.tcxp
    /bin/cat ~/.fan
}

function _deltempstats() {
    rm ~/.cpu &
    rm ~/.bat &
    rm ~/.fan &
    rm ~/.tcxp &

    wait
}

function _tempstats() {
    echo -e "\033[90mTemperatures:\033[0m"
    (_gettempstats)
    _printtempstats
    (_deltempstats)
}

function _temp() {
    if [ "$1" == "" ]; then
        _tempstats
    elif [ "$1" == "all" ]; then
        iStats all
    elif [ "$1" == "-a" ]; then
        iStats all
    fi
}

if shopt -q login_shell; then
    if [ $TERM=="xterm-256color" ]; then
        if [ -s ~/.turbo ]; then
            cat ~/.turbo
            echo
        fi
        echo -e "\033[90m﹍﹎﹎﹎﹏﹏﹏﹏﹏﹏﹎﹎﹎﹍\n\033[30mtime:"
        echo -e `/bin/cat $HOME/time.txt`"\033[33m\033[0m\033[90m\n﹍﹎﹎﹎﹏﹏﹏﹏﹏﹏﹎﹎﹎﹍"
        cat ~/.speedtest.txt | puf "[x for x in lines if 'mbit' in x.lower() or 'cest' in x.lower()]"


        echo -e "\033[90m﹍﹎﹎﹎﹏﹏﹏﹏﹏﹏﹎﹎﹎﹍\nquote:"
        /bin/cat $HOME/quote.txt
        echo -e "\n\033[90m﹍"
        /bin/cat $HOME/cquote.txt
        if [ -s  ~/.motd ]; then
            echo -e "\033[90m﹍\n\033[30mmotd:\n\033[90m"`cat ~/.motd`"\033[0m"
        fi
        _cdlastpath
    fi;
    echo -e "\033[90m﹍﹎﹎﹎﹏﹏﹏﹏﹏﹏﹎﹎﹎﹍\n\033[30mtodo:"
    if [ $(hostname) == "lycia" ]; then
    	todo ls | puf "'\033[30m--\033[96m\n'+'\n'.join([x.strip().replace(' ', '. ', 1) for x in lines if x]).replace('TODO:. ', '').replace('--', '\033[30m--')+'\033[0m'"
    fi;
fi

function _set_font_smoothing() {
    defaults -currentHost write -globalDomain AppleFontSmoothing -int $1
}

function _get_font_smoothing() {
    defaults -currentHost read -globalDomain AppleFontSmoothing
}

function _setlastpath() {
    vpwd=`pwd`
    cpath=`/bin/cat $HOME/.lastpath`;
    if [ "$cpath" != "$vpwd" ]; then
        pwd > $HOME/.lastpath;
    fi;

    #echo "_setlastpath:" `/bin/cat $HOME/.lastpath`;
}
export MANPATH

# Terminal colours (after installing GNU coreutils)
NM="\[\033[0;38m\]" #means no background and white lines
HI="\[\033[0;94m\]" #change this for letter colors
HII="\[\033[0;92m\]" #change this for letter colors
SI="\[\033[0;33m\]" #this is for the current directory
CL="\[\033[0;95m\]" #this is for the current directory
IN="\[\033[0m\]"

eval `gdircolors ~/.dir_colors`
export PS1="$NM[$HI\u:$HII\h $SI\W$NM] $IN"
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r; if [ \"`type -t _setlastpath`\" == \"function\" ]; then _setlastpath; fi; pwd|sed 's/.*/\"&\"/'|xargs dirname > ~/.userpwd.txt;  echo -ne \"\033[30m[\"; /bin/cat ~/.userpwd.txt| xargs |tr '\n' ']'; echo -e \"\033[30m\"";
export FLEETCTL_ENDPOINT=http://172.17.8.101:4001
export KUBERNETES_MASTER=http://172.17.8.101:8080

# remove_disk: spin down unneeded disk
# ---------------------------------------
# diskutil eject /dev/disk1s3
# to change the password on an encrypted disk image:
# ---------------------------------------
# hdiutil chpass /path/to/the/diskimage
# to mount a read-only disk image as read-write:
# ---------------------------------------
# hdiutil attach example.dmg -shadow /tmp/example.shadow -noverify

# mounting a removable drive (of type msdos or hfs)
# ---------------------------------------
# mkdir /Volumes/Foo
# ls /dev/disk*   to find out the device to use in the mount command)
# mount -t msdos /dev/disk1s1 /Volumes/Foo
# mount -t hfs /dev/disk1s1 /Volumes/Foo

# to create a file of a given size: /usr/sbin/mkfile or /usr/bin/hdiutil
# ---------------------------------------
# e.g.: mkfile 10m 10MB.dat
# e.g.: hdiutil create -size 10m 10MB.dmg
# the above createdte files that are almost all zeros-if random bytes are desired
# then use: $HOME/Dev/Perl/randBytes 1048576 > 10MB.dat
# Setting PATH for Python 3.5
# The orginal version is saved in .bash_profile.pysave
#PATH="/Library/Frameworks/Python.framework/Versions/3.5/bin:${PATH}"
#PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH
#export PATH
MANPATH=/usr/local/Cellar/coreutils/8.24/libexec/gnuman:/usr/local/Cellar/gnu-sed/4.2.2/libexec/gnuman:/usr/share/man
MANPATH=$MANPATH:/usr/local/Cellar/ack/2.14/share/man:/usr/local/Cellar/ansible/1.9.3/share/man:/usr/local/Cellar/apple-gcc42/4.2.1-5666.3/share/man:/usr/local/Cellar/autoconf/2.69/share/man:/usr/local/Cellar/automake/1.15/share/man:/usr/local/Cellar/autossh/1.4e/share/man:/usr/local/Cellar/base64/1.5/share/man:/usr/local/Cellar/bash/4.3.42/share/man:/usr/local/Cellar/binutils/2.25.1/share/man:/usr/local/Cellar/bison/3.0.4/share/man:/usr/local/Cellar/brew-cask/0.56.0/share/man:/usr/local/Cellar/bsdmake/24/share/man:/usr/local/Cellar/cmake/3.3.1/share/man:/usr/local/Cellar/colordiff/1.0.15/share/man:/usr/local/Cellar/coreutils/8.24/share/man:/usr/local/Cellar/cscope/15.8a/share/man:/usr/local/Cellar/curl/7.44.0/share/man:/usr/local/Cellar/djvulibre/3.5.27/share/man:/usr/local/Cellar/doxygen/1.8.10/share/man:/usr/local/Cellar/duplicity/0.7.04_1/share/man:/usr/local/Cellar/faac/1.28/share/man:/usr/local/Cellar/ffmpeg/2.7.2_1/share/man:/usr/local/Cellar/findutils/4.4.2/share/man:/usr/local/Cellar/flac/1.3.1/share/man:/usr/local/Cellar/fontconfig/2.11.1/share/man:/usr/local/Cellar/fontforge/20150824/share/man:/usr/local/Cellar/fortune/9708/share/man:/usr/local/Cellar/freetype/2.6_1/share/man:/usr/local/Cellar/gawk/4.1.3/share/man:/usr/local/Cellar/gdbm/1.11/share/man:/usr/local/Cellar/gdk-pixbuf/2.30.8/share/man:/usr/local/Cellar/gettext/0.19.5.1/share/man:/usr/local/Cellar/gifsicle/1.88/share/man:/usr/local/Cellar/git/2.5.1/share/man:/usr/local/Cellar/gnu-indent/2.2.10/share/man:/usr/local/Cellar/gnu-sed/4.2.2/share/man:/usr/local/Cellar/gnu-tar/1.28/share/man:/usr/local/Cellar/gnu-which/2.21/share/man:/usr/local/Cellar/gnupg/1.4.19/share/man:/usr/local/Cellar/gnutls/3.3.17.1/share/man:/usr/local/Cellar/gobject-introspection/1.44.0/share/man:/usr/local/Cellar/graphicsmagick/1.3.21/share/man:/usr/local/Cellar/graphviz/2.38.0/share/man:/usr/local/Cellar/guile/2.0.11_2/share/man:/usr/local/Cellar/help2man/1.47.1/share/man:/usr/local/Cellar/httrack/3.48.21/share/man:/usr/local/Cellar/hub/2.2.1/share/man:/usr/local/Cellar/icu4c/55.1/share/man:/usr/local/Cellar/imagemagick/6.9.1-10/share/man:/usr/local/Cellar/jbig2dec/0.12/share/man:/usr/local/Cellar/jpeg/8d/share/man:/usr/local/Cellar/jq/1.5/share/man:/usr/local/Cellar/lame/3.99.5/share/man:/usr/local/Cellar/librsync/0.9.7/share/man:/usr/local/Cellar/libtasn1/4.5/share/man:/usr/local/Cellar/libtiff/4.0.4/share/man:/usr/local/Cellar/libtool/2.4.6/share/man:/usr/local/Cellar/links/2.10/share/man:/usr/local/Cellar/little-cms2/2.7/share/man:/usr/local/Cellar/lua/5.2.4_1/share/man:/usr/local/Cellar/lynx/2.8.8rel.2_1/share/man:/usr/local/Cellar/makedepend/1.0.5/share/man:/usr/local/Cellar/memcached/1.4.24/share/man:/usr/local/Cellar/mercurial/3.5.1/share/man:/usr/local/Cellar/midnight-commander/4.8.14/share/man/sr:/usr/local/Cellar/mp3wrap/0.5/share/man:/usr/local/Cellar/mpc/0.27/share/man:/usr/local/Cellar/nmap/6.47/share/man/zh:/usr/local/Cellar/node/0.12.7_1/share/man:/usr/local/Cellar/numpy/1.9.2_1/libexec/nose/man:/usr/local/Cellar/openssl/1.0.2d_1/share/man:/usr/local/Cellar/ossp-uuid/1.6.2_1/share/man:/usr/local/Cellar/p7zip/9.20.1/share/man:/usr/local/Cellar/pandoc/1.15.2.1/share/man:/usr/local/Cellar/pango/1.36.8_2/share/man:/usr/local/Cellar/parallel/20150822/share/man:/usr/local/Cellar/pbzip2/1.1.12/share/man:/usr/local/Cellar/pcre/8.37/share/man:/usr/local/Cellar/pigz/2.3.3/share/man:/usr/local/Cellar/pkg-config/0.28/share/man:/usr/local/Cellar/postgresql/9.4.4/share/man:/usr/local/Cellar/python/2.7.10_2/share/man:/usr/local/Cellar/python/3.4.3_2/share/man:/usr/local/Cellar/rabbitmq/3.5.4/share/man:/usr/local/Cellar/rename/1.600/share/man:/usr/local/Cellar/rsync/3.1.0/share/man:/usr/local/Cellar/ruby/2.2.3/share/man:/usr/local/Cellar/s-lang/2.3.0/share/man:/usr/local/Cellar/scons/2.3.6/share/man:/usr/local/Cellar/speex/1.2rc1/share/man:/usr/local/Cellar/sqlite/3.8.11.1/share/man:/usr/local/Cellar/sslscan/1.8.0/share/man:/usr/local/Cellar/subversion/1.8.13/share/man:/usr/local/Cellar/texi2html/1.82/share/man:/usr/local/Cellar/tmux/2.0/share/man:/usr/local/Cellar/trash/0.8.5/share/man:/usr/local/Cellar/tree/1.7.0/share/man:/usr/local/Cellar/ttyrec/1.0.8/share/man:/usr/local/Cellar/unixodbc/2.3.2_1/share/man:/usr/local/Cellar/vim/7.4.826/share/man/ru.UTF-8:/usr/local/Cellar/watch/3.3.10/share/man:/usr/local/Cellar/wdiff/1.2.2/share/man:/usr/local/Cellar/webp/0.4.3/share/man:/usr/local/Cellar/wget/1.16.3/share/man:/usr/local/Cellar/xclip/0.12/share/man:/usr/local/Cellar/xz/5.2.1/share/man:/usr/local/Cellar/yasm/1.3.0/share/man:/usr/local/Cellar/rkhunter/1.4.2/share/man

# Initialization for FDK command line tools.Fri Nov  6 11:06:46 2015
FDK_EXE="/Users/rabshakeh/bin/FDK/Tools/osx"
PATH=${PATH}:/Users/rabshakeh/bin/FDK/Tools/osx:/usr/local/opt/findutils/libexec/gnubin:$PATH
export PATH
export FDK_EXE

function _screensharingon() {
    sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -off -restart -agent -privs -all -allowAccessFor -allUsers
}

function _getsubs() {
    echo
    echo
    echo "-----"
    pwd
    echo "-----"
    retval=$(subliminal download -l nl $1 | puf '0 if "Downloaded 0 subtitle" in str(lines) else 1')
    lang='nl'
    if [ "$retval" == "0" ]; then
        subliminal download -l en $1
        lang='en'
    fi
    fname=`echo $1 | puf "'.'.join(lines[0].split('.')[:-1])+'.$lang.srt'"`

    if [ -f $fname ]; then

        echo "  "$1 '->' $lang
        mv $fname `echo $1 | puf "'.'.join(lines[0].split('.')[:-1])+'.srt'"`
    fi
}

function _getallsubsext() {

    echo 'get subs for '$1
    for i in $(find . -maxdepth 1 -type f -name '*.'$1);
        do
            _getsubs $i
        done
}

function _getallsubs() {
    echo 'make safenames'
    _allsafe
    _getallsubsext 'mp4'
    _getallsubsext 'avi'
    _getallsubsext 'wmv'
    _getallsubsext 'mkv'
}

function _getfoldersubs() {
    currd=$(pwd)

    for i in $(find . -d 1 -type d); do
        cd $i&&_getallsubs $i
        cd $currd

        #subliminal download -l en *
        #subliminal download -l nl *

        ##cd ..
    done
}

function _print_servers() {
    echo -e "\033[92m1. uzziel\033[0m"
    echo -e "\033[90mssh rabshakeh@uzziel.a8.nl\033[0m"
    echo -e "\033[90mfunc: source code\033[0m"
    echo -e "\033[90mip: 188.166.115.155\033[0m"

    echo
    echo -e "\033[92m2. uriel\033[0m"
    echo -e "\033[90mfreeipa\033[0m"
    echo -e "\033[90mssh rabshakeh@uriel.a8.nl\033[0m"
    echo -e "\033[90m188.166.41.246\033[0m"

    echo
    echo -e "\033[92m3. jophiel\033[0m"
    echo -e "\033[90mipsilon/saml\033[0m"
    echo -e "\033[90mssh rabshakeh@jophiel.a8.nl\033[0m"
    echo -e "\033[90m188.166.52.154\033[0m"

    echo
    echo -e "\033[92m4. abigail\033[0m"
    echo -e "\033[90mwebserver governet\033[0m"
    echo -e "\033[90mssh rabshakeh@abigail.a8.nl\033[0m"
    echo -e "\033[90m188.166.101.102\033[0m"

    echo
    echo -e "\033[92m5. myitro\033[0m"
    echo -e "\033[90mdatabase governet\033[0m"
    echo -e "\033[90mssh rabshakeh@yitro.a8.nl\033[0m"
    echo -e "\033[90m178.62.251.74\033[0m"

    echo
    echo -e "\033[92m6.kohath\033[0m"
    echo -e "\033[90mcouchdb governet\033[0m"
    echo -e "\033[90mssh rabsshakeh@kohath.a8.nl\033[0m"
    echo -e "\033[90m178.62.208.233\033[0m"
    echo -e "\033[36mssh to (1-6), q=quit?\033[0m"

    read -p " " nums
    case $nums in
        1 ) ssh -v rabshakeh@uzziel.a8.nl;;
        2 ) ssh -v rabshakeh@uriel.a8.nl;;
        3 ) ssh -v rabshakeh@jophiel.a8.nl;;
        4 ) ssh -v rabshakeh@abigail.a8.nl;;
        5 ) ssh -v rabshakeh@yitro.a8.nl;;
        6 ) ssh -v rabshakeh@kohath.a8.nl;;

        [qQ] ) echo -e "\033[91mcancelled\033[0m";;
        * ) echo -e "\033[91munknown\033[0m";
            return;
            ;;
    esac
}

function _mandash() {
    globalpython3 /Users/rabshakeh/workspace/devenv/mandash/mandash.py $@
}

function _startfinder() {
    open -F /Applications/XtraFinder.app
    osascript -e  "tell application \"Finder\" to set the current view of the front Finder window to column view" > /dev/null
}

function _man2() {
    /usr/bin/open dash://$1:$2
    /usr/bin/man $@
}

function _resolution_width() {
    system_profiler SPDisplaysDataType |grep Resolution|puf '[x.split(":")[1].split(" x")[0] for x in lines][0].strip()'
}

function _top() {
    if [ "" == "$1" ]; then
        sudo /Users/rabshakeh/.pyenv/versions/3.5.2/bin/python ~/workspace/pip/pytop/pytopcmd/__init__.py -t 2
    else
        sudo /Users/rabshakeh/.pyenv/versions/3.5.2/bin/python ~/workspace/pip/pytop/pytopcmd/__init__.py -t $1
    fi
}

function _toascii() {
    globalpython3 ~/workspace/pip/consoleprinter/convertfile_ascii.py $1
}

function _press_option_key() {
    sleep 0.2
    applescript='tell application "System Events" to keystroke "'$1'" using option down'
    osascript -e "$applescript" 2> /dev/null > /dev/null
}

function _press_control_key() {
    sleep 0.2
    applescript='tell application "System Events" to keystroke "'$1'" using control down'
    osascript -e "$applescript" 2> /dev/null > /dev/null
}

function _press_command_key() {
    sleep 0.2
    applescript='tell application "System Events" to keystroke "'$1'" using command down'
    osascript -e "$applescript" 2> /dev/null > /dev/null
}

function _press_option_keycode() {
    sleep 0.2
    applescript='tell application "System Events" to key code '$1' using option down'
    osascript -e "$applescript" 2> /dev/null > /dev/null
}

function _press_command_keycode() {
    sleep 0.2
    applescript='tell application "System Events" to key code '$1' using command down'
    osascript -e "$applescript" 2> /dev/null > /dev/null
}

function _profile() {
    _subl ~/.bash_profile
}

function _close_app() {
    closeapps='
    tell application "'$1'"
        set mainID to id of front window
        close (every window whose id ≠ mainID)
    end tell
    delay 0.2
    activate application "'$1'"
    delay 0.2
    tell application "System Events"
        tell process "'$1'"
        keystroke "w" using {shift down, command down}
        end tell
    end tell'
    osascript -e  "$closeapps" #2> /dev/null > /dev/null
}

function _close_terms() {
    pwd > ~/.cwd
    _close_app "Terminal"
    _press_command_key 'k'
}

function _center_window(){
    if [ $(hostname) == "lycia" ]; then
        _press_option_key 'x'
    else
        _press_option_key 'f'
    fi
}

function _five_terms() {
    _close_terms
    _press_option_key 'q'
    _press_command_key 'n'
    _press_option_key 'p'
    _press_command_key 'n'
    _press_option_key 'm'
    _press_command_key 'n'
    _press_option_key 'z'
    _press_command_key 'n'
    _press_option_key 'g'

    for a in 1 2 3 4 5
    do
        _press_command_key 'k'
        _press_option_keycode 125
    done
    _press_command_key 'k'
}

function _hideall() {

    for a in 1 2 3 4 5 6 7
    do
        _press_command_key 'h'
        sleep 0.2
    done
}

function _move_win_left() {
    _press_option_key 's'
}

function _move_win_right() {
    _press_option_key 'k'
}

function _two_terms() {
    _close_terms
    _press_command_key 'n'
    _move_win_left
    _press_option_keycode 125
    sleep 0.5
    _move_win_right
    _press_command_key 'k'
    _press_option_keycode 125
    _press_command_key 'k'
    _press_option_keycode 125

    sleep 0.2
    _press_command_key 'k'
}

function _cterm() {
    _close_terms

    #_press_option_key 'k'
    _center_window
    _move_win_right
}

function _ofibase() {
    closeopen='
    tell application "Finder"
        close every window
    end tell
    '
    osascript -e  "$closeopen" 2> /dev/null > /dev/null
    open . > /dev/null
    sleep 0.2
    echo -e "\033[90mFinder at \033[33m`pwd`\033[0m"
}

function _ofi() {
    _ofibase
    _press_option_key 's'
}

function _ofi2() {
    _ofibase
    _press_option_key 'x'
    sleep 0.3
    _press_command_key 'u'
}

function _cfi() {
    osascript -e "tell application \"Finder\" to close every window"
    _ofi
}

function _encfile() {
    gpg -v --encrypt --sign --symmetric --passphrase `/bin/cat $HOME/.gpgpasswd` --recipient erik@a8.nl $1
    if [ $? -eq 0 ]
    then
        trash $1
        echo -e "\033[31mOriginal file is still in trash\033[0m"
    fi
}

function _cto() {
    _ofi
    _close_terms
    _press_command_key 'k'
    cd `cat ~/.cwd`
}

function _decfile() {
    gpg -v --passphrase `/bin/cat $HOME/.gpgpasswd` --symmetric  --sign --recipient erik@a8.nl $1
    trash $1
}

function _prettyjson() {
    globalpython3 -m json.tool $1 > tmp.json
    pygmentize tmp.json
    rm tmp.json
}

function _timedelta() {
    if [ ${#@} -lt 4 ]; then
        echo -e "timedelta he me hs ms\nhe=hour en\nhs=hour start"
        return
    fi
    puf "datetime.timedelta(hours=$1, minutes=$2)-datetime.timedelta(hours=$3, minutes=$4)"
}

function _trm() {
    todo -f rm $1
    _tls
}

function _done(){

    #todo append $1 "(done)"
    todo -a do $1 > /dev/null
    _tls
}

function _add() {
    sdate=$(date -r `date +%s` +"%y-%m-%d %H:%M")
    todo add $sdate": "$@
    _tls
}

function _ciphers() {
    SERVER=$1:443
    DELAY=1
    ciphers="SEED-SHA ECDH-ECDSA-AES128-SHA256 ECDH-RSA-DES-CBC3-SHA DES-CBC-SHA EXP-ADH-DES-CBC-SHA PSK-AES128-CBC-SHA ECDH-ECDSA-AES128-SHA ECDHE-RSA-DES-CBC3-SHA DH-DSS-DES-CBC3-SHA ECDHE-ECDSA-AES256-SHA384 ECDH-RSA-AES256-SHA SRP-AES-256-CBC-SHA DHE-DSS-AES256-GCM-SHA384 ECDH-ECDSA-DES-CBC3-SHA DH-DSS-CAMELLIA256-SHA ADH-AES256-GCM-SHA384 EXP-RC2-CBC-MD5 ECDHE-RSA-AES256-SHA EXP-ADH-RC4-MD5 PSK-3DES-EDE-CBC-SHA ECDHE-RSA-AES128-GCM-SHA256 ECDHE-ECDSA-AES256-GCM-SHA384 ECDHE-RSA-AES128-SHA ECDHE-ECDSA-RC4-SHA ADH-DES-CBC3-SHA AES256-GCM-SHA384 EDH-RSA-DES-CBC-SHA EXP-KRB5-RC2-CBC-SHA ECDH-ECDSA-AES256-GCM-SHA384 KRB5-RC4-MD5 EXP-EDH-DSS-DES-CBC-SHA ADH-AES256-SHA256 DHE-RSA-AES128-GCM-SHA256 NULL-SHA DH-RSA-SEED-SHA CAMELLIA256-SHA ADH-DES-CBC-SHA AECDH-RC4-SHA AECDH-AES256-SHA RC4-MD5 ECDHE-ECDSA-DES-CBC3-SHA SRP-3DES-EDE-CBC-SHA DH-DSS-AES256-GCM-SHA384 ECDH-ECDSA-RC4-SHA ECDH-ECDSA-AES128-GCM-SHA256 PSK-RC4-SHA ECDH-RSA-AES256-GCM-SHA384 DHE-RSA-AES128-SHA256 AES128-GCM-SHA256 DHE-DSS-AES256-SHA DHE-DSS-AES128-SHA DHE-RSA-CAMELLIA128-SHA SRP-RSA-AES-128-CBC-SHA KRB5-IDEA-CBC-MD5 ECDH-ECDSA-AES256-SHA DH-RSA-DES-CBC3-SHA ECDH-RSA-AES128-GCM-SHA256 EXP-DES-CBC-SHA SRP-DSS-AES-128-CBC-SHA ECDHE-RSA-AES256-SHA384 ADH-AES256-SHA DH-DSS-AES128-GCM-SHA256 DHE-DSS-AES128-SHA256 DES-CBC-MD5 ECDHE-RSA-AES128-SHA256 EXP-KRB5-RC4-SHA EXP-KRB5-DES-CBC-MD5 ECDH-ECDSA-NULL-SHA ECDHE-ECDSA-AES256-SHA DHE-RSA-AES256-SHA ADH-CAMELLIA128-SHA EDH-RSA-DES-CBC3-SHA KRB5-DES-CBC-SHA RC2-CBC-MD5 AECDH-NULL-SHA EXP-EDH-RSA-DES-CBC-SHA DH-DSS-AES128-SHA256 NULL-SHA256 ADH-RC4-MD5 DHE-RSA-AES256-SHA256 ECDH-RSA-RC4-SHA PSK-AES256-CBC-SHA ECDHE-RSA-RC4-SHA ECDH-RSA-NULL-SHA DH-RSA-AES128-SHA DHE-DSS-AES256-SHA256 EXP-KRB5-DES-CBC-SHA ADH-AES128-SHA256 AECDH-AES128-SHA AECDH-DES-CBC3-SHA NULL-MD5 DH-RSA-DES-CBC-SHA EDH-DSS-DES-CBC-SHA DHE-RSA-AES256-GCM-SHA384 SRP-DSS-3DES-EDE-CBC-SHA ECDH-RSA-AES256-SHA384 AES256-SHA256 ECDH-RSA-AES128-SHA ADH-SEED-SHA SRP-DSS-AES-256-CBC-SHA DHE-DSS-CAMELLIA128-SHA DHE-RSA-AES128-SHA ADH-AES128-SHA SRP-AES-128-CBC-SHA ECDHE-ECDSA-AES128-GCM-SHA256 ADH-CAMELLIA256-SHA DH-RSA-CAMELLIA256-SHA DES-CBC3-MD5 SRP-RSA-AES-256-CBC-SHA DH-RSA-AES128-SHA256 IDEA-CBC-SHA DH-DSS-AES128-SHA DH-RSA-AES256-SHA256 DH-RSA-AES256-GCM-SHA384 ECDHE-RSA-AES256-GCM-SHA384 CAMELLIA128-SHA AES128-SHA256 ECDH-ECDSA-AES256-SHA384 ECDH-RSA-AES128-SHA256 ECDHE-RSA-NULL-SHA ADH-AES128-GCM-SHA256 RC4-SHA KRB5-DES-CBC-MD5 KRB5-RC4-SHA DH-DSS-DES-CBC-SHA ECDHE-ECDSA-AES128-SHA256 DHE-DSS-SEED-SHA DH-DSS-AES256-SHA DHE-RSA-CAMELLIA256-SHA KRB5-DES-CBC3-MD5 DH-DSS-SEED-SHA KRB5-DES-CBC3-SHA SRP-RSA-3DES-EDE-CBC-SHA ECDHE-ECDSA-NULL-SHA DHE-DSS-CAMELLIA256-SHA DH-RSA-CAMELLIA128-SHA DH-RSA-AES256-SHA EXP-KRB5-RC4-MD5 DHE-DSS-AES128-GCM-SHA256 DH-DSS-AES256-SHA256 DH-RSA-AES128-GCM-SHA256 ECDHE-ECDSA-AES128-SHA IDEA-CBC-MD5 DES-CBC3-SHA KRB5-IDEA-CBC-SHA AES256-SHA AES128-SHA EXP-RC4-MD5 DH-DSS-CAMELLIA128-SHA EDH-DSS-DES-CBC3-SHA EXP-KRB5-RC2-CBC-MD5 DHE-RSA-SEED-SHA"
    for cipher in ${ciphers[@]}
    do
    result=$(echo -n | openssl s_client -cipher "$cipher" -connect $SERVER 2>&1)

    if [[ "$result" =~ ":error:" ]] ; then
      error=$(echo -n $result | cut -d':' -f6)

      #echo NO \($error\)
    else
      if [[ "$result" =~ "Cipher is ${cipher}" || "$result" =~ "Cipher    :" ]] ; then
        echo found $cipher...
      else
        echo UNKNOWN RESPONSE
        echo $result
      fi
    fi
    sleep $DELAY
    done
}

function _enable_eve() {
    globalpython3 $HOME/workspace/devenv/code/start_eve.py
    eval "$(docker-machine env eve)"
}
export -f _enable_eve

function encode() {
    echo -n $@ | perl -pe's/([^-_.$HOMEA-Za-z0-9])/sprintf("%%%02X", ord($1))/seg';
}

function _pss() {
    ps aux | grep -i "$1" | globalpython3 ~/workspace/devenv/code/sortps.py
}

function _todohelp() {
    echo -e 'https://github.com/ginatrapani/todo.txt-cli\n\nhttps://github.comwwww/ginatrapani/todo.txt-cli/blob/master/todo.sh\n\nUsage: todo [-fhpantvV] [-d todo_config] action [task_number] [task_description]
  Actions:
    add|a "THING I NEED TO DO +project @context"
    addm "THINGS I NEED TO DO
          MORE THINGS I NEED TO DO"
    addto DEST "TEXT TO ADD"
    append|app ITEM# "TEXT TO APPEND"
    archive
    command [ACTIONS]
    deduplicate
    del|rm ITEM# [TERM]
    depri|dp ITEM#[, ITEM#, ITEM#, ...]
    do ITEM#[, ITEM#, ITEM#, ...]
    help [ACTION...]
    list|ls [TERM...]
    listall|lsa [TERM...]

    listaddons
    listcon|lsc [TERM...]
    listfile|lf [SRC [TERM...]]
    listpri|lsp [PRIORITIES] [TERM...]
    listproj|lsprj [TERM...]
    move|mv ITEM# DEST [SRC]
    prepend|prep ITEM# "TEXT TO PREPEND"
    pri|p ITEM# PRIORITY
    replace ITEM# "UPDATED TODO"
    report
    shorthelp
  Actions can be added and overridden using scripts in the actions
  directory.

  See "help" for more details.'
}

function _fpath() {
    OUT=$(puf "os.path.join(os.getcwd(), '"$1"')")
    echo -e "\033[94m\n"$OUT"\033[0m\n"
}

function _logout() {
    read -p "Are you sure (y|Y)? " yn
    case $yn in
        [Yy]* ) ;;
        * ) echo "Cancelled";
            return;
            ;;
    esac
    globalpython3 $HOME/workspace/research/swapbaseloginimg.py
    sudo osascript -e 'tell app "System Events" to  «event aevtrlgo»'

    # Get the logged in users username
    loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

    # send logout
    su $loggedInUser -c osascript  'tell application "loginwindow" to  «event aevtrlgo»'
}

function _fpaths() {
    if [ -d "$1" ]; then
        echo -e "\033[90m"
        puf "[os.path.join(os.getcwd(), x) for x in os.listdir(os.path.join(os.getcwd(), '"$1"'))]"
    else
        if [ ! -d "$1" ]; then
            echo -e "\033[31m[$1] not a folder\033[90m"
        fi
        puf "[os.path.join(os.getcwd(), x) for x in os.listdir(os.getcwd())]"
    fi
    echo -e "\033[0m"
}

function _brf() {
    open -n /Applications/Google\ Chrome\ Canary.app --args -newtab "file://"`pwd`"/"$1
}

function _bru() {
    open -n /Applications/Google\ Chrome\ Canary.app --args -newtab "$1"
}

function _killall() {
    cmd="ps aux | tr '[:upper:]' '[:lower:]' | tr -d '\200-\377' | puf \"[(x[1], os.system('sudo kill '+str(x[1]))) for x in rows if '"`echo $1| tr '[:upper:]' '[:lower:]'`"' in str(x[10:]).lower() ]\""
    echo $cmd
    res=$(echo $cmd | sh)
    echo $res
    if [ '' == "$res" ]; then
        echo -e "\033[91m"$1" not found.\033[0m"
        return
    fi
    sleep 0.2
    ress=`ps aux | tr '[:upper:]' '[:lower:]' | tr -d '\200-\377' | grep "$1" | grep -v 'grep'`
    if [ '' == "$ress" ]; then
        echo -e "\033[32mok\033[0m"
    else
        echo -e "\033[31mprocesses left, trying -9\033[0m"
        echo -e "\033[37m -3"

        cmd="ps aux | tr '[:upper:]' '[:lower:]' | tr -d '\200-\377' | puf \"[(x[1], os.system('sudo kill -3 '+str(x[1]))) for x in rows if '"`echo $1| tr '[:upper:]' '[:lower:]'`"' in str(x[10:])]\""
        res=`eval $cmd`
        ps aux  | tr '[:upper:]' '[:lower:]' | grep "$1" | grep -v 'grep'
        echo -e "\033[31m -9"
        cmd="ps aux | tr '[:upper:]' '[:lower:]' | tr -d '\200-\377' | puf \"[(x[1], os.system('sudo kill -9 '+str(x[1]))) for x in rows if '"`echo $1| tr '[:upper:]' '[:lower:]'`"' in str(x[10:])]\""
        res=`eval $cmd`
        ps aux  | tr '[:upper:]' '[:lower:]' | grep "$1" | grep -v 'grep'
        echo -e "\033[0m"
    fi
}

function _rsyncfolder() {
    if [ '' == "$1" ]; then
        echo -e '\033[31mNo folders: rsyncfolder source dest\033[0m'
        return
    fi
    if [ '' == "$2" ]; then
        echo -e '\033[31mNo destination folder: rsyncfolder source dest\033[0m'
        return
    fi
    grsync --archive --human-readable --compress $1 $2
}

function _topy3() {
    futurize -w $1;
    pasteurize -w $1;
}

function _wwhich() {
    command=`which $1`
    echo $command
}

function _quitall() {
    ascpt='
    to logit(log_string)
        do shell script "echo " & quoted form of log_string
    end logit
    tell application "System Events" to set the visible of every process to true
    set white_list to {"Terminal"}
    tell application "Finder"
        try
            set process_list to the name of every process whose visible is true
        on error errMsg number errorNumber
            logit("An unknown error occurred:  " & errorNumber as text)
        end try
    end tell
    repeat with i from 1 to (number of items in process_list)
        set this_process to item i of the process_list
        if this_process is not in white_list then
            tell application this_process
                try
                    quit
                on error errMsg number errorNumber
                    logit("An unknown error occurred:  " & errorNumber as text)
                end try
            end tell
        end if
    end repeat
    '
    osascript -e "$ascpt"
    sleep 0.5
}

function _resetworkspace() {
    ascpt='
    to logit(log_string)
        do shell script "echo " & quoted form of log_string
    end logit
    tell application "System Events" to set the visible of every process to true

    set white_list to {"Terminal", "PyCharm", "Chromium", "Transmission", "App for WhatsApp"}
    tell application "Finder"
        try
            set process_list to the name of every process whose visible is true
        on error errMsg number errorNumber
            logit("An unknown error occurred:  " & errorNumber as text)
        end try
    end tell
    repeat with i from 1 to (number of items in process_list)
        set this_process to item i of the process_list
        if this_process is not in white_list then
            tell application this_process
                try
                    quit
                on error errMsg number errorNumber
                    logit("An unknown error occurred:  " & errorNumber as text)
                end try
            end tell
        end if
    end repeat
    '
    osascript -e "$ascpt"
    sleep 0.5
    _aopen 'Chromium.app'
    _cterm
    _ofi
    sleep 0.5
    _aopen 'PyCharm'
    sleep 0.5
    _press_option_key "f"
}

function _searchcode(){
    cgrep -c "$@" > ~/.cgrep.out; c/bin/cat ~/.cgrep.out; rm ~/.cgrep.out
}

function _gopen() {
    qs=`encode $@`
    echo -e "\033[90mGoogling with i'm feeling lucky:\033[0m"
    echo -e "\033[33m"$@"\033[0m"

    (open -n /Applications/Google\ Chrome.app --args -newtab "https://www.google.nl/search?site=&source=hp&btnI&q="$qs) ;
    (osascript ~/workspace/devenv/code/canary_to_foreground.applescript 2> /dev/null)
}

function _safari() {
    if [ -a "$1" ]; then

        echo "file -> "$1
        location="file://`pwd`/"$1
    else
        location=$1
    fi;

    #echo $location
    #osascript -e 'tell application "Safari" to open location "'$location'" activate end tell';
    #sleep 0.2;
    #osascript -e 'tell application "Safari" to activate';
    safariscript='
tell application "Safari"
    activate
    reopen
    tell (window 1 where (its document is not missing value))
        if name of its document is not "Untitled" then set current tab to (make new tab)
        set index to 1
    end tell
    set URL of document 1 to "'$location'"
end tell
tell application "System Events" to tell process "Safari"
    perform action "AXRaise" of window 1
end tell
'

    #echo -e "$safariscript1"
    osascript -e "$safariscript" 2> /dev/null > /dev/null
    sleep 0.1
    _center_window
}

function _google() {
    qs=`encode $@`
    echo -e "\033[90mGoogling: \033[0m\033[33m"$@"\033[0m"
    _safari "https://www.google.nl/search?site=&source=hp&q="$qs # &> /dev/null

    #open -n /Applications/Google\ Chrome.app --args -newtab "https://www.google.nl/search?site=&source=hp&q="$qs &> /dev/null
    #osascript ~/workspace/devenv/code/chrome_to_foreground.applescript &> /dev/null
}

function _chrome() {
    if [ -a "$1" ]; then

        echo "file -> "$1
        location="file://`pwd`/"$1

    elif [[ $1 != http* ]]; then
        location="http://"$1
    else
        location=$1
    fi;
    echo $location
    osascript -e 'tell application "Google Chrome" to open location "'$location'"';
    sleep 0.2;
    osascript -e 'tell application "Google Chrome" to activate';
}

function _nbook() {
    _safari http://127.0.0.1:8888;
}

function _concatmp3() {
    echo "concatting mp3's and making audiobook" $1'.m4b'
    sleep 1

    find *|grep .mp3|while read f; do echo "file '$f'" >> mylist.txt; done
    wait
    ffmpeg -f con/bin/cat -i mylist.txt -c copy $1".mp3"
    sleep 5
    wait
    nice -n 10 ffmpeg -i $1".mp3" -threads 8 -metadata album=$1 -metadata title=$1 -vn $1'.m4a'
    sleep 5
    wait
    mv $1'.m4a' $1'.m4b'
    wait
    rm $1'.mp3'
    rm mylist.txt
}

function _numcpus() {
    if [ ! "$numcpus" ]; then
        numcpus=`sysctl -a | grep hw.ncpu | sed -e "s/[a-z. _:]/ /g" | xargs`
    fi
    echo $numcpus
}

function splitfilename() {
    fullfile=$1
    filename=$(basename "$fullfile")
    dirname=$(dirname "$fullfile")

    extension="${filename##*.}"
    filename="${filename%.*}"
}

function splitfilenamesafe() {
    splitfilename "$1"
    filenameorg=`echo $filename`
    filename=`echo $filename|safe|xargs`

    extension=`echo $extension|safe|lwr|xargs`
}

function debug() {
    echo -e "\033[37m"$1"\033[0m"
}

function info() {
    echo -e "\033[94m"$1"\033[0m"
}

function warning() {
    echo -e "\033[31m"$1"\033[0m"
}

function succes() {
    echo -e "\033[32m"$1"\033[0m"
}

function convertm4v() {
    nice -n 20 ffmpeg -i $1.$2 -codec:v libx264 -profile:v main -preset slow -b:v 400k -maxrate 400k -bufsize 800k -vf scale=-1:480 -threads 0 -codec:a libfdk_aac -b:a 128k -strict experimental $1.m4v
}

function waitall() { # PID...

    ## Wait for children to exit and indicate whether all exited with 0 status.
    local errors=0
    pcnt=0

    while :; do
        let pcnt=0

        for pid in "$@"; do
            let pcnt=$pcnt+1
            shift

            if kill -0 "$pid" 2>/dev/null; then
                set -- "$@" "$pid"
            elif wait "$pid"; then
                succes "$pid exit 0"
            else
                warning "$pid exited with  non-zero exit status."
                ((++errors))
            fi
        done
        info "$pcnt processes remaining: $*"
        if [ $pcnt -lt `numcpus` ]; then
            succes "returning"
            break
        fi
        (("$#" > 0)) || break
                sleep 1
     done
    ((errors == 0))
}

function xxx2mp3() {
    pids=""
    cnt=0

    for i in *.$1
        do
        if [ -f "$i" ]; then
                splitfilenamesafe "$i"

                echo -e "\033[94m"$i"\033[96m    -> $filename.mp3\033[0m"
                if [ ! -f "$filename.mp3" ]; then
                    echo "`basename "$i" .$1`.jpg"
                    if [ -f "$filename.jpg" ]; then
                        $(nice -n 20 ffmpeg -i "$i" -i "$filename.jpg" -flags -global_header -ab 320k -ac 2  " $filename.mp3") &
                    else
                        $(nice -n 20 ffmpeg -i "$i" -ab 320k -ac 2  "$filename.mp3") &
                    fi
                    pids="$pids $!"
                    let cnt=$cnt+1
                    if [ $(($cnt % `numcpus`)) -eq 0 ] ; then
                        echo "waiting"
                        waitall $pids
                        pids=""
                    fi
                else
                    echo "$filename.mp3 exists"
                fi
            fi
        done
    waitall $pids
    wait
    stty sane
}

function xxx2mp4() {
    pids=""
    cnt=0

    for i in *.$1
        do
            splitfilenamesafe "$i"

            echo -e "\033[94m"$i"\033[96m    -> $filename.mp4\033[0m"
            $(nice -n 10 ffmpeg -i $i  $filename.mp4)
            pids="$pids $!"
            let cnt=$cnt+1
            if [ $(($cnt % `numcpus`)) -eq 0 ] ; then
                echo "waiting"
                waitall $pids
                pids=""
            fi
        done
    waitall $pids
    wait
    stty sane
}

function _recodemp3128() {
    unset IFS
    IFS=$'\n'

    for i in $(find . -type f -name '*.mp3');
        do
            splitfilenamesafe "$i"
            newname="$dirname/$filenameorg.128.mp3"
            br=`ffprobe -v quiet -print_format flat -show_format $i | grep bit_rate| sed 's/format.bit_rate=//' | sed -e 's/"//g' | tr -d " " `
            if [ "$br" -gt "129000" ]; then
                echo -e "\033[33m"`basename "$i"`: $br"bps\033[30m"
                lame --mp3input -b 128 "$i" "$newname";
                rm "$i";
                mv "$newname" "$i"
            fi
        done
    stty sane
    unset IFS
    echo -e "\033[0mdone"
}

function __allmp4ipad() {
    pids=""
    cnt=0

    for mvfile in *.$1
        do
            if [ -f "$mvfile" ]; then
                outfile=`echo $mvfile|safe|xargs|puf "[myStr[::-1].replace('_'[::-1], '.'[::-1], 1)[::-1] for myStr in lines]"`
                echo $mvfile
                nice -n 10 ffmpeg -i "$mvfile"  -acodec aac -ac 2 -strict experimental -ab 160k -s 1024x768 -vcodec libx264 -preset slow -profile:v baseline -level 30 -maxrate 10000000 -bufsize 10000000 -b 1200k -f mp4 -threads 0 $outfile
            fi
        done
    wait
    stty sane
}

function _allsafefiles () {
    unset IFS
    IFS=$'\n'

    for afile in $(find . -type f -maxdepth 1 -not -path '*/\.*' -not -path '*recycle*')
        do
            _safename $afile
        done
    stty sane
    unset IFS
}

function _allsaferunner() {
    _allsafe 1
    _allsafe 1
}

function _ytdlmp3() {
    youtube-dl -o '%(title)s.mp3' $1 -i --rm-cache-dir --restrict-filenames --write-info-json  --no-warnings --write-thumbnail --extract-audio  --audio-format=best --audio-quality=0 -kall
}
function _m4a2mp3 {
    ffmpeg -i "$1" -i `basename "$1" .m4a`.jpg -map 0:0 -map 1:0 -ab 320k -ac 2  " `basename "$1" .m4a`.mp3"
}

function _ytdlmp4() {
    youtube-dl -o '%(title)s.mp4' $1 -i --rm-cache-dir --restrict-filenames --write-info-json  --no-warnings --audio-format=best --write-thumbnail -f 137 --recode-video=mp4
    if [ "$?" == "1" ]; then
        youtube-dl -o '%(title)s.mp4' $1 -i --rm-cache-dir --restrict-filenames --write-info-json  --no-warnings --audio-format=best --write-thumbnail -f 136 --recode-video=mp4
        if [ "$?" == "1" ]; then
            youtube-dl -o '%(title)s.mp4' $1 -i --rm-cache-dir --restrict-filenames --write-info-json  --no-warnings --audio-format=best --write-thumbnail --recode-video=mp4
            if [ "$?" == "1" ]; then
                youtube-dl -F $1
                echo 'sorry, could not download'
            fi
        fi
    fi
}

function _rmt() {
    echo "">.rmt.txt

    for i in "$@"; do echo "'`pwd`/$i'">>.rmt.txt; done
    puf "[os.system('trash '+x) for x in open('.rmt.txt').read().strip().split('\n')if not str(x).strip().strip(\"'\").endswith('*')]" > /dev/null
    rm -f .rmt.txt
}

function _apply_coverjp(){

    for i in *.mp3; do
        lame --ti ./cover.jpg "$i"
    done
}

function _allmp4ipad() {
    __allmp4ipad 'avi';
    __allmp4ipad 'mkv';
}

function _mkv2mp4() {
    xxx2mp4 "mkv"
}

function _opus2mp3() {
    xxx2mp3 "opus"
}

function _all2mp3() {
    xxx2mp3 "opus"
    xxx2mp3 "m4a"
    xxx2mp3 "mp4"
    xxx2mp3 "avi"
    xxx2mp3 "mkv"
    xxx2mp3 "m4v"
    xxx2mp3 "flv"
}

function _m4b2mp3() {
    xxx2mp3  "m4b"
}

function _strip_prefix_num() {
    _allsafe
    ls | puf "['mv '+x+' '+'_'.join(x.split('_')[1:]) for x in lines if 'cover.jpg' not in x]" > run.sh
    source run.sh
    /bin/cat run.sh

    rm run.sh
    _ofi
}

function _flac2mp3() {
    if [ ! -f "cover.jpg" ]; then
        echo "need cover.jpg"
        return
    fi
    echo "converting flac to mp3"
    _allsafe
    xxx2mp3 "flac"
    mkdir -p flac; mv *.flac flac
    mkdir -p mp3; mv *.mp3 mp3
}

function _covermp3() {
    ffmpeg -i input.mp3 -i cover.png -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (Front)" out.mp3
}

function _sortmpx() {
    mkdir -p mp3
    mkdir -p mov

    files=$(find . -type f -name '*mp3')

    if [ ${#files[@]} -gt 0 ]; then
        mv *.mp3 mp3
    fi
    files=$(find . -type f -name '*mp4')

    if [ ${#files[@]} -gt 0 ]; then
        mv *.mp4 mov
    fi
    files=$(find . -type f -name '*mkv')

    if [ ${#files[@]} -gt 0 ]; then
        mv *.mkv mov
    fi
    tree
}

function _searchquote() {
    cd $HOME/workspace/brainyquote
    globalpython3 $HOME/workspace/brainyquote/printbrainyquote.py -d "$HOME/workspace/brainyquote/quotes" -s "$@"
    _setlastpath
}

function _openf() {
    globalpython3 ~/workspace/filetool/filetool.py $@
}

function _opendir() {
    globalpython3 $HOME/workspace/research/openfolder.py --fp=$1
}

function _jc() {
    curl -L $1 2> /dev/null | underscore print --color
}

_com() {
    $HOME/workspace/git_utils/commitfast.sh $1;
}

_gcom() {
    git commit -am '-'$1 > /dev/null; git status;
}

function _tarsnap() {
    tarsnap --keyfile /root/tarsnap.key --cachedir /root/tarsnap-cache $1
}

function _spip() {
    pip install $1
    pip3 install $1
}

function _mtar() {
    oldname=$1
    newname=`echo -e $1 | tr -d "'" | tr -d "\n"| tr -d "-" | sed -e "s/ /_/g" -e "s/[(]/_/g" -e "s/[&,\'!%]/_/g" -e "s/__/_/g" `
    if [ $newname != $1 ]; then
        completenewname=`date +%y%m%d%H%M`"_""$newname"

        echo -e "\033[94m"$1"\033[96m -> "`date +%y%m%d%H%M`"_"$newname
        #mv "$@" $completenewname
    fi
    foldername=`echo $newname| puf "lines[0].strip('/')"`
    tar -cz  -f $completenewname".tar.gz" $foldername
}

function _mtar() {
    newname=`echo -e $1 | tr -d "'" | tr -d "\n"| tr -d "-" | sed -e "s/ /_/g" -e "s/[(]/_/g" -e "s/[&,\'!%]/_/g" -e "s/__/_/g" | lwr`
    if [ $newname != $1 ]; then

        echo -e "\033[94mChange: $@\033[96m to -> "$newname
        read -p "Are you sure (y|Y)? " yn
        case $yn in
            [Yy]* ) echo 'changing name';
                    mv "$@" $newname;;

            * ) echo "keeping name: "$@;
                newname=$@;;
        esac
    fi
    timestamp=$(date +%y%m%d%H)
    foldername=`echo $newname| puf "lines[0].strip('/')"`
    tar -cvf $timestamp"_"$foldername.tar $foldername
    pigz --best -v $timestamp"_"$foldername.tar
}

function _mzip() {
    newname=`echo -e $1 | tr -d "'" | tr -d "\n"| tr -d "-" | sed -e "s/ /_/g" -e "s/[(]/_/g" -e "s/[&,\'!%]/_/g" -e "s/__/_/g" | lwr`
    if [ $newname != $1 ]; then

        echo -e "\033[94mChange: $@\033[96m to -> "$newname
        read -p "Are you sure (y|Y)? " yn
        case $yn in
            [Yy]* ) echo 'changing name';
                    mv "$@" $newname;;

            * ) echo "keeping name: "$@;
                newname=$@;;
        esac
    fi
    timestamp=$(date +%y%m%d%H)
    foldername=`echo $newname| puf "lines[0].strip('/')"`
    zip -0 -r $timestamp"_"$foldername.zip $foldername
}

function _utar() {
    pigz -cd ./$1 | tar -x
}

_only() {
    PROG='!'"/^$$|ack/&&/$(basename $SHELL)"'$/{print$2}'
    ps -ao pid,ppid,comm=| awk "$PROG" | xargs kill
}

function _make_project_links() {
    if [ ! -d _projects ]; then
        mkdir _projects
    fi

    for i in *
        do

            for j in $i/*
                do
                    if [ -d $j ]; then
                        if [ "$(basename $i)"!="_projects" ]; then
                            if [ "$i"!="_projects" ]; then
                                if [ ! -h "./_projects/""$(basename $j)" ]; then
                                    if [ "$j"!="_projects" ]; then
                                        ln -s "../$j" ./_projects/
                                        echo making $j
                                    fi
                                fi
                            fi
                        fi
                    fi
                done
        done
}

function _dps() {
    docker inspect $(docker ps -q)  2> ~/err.txt > /dev/null
    error=$(/bin/cat ~/err.txt | puf "[x for x in lines if 'inspect' in x and 'minimum' in x]")

    #rm ~/err.txt
    if [ "$error" != "" ]; then
        echo "no docker processe running"
    else
        ips=`docker inspect $(docker ps -q) | grep -v 'SecondaryIPAddresses'| egrep -i 'IPAddress|\"Name\":'  | puf "''.join(cols[1][0:2]).replace('\"', '').replace('/', '').replace(',', ' ').strip().strip(':')"`
        echo -e $ips | puf -l "'\033[35m'+row[0]+'\033[34m='+row[1]+'\033[0m'"
    fi
}

function _rst2md() {

    for i in *.rst
        do
            if [ -f $i ]; then
                globalpython3 $HOME/workspace/ghresearch/rst2md.py "$i"
                globalpython3 $HOME/workspace/ghresearch/mdcodeblockcorrect.py -f "$(dirname $1)"/"$(basename $1 ".rst").md"
            fi
        done
}

function _allrst() {
    echo -e "\033[31mALL RST: "`pwd`"\033[0m"
    read -p "Are you sure (y|Y)? " yn
    case $yn in
        [Yy]* ) ;;
        * ) echo "Cancelled";
            return;
            ;;
    esac
    echo -e "\033[91mconvert all rst to md recursively: "`pwd`"\033[0m"
    _renameallext markdown md

    for rstfile in $(find . -type f -name '*rst')
        do
            if [ -f $rstfile ]; then
                globalpython3 $HOME/workspace/ghresearch/rst2md.py "$rstfile"
            fi
        done
    _allmdcheck
}

function _allrstf() {
    echo -e "\033[91mconvert all rst to md recursively: "`pwd`"\033[0m"
    _renameallext markdown md

    for rstfile in $(find . -type f -name '*rst')
        do
            if [ -f $rstfile ]; then
                globalpython3 $HOME/workspace/ghresearch/rst2md.py -f "$rstfile"
            fi
        done
    _allmdcheckforce
}

function _allrstfq() {
    echo -e "\033[31mALL RST: "`pwd`"\033[0m"
    read -p "Are you sure (y|Y)? " yn
    case $yn in
        [Yy]* )_allrstf;;
        * ) echo "Cancelled";
            return;
            ;;
    esac
}

function _gitreset() {
    read -p "Are you sure (y|Y)? " yn
    case $yn in
        [Yy]* ) ;;
        * ) echo "Cancelled";
            return;
            ;;
    esac
    git reset --hard origin/master;
    git clean -f
}

function _remove_code() {
    echo -e "Remove code in:\033[91m"
    echo

    echo -e "-> "`pwd`
    echo -e "\033[0m"

    read -p "(y/n)? " yn
    case $yn in
        [Yy]* ) find . -type l -exec rm -f {} \;
                find . -name '*.py' -exec rm -rf {} \;
                find . -name '*.*doc*' -exec rm -rf {} \;
                find . -name '*.sh' -exec rm -rf {} \;
                find . -name '*.ini' -exec rm -rf {} \;
                find . -name '*.cfg' -exec rm -rf {} \;
                find . -name '*.yml' -exec rm -rf {} \;
                find . -name '*.coffee' -exec rm -rf {} \;
                find . -name '*.go' -exec rm -rf {} \;
                find . -name '*.mo' -exec rm -rf {} \;
                find . -name '*.po' -exec rm -rf {} \;
                find . -name '.git'  -exec rm -Rf {} \;
                find . -name '*.htm' -exec rm -rf {} \;
                find . -name '*.css' -exec rm -rf {} \;
                find . -name '*.jar' -exec rm -rf {} \;
                find . -name '*.txt' -exec rm -rf {} \;
                find . -name '*.csv' -exec rm -rf {} \;
                find . -name '*.json' -exec rm -rf {} \;
                find . -name '*.in' -exec rm -rf {} \;
                find . -name '*.html' -exec rm -rf {} \;
                find . -name '*.c' -exec rm -rf {} \;
                find . -name 'man' -exec rm -rf {} \;
                find . -name 'commands' -exec rm -rf {} \;
                find . -name 'Godeps*' -exec rm -rf {} \;
                find . -name '_Godeps*' -exec rm -rf {} \;

                find . -depth -empty -delete
                find . ! -name '*.*' -type f -exec bash -c 'mv "$1" "$1.txt"' -- {} \;
                find . -name '*.txt' -type f -exec bash -c 'mv "$1" "${1/.txt/.md}"' -- {} \;
                find . -name 'tempfolder*' -exec rm -rf {} \;

                wait;;
        [Nn]* ) echo "skip";;
        * ) echo "Cancelled";
            return;
            ;;
    esac
}

function _makedocs() {
    read -p "Are you sure (y|Y)? " yn
    case $yn in
        [Yy]* ) ;;
        * ) echo "Cancelled";
            return;
            ;;
    esac
    echo -e "\033[91mconvert all rst to md recursively: "`pwd`"\033[0m"
    _renameallext markdown md
    _renameallext txt md

    for rstfile in $(find . -type f -name '*rst')
        do
            if [ -f "$rstfile" ]; then
                globalpython3 $HOME/workspace/ghresearch/rst2md.py -fvc "$rstfile"
            fi
        done
    _allmdcheck
}

function _py2html() {
    mkdir -p codehtml

    for pyfile in $(find . -type f -name '*py')
        do
            if [ -f $pyfile ]; then
                groc -o codehtml --hl=pygments $pyfile
            fi
        done
}

function _python() {
    echo -e "\033[35m> starting python\033[0m\n"
    globalpython3 $@
}

function _allmdcheck() {
    echo -e "\033[31mALL MD: "`pwd`"\033[0m"
    read -p "Are you sure (y|Y)? " yn
    case $yn in
        [Yy]* ) ;;
        * ) echo "Cancelled";
            return;
            ;;
    esac
    echo -e "\033[91mcheck all mdfiles: "`pwd`"\033[0m"

    for mdfile in $(find . -type f -name '*markdown')
        do
            if [ -f $mdfile ]; then
                globalpython3 $HOME/workspace/ghresearch/mdcodeblockcorrect.py $mdfile
            fi
        done

    for mdfile in $(find . -type f -name '*md')
        do
            if [ -f $mdfile ]; then
                globalpython3 $HOME/workspace/ghresearch/mdcodeblockcorrect.py $mdfile
            fi
        done
}

function _allmdcheckforce() {
    echo -e "\033[91mcheck all mdfiles: "`pwd`"\033[0m"

    for mdfile in $(find . -type f -name '*markdown')
        do
            if [ -f $mdfile ]; then
                globalpython3 $HOME/workspace/ghresearch/mdcodeblockcorrect.py -f $mdfile
            fi
        done

    for mdfile in $(find . -type f -name '*md')
        do
            if [ -f $mdfile ]; then
                globalpython3 $HOME/workspace/ghresearch/mdcodeblockcorrect.py -f $mdfile
            fi
        done
}

function _allmdcheckforceq() {
    echo -e "\033[31mALL MDCHECK: "`pwd`"\033[0m"
    read -p "Are you sure (y|Y)? " yn
    case $yn in
        [Yy]* ) ;;
        * ) echo "Cancelled";
            return;
            ;;
    esac
    _allmdcheckforce
}

function _mdcheck() {
    echo -e "\033[91mcheck mdfile: $1\033[0m"
    _md2md $1
}
function findfilex {
    find "$1" -iname "*$2*";
}

function _py2or3() {

    # to prevent mistakes, or introduce sysbugs
    read -p "Which globalpython3 (q/2/3, default=3)? " yn
    pyargs=$1
    case $yn in
        [2]* ) globalpython3 $@;;
        [3]* ) _py3 $@;;
        [q]* ) return;;

        * ) echo "defaulting to python"&&globalpython3 $@;;
    esac
}

function _ccatpre() {
    if [[ $1 == *"xml"* ]]; then
        if [ -f pretty.xml ]; then
            rm -f ./pretty.xml
        fi
        echo $1 | xargs xmllint --format > pretty.xml 2> /dev/null
    elif [[ $1 == *"json"* ]]; then
        if [ -f pretty.json ]; then
            rm -f ./pretty.json
        fi
        globalpython3 -m json.tool $1 > pretty.json 2> /dev/null
    fi
    if [ -f ~/ccat.tmp ]; then
        rm -f ~/ccat.tmp
    fi;
    if [ -f pretty.json ]; then
        /usr/local/bin/pygmentize3 -g -O style=colorful pretty.json > ~/ccat.tmp
        rm -f pretty.json
    elif [ -f pretty.xml ]; then
        /usr/local/bin/pygmentize3 -g -O style=colorful pretty.xml > ~/ccat.tmp
        rm -f pretty.xml
    else
        /usr/local/bin/pygmentize3 -g -O style=colorful $1 > ~/ccat.tmp
    fi
}

function _ccatpost() {
    if [ -f ~/ccat.tmp ]; then
        rm -f ~/ccat.tmp
    fi;
}

function _ccat_question() {
    read -p "Which cat (q/original(o)/color(C))? " oc
    pyargs=$1
    case $oc in
        [q]* ) return;;
        [o]* ) /bin/cat $@;
               return;;
        [c]* ) ;;
        * ) _ccatpre $@;
            /bin/cat ~/ccat.tmp | less -EirX
            _ccatpost $@;
            return;;
    esac
}

function _ccat() {
    _ccatpre $@;
    /bin/cat ~/ccat.tmp | less -EirX
    _ccatpost $@;
}

function _c() {
    clear;
    /bin/cat ~/time.txt
    echo -e "\033[36m$@:\n--\033[0m"
    _c/bin/cat $@;
}

function _rsscurl() {
    curl -s $1 | xmllint --format-| pygmentize3 -g -O style=colorful
}

function _ccurl() {
    if [ -f ~/ccurl.tmp ]; then
        rm -f ~/ccurl.tmp
    fi;
    curl -s $1 > ~/ccurl.tmp
    string=`/bin/cat ~/ccurl.tmp`
    if [[ $string == *"<html"* ]]; then
        links $1
    else
        /usr/local/bin/pygmentize3 -g -O style=colorful ~/ccurl.tmp > ~/ccurl2.tmp;
        /bin/cat ~/ccurl2.tmp | less -EirX;
    fi
    if [ -f ~/ccurl.tmp ]; then
        rm -f ~/ccurl.tmp
    fi;
    if [ -f ~/ccurl2.tmp ]; then
        rm -f ~/ccurl2.tmp
    fi;
}

function _hist() {
    globalpython3 $HOME/workspace/pip/historybash/historybash/__init__.py -f 1 $@ > ~/.hist.tmp
    /bin/cat ~/.hist.tmp # | more -r
    rm ~/.hist.tmp
}

function _md2man() {
    pandoc -s -f markdown_github -t man $1 > "$(dirname $1)"/"$(basename $1 ".md").man"
}

function _mdcat() {
    _md2man $1
    man "$(dirname $1)"/"$(basename $1 ".md").man"
    rm "$(dirname $1)"/"$(basename $1 ".md").man"
}

function _kube_version_change() {
    if [ -f "$1" ]; then
        /Users/rabshakeh/workspace/forks/kubernetes/_output/local/bin/darwin/amd64/kube-version-change -i "$1" --out-version="v1beta3" --output="-"
    else
        echo -e "\033[31mkube_version_change: no file provided\033[0m"
    fi;
}

function _sal() {
    data1=$@
    echo $data1 | globalpython3 ~/workspace/devenv/code/sortals.py
}

function _pipboth() {
    read -p "Which pip (q/2/3)? " yn
    pyargs=$1
    case $yn in
        [2]* ) /usr/local/bin/pip2 $@;;
        [3]* ) /usr/local/bin/pip3 $@;;

        [q]* ) return;;
        * ) return;;
    esac
}

function _tyml() {
    if [ -f "$1" ]; then
        puf "[x for x in yaml.load(open(\"$1\"))]"
    fi;
}

function _processhasfile() {
    sudo opensnoop | grep $1
}

function _ratecode() {
    pylint -j 8 --rcfile=$HOME/.pylint.conf $1 | grep "Your code has" | sani
}

function _newmail() {
    osa1='
tell application "Mail"\n

\ttell (make new outgoing message)\n'
    osa2="\t\tset subject to \"$1\"\n"
    osa3="\t\tset content to \"$2\"\n"

    osa4="\t\tmake new to recipient at end of to recipients with properties {address:\"$3\"}\n"
    if [ "$4" != "" ]; then
        osa5="\t\tmake new attachment with properties {file name:(POSIX file \"`pwd`/$4\")} at after the last paragraph\n"
    fi
    osa6='\tend tell\n
end tell'
    osa=$osa1$osa2$osa3$osa4$osa5$osa6
    echo -e $osa
    osascript -e "$osa"
}

function _md2html() {
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    _md2md $1

    #echo -e "\033[94m"$1"\033[96m    ->    "$(dirname $1)"/"$(basename $1 ".md").html"\033[0m"
    pandoc --from=markdown_github --to=html --highlight-style=pygments "$(dirname $1)"/"$(basename $1)" -o "$(dirname $1)"/"$(basename $1 ".md").html.tmp"
    /bin/cat $HOME/workspace/ghresearch/mdhtml1.html > "$(dirname $1)"/"$(basename $1 ".md").html"
    /bin/cat $HOME/workspace/ghresearch/md2html.css >> "$(dirname $1)"/"$(basename $1 ".md").html"
    /bin/cat $HOME/workspace/ghresearch/mdhtml1_5.html >> "$(dirname $1)"/"$(basename $1 ".md").html"

    /bin/cat "$(dirname $1)"/"$(basename $1 ".md").html.tmp" >> "$(dirname $1)"/"$(basename $1 ".md").html"
    title=$(basename `pwd`)
    echo "<title>"$title"</title>" >> "$(dirname $1)"/"$(basename $1 ".md").html"
    /bin/cat $HOME/workspace/ghresearch/mdhtml2.html >> "$(dirname $1)"/"$(basename $1 ".md").html"
    rm "$(dirname $1)"/"$(basename $1 ".md").html.tmp"
    IFS=$SAVEIFS
}

function _allhtml2mdexec() {
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    for htmlfile in $(find . -type f -name '*html')
        do
            if [ -f $mdfile ]; then
                pwd
                name=${htmlfile##*/}
                base=${name%.html}
                scwd=`pwd`
                cd $(dirname $htmlfile)
                cmd=`echo pandoc --from=html --to=markdown_github \"$(basename $htmlfile)\" -o \"$base.md\"`
                echo $cmd > cmd.sh
                chmod +x cmd.sh

                ./cmd.sh
                rm ./cmd.sh
                chown rabshakeh *.md
                cd `echo $scwd`
            fi
            echo $htmlfile
        done
    IFS=$SAVEIFS
}

function _allhtml2md() {
    echo -e "\033[31mALL HTML2MD: "`pwd`"\033[0m"
    read -p "Are you sure (y|Y)? " yn
    case $yn in
        [Yy]* ) ;;
        * ) echo "Cancelled";
            return;
            ;;
    esac
    echo -e "\033[91mconvert all html to md recursively: "`pwd`"\033[0m"
    _allhtml2mdexec
}

function _allmd2pdf() {
    echo -e "\033[31mAll md2pdf: "`pwd`"\033[0m"
    read -p "Are you sure (y|Y)? " yn
    case $yn in
        [Yy]* ) ;;
        * ) echo "Cancelled";
            return;
            ;;
    esac
    echo -e "\033[91mconvert all md to pdf recursively: "`pwd`"\033[0m"
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    for mdfile in $(find . -type f -name '*md')
        do
            if [ -f $mdfile ]; then
                _md2pdf "$mdfile"
            fi
        done
    IFS=$SAVEIFS
}

function _allhtml2pdf() {
    echo -e "\033[31mAll html2pdf: "`pwd`"\033[0m"
    read -p "Are you sure (y|Y)? " yn
    case $yn in
        [Yy]* ) ;;
        * ) echo "Cancelled";
            return;
            ;;
    esac
    echo -e "\033[91mconvert all html to pdf recursively: "`pwd`"\033[0m"
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    for hfile in $(find . -type f -name '*html')
        do
            if [ -f $hfile ]; then
                _html2pdf "$hfile"
            fi
        done
    IFS=$SAVEIFS
}

function _allmd2epub() {
    echo -e "\033[31mAll md2epub: "`pwd`"\033[0m"
    read -p "Are you sure (y|Y)? " yn
    case $yn in
        [Yy]* ) ;;
        * ) echo "Cancelled";
            return;
            ;;
    esac
    echo -e "\033[91mconvert all md to epub recursively: "`pwd`"\033[0m"
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    for mdfile in $(find . -type f -name '*md')
        do
            if [ -f $mdfile ]; then
                _md2epub "$mdfile"
            fi
        done
    IFS=$SAVEIFS
}

function _allmd2md() {
    echo -e "\033[31mAll md2md: "`pwd`"\033[0m"
    read -p "Are you sure (y|Y)? " yn
    case $yn in
        [Yy]* ) ;;
        * ) echo "Cancelled";
            return;
            ;;
    esac
    echo -e "\033[91mrecode all md to md recursively: "`pwd`"\033[0m"
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    for mdfile in $(find . -type f -name '*md')
        do
            if [ -f $mdfile ]; then
                _md2md "$mdfile"
            fi
        done
    IFS=$SAVEIFS
}

function _allmd2html() {
    echo -e "\033[31mALL MD2HTML: "`pwd`"\033[0m"
    read -p "Are you sure (y|Y)? " yn
    case $yn in
        [Yy]* ) ;;
        * ) echo "Cancelled";
            return;
            ;;
    esac
    echo -e "\033[91mconvert all md to html recursively: "`pwd`"\033[0m"
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    for mdfile in $(find . -type f -name '*md')
        do
            if [ -f $mdfile ]; then
                _md2html "$mdfile"
            fi
        done
    IFS=$SAVEIFS
}

function _allmd2htmlnoconfirm() {
    echo -e "\033[91mconvert all md to html recursively: "`pwd`"\033[0m"
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    for mdfile in $(find . -type f -name '*md')
        do
            if [ -f $mdfile ]; then
                _md2html "$mdfile"
            fi
        done
    IFS=$SAVEIFS
}

function _screensharingon() {
    sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -off -restart -agent -privs -all -allowAccessFor -allUsers
}

function _ghsearch() {
    if [ "$#" -ne 3 ]; then
        echo -e '\033[33mglobalpython3 $HOME/workspace/ghresearch/githubsearch.py -c erik@a8.nl `/bin/cat $HOME/.ghpwd` $HOME/Desktop/ghresearch '$@'\033[0m'
        echo
        return
    fi
    mkdir -p $HOME/Desktop/ghresearch
    echo "globalpython3 $HOME/workspace/ghresearch/githubsearch.py -c erik@active8.nl `/bin/cat $HOME/.ghpwd` $HOME/Desktop/ghresearch $@"
    globalpython3 $HOME/workspace/ghresearch/githubsearch.py -c erik@active8.nl `/bin/cat $HOME/.ghpwd` $HOME/Desktop/ghresearch $@
    if [ "$?" == "0" ]; then
        cd $HOME/Desktop/ghresearch
        globalpython3 $HOME/workspace/ghresearch/genindex.py $HOME/Desktop/ghresearch
        _allmd2htmlnoconfirm
    else
        echo -e '\033[33mglobalpython3 $HOME/workspace/ghresearch/githubsearch.py -c erik@a8.nl `/bin/cat $HOME/.ghpwd` $HOME/Desktop/ghresearch '$@'\033[0m'
    fi
}

function _json2md() {
    echo "$(dirname $1)"/"$(basename $1 ".json").md"
    pandoc --from=json --to=markdown_github "$(dirname $1)"/"$(basename $1)" -o "$(dirname $1)"/"$(basename $1 ".json").md"
    _md2md "$(basename $1 ".json").md"
}

function _json2md() {
    echo "$(dirname $1)"/"$(basename $1 ".json").md"
    pandoc --from=json --to=markdown_github "$(dirname $1)"/"$(basename $1)" -o "$(dirname $1)"/"$(basename $1 ".json").md"
    _md2md "$(basename $1 ".json").md"
}

function _txt2md() {
    /bin/cat $1 | puf '[x.replace("     ", "    ", 1) for x in lines]'
    echo "$(dirname $1)"/"$(basename $1 ".txt").md"
    pandoc --from=textile --to=markdown_github "$(dirname $1)"/"$(basename $1)" -o "$(dirname $1)"/"$(basename $1 ".txt").md"
    globalpython3 $HOME/workspace/ghresearch/mdcodeblockcorrect.py "$(dirname $1)"/"$(basename $1 ".txt").md"
    _md2md "$(basename $1 ".txt").md"
}

function _rstxt2docx() {
    echo "$(dirname $1)"/"$(basename $1 ".md").docx"
    pandoc --from=rst --to=docx "$(dirname $1)"/"$(basename $1)" -o "$(dirname $1)"/"$(basename $1 ".rst").docx"
}

function _md2docx() {
    echo "$(dirname $1)"/"$(basename $1 ".md").docx"
    pandoc --from=markdown_github --to=docx "$(dirname $1)"/"$(basename $1)" -o "$(dirname $1)"/"$(basename $1 ".md").docx"
}

function _mamdocx2md() {
    echo "$(dirname $1)"/"$(basename $1 ".md").docx"
    mammoth $1 > "$(dirname $1)"/"$(basename $1 ".docx").md"
    globalpython3 ~/workspace/devenv/markdown/tools/mdonelineparachaps.py "$(dirname $1)"/"$(basename $1 ".docx").md"
}

function _man2md() {
    /bin/cat $1 |  groff -mandoc -Thtml > temp.html
    pandoc --from=textile --to=markdown_github temp.html -o "$(dirname $1)"/"$(basename $1).html"
    rm temp.html
    _html2md "$(dirname $1)"/"$(basename $1).html"
    rm -f "$(dirname $1)"/"$(basename $1).html"
}

function _html2mdmammoth() {
    workfile=$1
    echo $workfile" to md"
    pandoc --atx-headers --from=html --to=markdown "$(dirname $workfile)"/"$(basename $workfile)" -o temp1.md
    _md2md temp1.md
    pandoc --from=markdown --to=docx temp1.md -o temp.docx
    rm temp1.md
    mammoth temp.docx > temp.html
    rm temp.docx

    pandoc --atx-headers --from=html --to=markdown_github temp.html -o temp.md
    rm temp.html
    _md2md temp.md

    /bin/cat temp.md | puf "[x.replace(') [', ')\n [').replace('\\#', '#') for x in lines]" > temp2.md
    rm temp.md
    _md2md temp2.md

    /bin/cat temp2.md | puf "[x.replace(') [', ')\n [').replace('\\#', '#').replace('****** bash ', '').replace('****** html ', '').replace('****** bash', '').replace('****** html', '').replace('******', '') for x in lines]" > "$(basename $workfile ".html").md"
    rm temp2.md
}

function _html2md() {
    echo "$(dirname $1)"/"$(basename $1 ".html").md"
    pandoc --atx-headers --from=html --to=markdown_github "$(dirname $1)"/"$(basename $1)" -o "$(dirname $1)"/"$(basename $1 ".html").md"
    _md2md "$(basename $1 ".html").md"
}

function _html2docx() {
    echo "$(dirname $1)"/"$(basename $1 ".html").docx"
    pandoc --atx-headers --from=html --to=docx "$(dirname $1)"/"$(basename $1)" -o "$(dirname $1)"/"$(basename $1 ".html").docx"
}

function _md2mdmammoth() {
    echo "$(dirname $1)"/"$(basename $1 ".html").md"
    cat $1 > $1.backup
    _md2html $1
    _html2docx "$(dirname $1)"/"$(basename $1 ".md").html"
    mammoth "$(dirname $1)"/"$(basename $1 ".md").docx" > "$(dirname $1)"/"$(basename $1 ".md").html"

    if [ $? -eq 0 ]; then
        pandoc --atx-headers --from=html --to=markdown_github "$(dirname $1)"/"$(basename $1 ".md").html" -o "$(dirname $1)"/"$(basename $1)"
        if [ $? -eq 0 ]; then
            _md2md "$(basename $1)  "
            rm "$(dirname $1)"/"$(basename $1 ".md").docx"
            rm "$(dirname $1)"/"$(basename $1 ".md").html"
        else
            cat $1.backup > $1
        fi
    else
        cat $1.backup > $1
    fi
}

function _md2md() {
    pandoc --atx-headers --from=markdown_github --to=markdown_github $1 -o $1
    wait $!
    globalpython3 $HOME/workspace/ghresearch/mdcodeblockcorrect.py -f $1
    wait $!
}

function _docx2md() {
    echo "$(dirname $1)"/"$(basename $1 ".docx").md"
    pandoc --from=docx --to=markdown_github "$(dirname $1)"/"$(basename $1)" -o "$(dirname $1)"/"$(basename $1 ".docx").md"
    _md2md "$(basename $1 ".docx").md"
}

function _md2epub() {
     cpwd=`pwd`
     echo "$(dirname $1)"/"$(basename $1 ".md").epub"
     cd $(dirname $1)

     pandoc --from=markdown_github --to=epub --epub-embed-font=/Users/rabshakeh/workspace/devenv/fonts/computermodern/Sans/ttf/cmunss.ttf "$(basename $1)" -o "$(basename $1 ".md").epub"
     cd $cpwd
 }

function _md2pdf() {
    /bin/cat $1 > md2pdf.backup
    globalpython3 $HOME/workspace/ghresearch/mdcodeblockcorrect.py -fp $1
    _toascii $1
    PATH=$PATH:/usr/local/texlive/2015/bin/x86_64-darwin
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    echo "$(dirname $1)"/"$(basename $1 ".md").pdf"
    pandoc --latex-engine=pdflatex -N --data-dir=$HOME/workspace/documentation -V "geometry:paperwidth=8.26387in" \
    -V "geometry:paperheight=29.7cm" \
    -V "geometry:vmargin=1.4cm" \
    -V "geometry:hmargin=1.6cm" \
    -V fontsize=11pt --variable linestretch="1.5" --variable sansfont="CMU Bright Roman" --variable monofont="AnonymousPro"  --from=markdown_github --to=latex $1 -o "$(dirname $1)"/"$(basename $1 ".md").pdf"
    IFS=$SAVEIFS
    /bin/cat md2pdf.backup > $1
    rm -f md2pdf.backup
}

function _epub2pdf() {
    PATH=$PATH:/usr/local/texlive/2015/bin/x86_64-darwin
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    echo "$(dirname $1)"/"$(basename $1 ".epub").pdf"
    pandoc --latex-engine=pdflatex -N --data-dir=$HOME/workspace/documentation -V "geometry:paperwidth=8.26387in" \
    -V "geometry:paperheight=29.7cm" \
    -V "geometry:vmargin=1.4cm" \
    -V "geometry:hmargin=1.6cm" \
    -V fontsize=11pt --variable linestretch="1.5" --variable monofont="AnonymousPro"  --from=epub --to=latex $1 -o "$(dirname $1)"/"$(basename $1 ".md").pdf"
    IFS=$SAVEIFS
}

function _html2pdf() {
    _toascii $1
    PATH=$PATH:/usr/local/texlive/2015/bin/x86_64-darwin
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    echo "$(dirname $1)"/"$(basename $1 ".html").pdf"
    pandoc --latex-engine=pdflatex -N --data-dir=$HOME/workspace/documentation -V "geometry:paperwidth=8.26387in" \
    -V "geometry:paperheight=29.7cm" \
    -V "geometry:vmargin=1.4cm" \
    -V "geometry:hmargin=1.6cm" \
    -V fontsize=11pt --variable linestretch="1.5" --variable monofont="AnonymousPro"  --from=html --to=latex $1 -o "$(dirname $1)"/"$(basename $1 ".html").pdf"
    IFS=$SAVEIFS

    #open "$(dirname $1)"/"$(basename $1 ".md").pdf"
}

#Universalis
#Opensans Light
#Mint Spirit No. 
#Lato Light, Regular
#Droid Sans Mono, Regular

function _singlemd2pdf() {
    _md2pdf $1
    open "$(dirname $1)"/"$(basename $1 ".md").pdf"
}

function _mdclean() {
    _md2html $1
    _html2md "$(dirname $1)"/"$(basename $1 ".md").html"
    rm "$(dirname $1)"/"$(basename $1 ".md").html"
    open $1
}

function _jsjpicks(){
    globalpython3 $HOME/workspace/research/jsjpicksjsonconvert.py > jsjpicks.md
}

function _lintpy() {
    pylint --optimize-ast=y -j 8 --rcfile=$HOME/.pylint.conf $1 | saniless
}

function _search() {

    echo -e "\033[94msearch: \033[94m../"$(basename `pwd`)" \033[94mfor \033[91m$1:\033[0m"
    globalpython3 ~/workspace/devenv/code/searchfiles.py -r . all $1
}

function _grepsearchpy() {
        find . -type f \( -name "*.py" \)  | xargs /bin/cat | grep '$1'
}

function _grepsearch() {

    grep -i -r "$1" `pwd` #| puf '["\033[93m"+x.split(":")[0].replace(os.getcwd(), ".")+"\033[35m -> \033[34m"+x.split(":")[1]+"\033[0m" for x in lines if ":" in x]'
}

function _csearch() {

    echo -e "\033[94msearch: \033[94m../"$(basename `pwd`)" \033[94mfor \033[91m$1:\033[0m"
    globalpython3 ~/workspace/devenv/code/searchfiles.py . all $1
}

function _gcompush() {
    if [ "" == "$1" ]; then
        echo -e "\033[31mno comment given, commit '-'\033[0m"
        git commit -am "-";
    else
        echo "committing: $@"
        git commit -am "$1 $2 $3 $4 $5 $6";
    fi
    git push
}

function _qfinda(){
    echo "/Applications"
    sudo find /Applications -name $1
    echo "/Downloads"
    sudo find /Downloads -name $1

    echo "/Library"
    sudo find /Library -name $1
    echo "/System"
    sudo find /System -name $1
    echo "/Users"
    sudo find /Users -name $1
    echo "/bin"
    sudo find /bin -name $1
    echo "/etc"
    sudo find /etc -name $1
    echo "/home"
    sudo find /home -name $1
    echo "/opt"
    sudo find /opt -name $1
    echo "/private"
    sudo find /private -name $1
    echo "/root"
    sudo find /root -name $1
    echo "/sbin"
    sudo find /sbin -name $1
    echo "/tmp"
    sudo find /tmp -name $1
    echo "/usr"
    sudo find /usr -name $1
    echo "/var"
    sudo find /var -name $1
}

function _makeallfiles() {
    echo "fastraid"
    cd /Volumes/fastraid&&find . > ~/fastraid.txt
    echo "rabshakeh"
    cd /Users/rabshakeh&&find . > ~/rabshakeh.txt
    echo "/usr"
    cd /usr&&find . > ~/usr.txt
    echo "bin"
    cd /bin&&find . > ~/bin.txt
    echo "combine"
    /bin/cat ~/rabshakeh.txt > ~/allfiles.txt
    /bin/cat ~/usr.txt >> ~/allfiles.txt
    /bin/cat ~/bin.txt >> ~/allfiles.txt
    /bin/cat ~/fastraid.txt >> ~/allfiles.txt

    rm ~/rabshakeh.txt
    rm ~/usr.txt
    rm ~/bin.txt
    rm ~/fastraid.txt
}

function _try_file_encodings() {
    globalpython3 ~/workspace/research/try_file_encodings.py $1
}

function _ghbase() {
    rm -Rf $HOME/workspace/github/_newrepos > /dev/null;
    mkdir $HOME/workspace/github/_newrepos > /dev/null;
    cd $HOME/workspace/github-stars-syncer
}

function _ghend() {
    cd $HOME/workspace/github;
    _make_project_links;
    newrepos=$HOME/workspace/github/_newrepos
    if [ ! -d "$newrepos" ]; then
        rm -Rf $newrepos
        mkdir $newrepos
    fi
    cd $HOME/workspace/github/_newrepos;
    _make_project_links;
}

function _ghstar() {
    _ghbase
    globalpython3 update_stars_github.py all;
    _ghend
}

function _ghstarnew() {
    _ghbase
    globalpython3 update_stars_github.py new;
    _ghend
}

function _newrepos() {
    newreposfolder=$HOME/Desktop/newrepos
    if [ ! -d "$newreposfolder" ]; then
        # Control will enter here if $DIRECTORY doesnt exist.
        mkdir -p "$newreposfolder"
    fi
    cd $newreposfolder
    gcp -vLnr $HOME/workspace/github/_newrepos/_projects/* .;
    rm -f ._existingrepos_done
    cd $newreposfolder
    _allrstf
}

function _existingrepos_begin() {
    newreposfolder=$HOME/Desktop/newrepos
    if [ ! -d "$newreposfolder" ]; then
        # Control will enter here if $DIRECTORY doesnt exist.
        echo "no newrepos folder found on desktop"
        return
    fi
    cd $newreposfolder
    if [ -f "._existingrepos_done" ]; then
        echo "This folder is alread done"
        return
    fi

    #_make_project_links;
#    mkdir -p projects;
#    gcp -vLnr _projects/* projects/;
#    rm -Rf _projects;
#    mv projects ..;
#    rm -Rf *;
#    mv ../projects .;
#    mv ./projects/* .;
#    rmdir projects;

}

function _newrepos_end() {
    _allmd2htmlnoconfirm
}

function _newrepos_book() {
    _newrepos
    _newrepos_end
}

function _newrepos_readmes_book() {
    _newrepos
    globalpython3 $HOME/workspace/ghresearch/get_readmes.py;
    _newrepos_end
}

function _existingrepos_book() {
    _existingrepos_begin
    globalpython3 $HOME/workspace/ghresearch/genindex.py .
    globalpython3 $HOME/workspace/ghresearch/get_readmes.py .

    cd githubreadme;
    globalpython3 $HOME/workspace/ghresearch/genindex.py .
    cd ..
   _newrepos_end
   date > ._existingrepos_done
}

function _filemimetype() {
    file --mime-type $1 | puf "[x.split(':')[1].strip() for x in lines if ':' in x]"
}

function _filemimeencoding() {
    file --mime-encoding $1 | puf "[x.split(':')[1].strip() for x in lines if ':' in x]"
}

function ghstardesktop() {
_ghstar
_newrepos
}

function _to_utf8() {
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    _filemimeencoding $1 > fileencoding.txt
    globalpython3 ~/workspace/devenv/code/make_utf8.py $1
    rm -f fileencoding.txt
    IFS=$SAVEIFS
}

function _man() {
    echo -e "\033[94mbro\033[0m"
    bro $1
    echo -e "\033[94meg\033[0m"
    eg --color $1
}

function _renameallextexp() {
    echo -e "\033[91m""Recursively renames all files with ext1 to ext2""\033[0m"
    echo
    echo "$ renameallext txt rst"
    echo
}

function _renameallext() {
    if [ ! $1 ]; then
        _renameallextexp
        echo -e "\033[31m""ext1 and ext2 not given""\033[0m"
        echo
        return 1
    fi
    if [ ! $2 ]; then
        _renameallextexp
        echo -e "\033[31m""ext2 not given""\033[0m"
        echo
        return 1
    fi

    for targetfile in $(find . -type f -name "*$1")
        do
            echo -e "\033[94m"$targetfile"\033[0m"
            if [ -f $targetfile ]; then

                echo -e "\033[94m"$targetfile"\033[96m    ->    ""$(dirname $targetfile)"/"$(basename $targetfile ".$1").$2\033[0m"
                mv $targetfile "$(dirname $targetfile)"/"$(basename $targetfile ".$1").$2"
            fi
        done
}

function _renameall() {
    if [ ! $1 ]; then
        _renameallextexp
        echo -e "\033[31m""ext1 and ext2 not given""\033[0m"
        echo
        return 1
    fi
    if [ ! $2 ]; then
        _renameallextexp
        echo -e "\033[31m""ext2 not given""\033[0m"
        echo

        #return 1
    fi
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    for targetfile in $(find . -type f -name "*$1*")
        do
            if [ $targetfile ]; then
                newname=`echo -e $targetfile | tr -d "'" | tr -d "\n" | sed -e "s/$1/$2/g" -e "s/ /_/g" -e "s/[(]/_/g" -e "s/[&,\'!%]/_/g"`

                echo -e "\033[94m"$targetfile"\033[96m    ->    $newname"
                mv $targetfile $newname
            fi
        done
    IFS=$SAVEIFS
}

function _tryrenameall() {
    if [ ! $1 ]; then
        _renameallextexp
        echo -e "\033[31m""ext1 and ext2 not given""\033[0m"
        echo
        return 1
    fi
    if [ ! $2 ]; then
        _renameallextexp
        echo -e "\033[31m""ext2 not given""\033[0m"
        echo

        #return 1
    fi
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    for targetfile in $(find . -type f -name "*$1*")
        do
            if [ $targetfile ]; then
                newname=`echo -e $targetfile | tr -d "'" | tr -d "\n" | sed -e "s/$1/$2/g" -e "s/ /_/g" -e "s/[(]/_/g" -e "s/[&,\'!%]/_/g"`

                echo -e "\033[94m"$targetfile"\033[96m    ->    $newname"
                mv $targetfile $newname
            fi
        done
    IFS=$SAVEIFS
}

function _pull(){
    globalpython3 $HOME/workspace/git_utils/pull_all_git_folders.py -i -f -$1
}

function _stopvms() {
    echo -e "\033[31mstopping vms\033[96m:"

    #vmrun stop ~/vms/fedora_64_ipsilon.vmwarevm/fedora_64_ipsilon.vmx nogui
    #vmrun stop ~/vms/fedora_64.vmwarevm/fedora_64.vmx nogui

    echo -e "\033[94mdone\033[0m"
}

function _startvms() {

    #vmrun start ~/vms/fedora_64_ipsilon.vmwarevm/fedora_64_ipsilon.vmx nogui
    vmrun start ~/vms/fedora_64.vmwarevm/fedora_64.vmx nogui
}

function _renamesafe() {
    if [ "" == "$@" ]; then
        echo -e "\033[31mno file given\033[0m"
        return 1
    fi
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    newname=`echo -e $@ | tr -d "'" | tr -d "\n"| tr -d "-" | sed -e "s/ /_/g" -e "s/[(]/_/g" -e "s/[&,\'!%]/_/g" -e "s/__/_/g" | lwr`

    echo -e "\033[94m"$@"\033[96m -> "$newname
    mv "$@" "$newname"
    IFS=$SAVEIFS
}

function generatels() {
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    for targetfile in $(find . -type f -name "*$1*")
        do
            if [ $targetfile ]; then
                echo -e $2$targetfile$3$targetfile$4
            fi
        done
    IFS=$SAVEIFS
}

function _aopen() {
    globalpython3 /Users/rabshakeh/workspace/pip/openmacapp/openmacapp/__init__.py $@
}

function _tinyurl() {
    if [ -n "$1" ]; then
        url="$1"
        turl=`curl -s http://tinyurl.com/create.php?url=${url} | sed -n 's/.*\(http:\/\/tinyurl.com\/[a-z0-9][a-z0-9]*\).*/\1/p' | uniq`
        echo -e "\033[93mTinyurl created:\033[0m"
        echo -e "\033[37m$url\033[0m"
        echo -e "\033[32m`echo "$turl"`\033[0m"

        echo "$turl" | tr -d "\n"  | pbcopy
    else
        echo "Error: You must pass a URL"
    fi
}

function _eve_upgrade() {
    echo "1" > ~/.upgradingeve
    rm "~/.upgradingeve"
}

function _locate() {
    loc $@
}

function nocolor() {
    puf "''.join([str(x) for x in [str(consoleprinter.remove_color(y))+'\n' for y in lines]]).strip()"
}

function saniless() {
    puf "' '.join([str(x) for x in [str(consoleprinter.colorize_for_print(y))+'\n' for y in lines]]).strip()" > $HOME/.sl
    less -r -f $HOME/.sl
    rm $HOME/.sl

    echo -e "\033[98m\033[0m"
}

function _restartvmnet() {
    echo 'restart vmware network'
    if [ "$(uname)" == "Darwin" ]; then
        sudo vmnet-cli --stop
        sleep 1
        sudo vmnet-cli --start
        sleep 2
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        sudo /usr/bin/vmware-networks --stop
        sleep 1
        sudo /usr/bin/vmware-networks --start
        sleep 2
    fi
}

function _evemachinecreate() {
    rm $HOME/.docker/env
    _restartvmnet
    docker-machine -D create --driver "vmwarefusion" --vmwarefusion-cpu-count "2" --vmwarefusion-disk-size "40000" --vmwarefusion-memory-size "512" eve
}

function nospaces() {
    puf '[" ".join([z for z in y.split()]).replace("--", "    --") for y in [x for x in lines]]'
}

function _spaste() {
    pbpaste | tr -d "\n" | sed -e "s/\// /g" -e "s/\r\n/-/g" -e "s/    / /g" -e "s/^[ \t]*//;s/[ \t]*$//"
}

function safe() {
    read var
    safevar=`echo -e $var | puf '[consoleprinter.slugify(x) for x in lines]'`
    echo ${safevar%_}
}

function _screensaver()  {
    /System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine
}

function _locgrep() {
    $HOME/workspace/devenv/code/locate.py $1 | grep $2
    echo $1
    echo $2
    echo $3
}

function _unicode_line_nr() {
    globalpython3 $HOME/workspace/research/unicode_line_number.py $@
}

function _mu() {
    printf '\033[?7l'
    ps wwaxm -o pid,stat,vsize,rss,time,command | head -10 | pygmentize -g
    printf '\033[?7h'
}

function _py2() {

    echo "`date +%s`: `pwd` -> $@" >> ~/pycmdpaths.txt
    globalpython3 $@
}

function _py3() {

    echo "`date +%s`: `pwd` -> $@" >> ~/pycmdpaths.txt
    globalpython3 $@
}

function _configs() {

 ls -las ~/ | puf "[x.split('->')[1].strip() for x in lines if '->' in x and 'Mackup' in x]"| puf "['cp '+x.replace(' ', '\ ').replace('(', '\(').replace(')', '\)')+' ~/workspace/devenv'for x in lines if x and os.path.isfile(x)]" > ~/.configs.sh
 /bin/cat ~/.configs.sh | sh
 _c/bin/cat ~/.configs.sh

 rm  ~/.configs.sh
}

function _xtar() {
    tar -xf $1;
}

function _araxis() {
    /Applications/Araxis\ Merge.app/Contents/Utilities/compare $1 $2
}

function _whichrealpath() {
    echo -e "\033[34m"`which "$1"`"\033[0m"
    which "$1" | grep -v iased > .command.txt

    puf " '\033[92m'+'\n'.join([str(x)+'\033[93m -> \033[94m'+os.path.realpath(x.split(' ')[-1]) for x in open('.command.txt').read().split('\n') if x])+'\033[0m'"
    puf "'\033[91m'+os.path.realpath(open('.command.txt').read().split('\n')[0].split(' ')[-1])+'\033[0m'"

    rm -f .command.txt
}

function _github_readmes() {
    cd ~/Desktop
    newreposfolder=$HOME/Desktop/newrepos
    if [ ! -d "$newreposfolder" ]; then
        mkdir $newreposfolder
    fi
    cd /Users/rabshakeh/workspace/github/
    rm -Rf _projects
    _make_project_links
    _renameallext markdown md
    _renameallext txt md

    cd $newreposfolder
    globalpython3 $HOME/workspace/ghresearch/get_readmes.py /Users/rabshakeh/workspace/github/_projects /Users/rabshakeh/Desktop/newrepos
    cd githubreadme;
    globalpython3 $HOME/workspace/ghresearch/genindex.py .
    _newrepos_end
    globalpython3 /Users/rabshakeh/workspace/git_utils/listdirgit.py gitreset ~/workspace/github -f
}

function _realpath() {
    cd `dirname $1`
    echo `pwd`/`basename $1` > .command.txt
    echo -e "\033[34m`/bin/cat .command.txt`/$1\033[0m"

    puf "'\033[92m'+'\n'.join([str(x)+'\033[93m -> \033[94m'+os.path.realpath(x.split(' ')[-1]) for x in open('.command.txt').read().split('\n') if x])+'\033[0m'"
    puf "'\033[91m'+os.path.realpath(open('.command.txt').read().split('\n')[0].split(' ')[-1])+'\033[0m'"

    #rm -f .command.txt
}

function _eoffunctio() {
    echo "last function"
}

function _ls() {
    if [ "$1" == "" ]; then
        gls -Glkh --group-directories-first --color=auto  $2
    elif [ "$1" == "-s" ]; then
        gls -GlSskhr --group-directories-first --color=auto  $2
    elif [ "$1" == "-las" ] || [ "$1" == "-sla" ] || [ "$1" == "-als" ]; then
        gls -lash --group-directories-first --color=auto $2
    else
        ls -las | grep $1
    fi
}

function _pull_all() {
    globalpython3 $HOME/workspace/git_utils/pull_all_git_folders.py $1 $2
}

function _reboot() {
    read -p "Are you sure (y|Y)? " yn
    case $yn in
        [Yy]* ) ;;
        * ) echo "Cancelled";
            exit;
            ;;
    esac
    echo sudo reboot
}
export PATH=$PATH:/usr/local/opt/go/libexec/bin
export ANDROID_HOME=/usr/local/opt/android-sdk

# Setting PATH for Python 3.5
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.5/bin:${PATH}"
export PATH

# Setting PATH for Python 3.5
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.5/bin:${PATH}"
export PATH

function _runserver() {
    ret=`globalpython3 -c 'import sys; print("%i" % (sys.hexversion<0x03000000))'`

    if [ $ret -eq 0 ]; then
        echo "we require globalpython3 version <3"
    else
        echo "globalpython3 version is <3"
    fi
    globalpython3 ~/workspace/research/www/wwwserver.py
}

function _gofocus() {
    vpwd=`pwd`
    cd ~/workspace/research/focusatwill
    sublime music.sh
    read -p "press enter"
    globalpython3 music.py
    cd `echo $scwd`
}

function _wwwserver() {
    ret=`python -c 'import sys; print("%i" % (sys.hexversion<0x03000000))'`

    if [ $? -eq 0 ]; then
        python3 -m http.server 8080
    else
        globalpython3 -m SimpleHTTPServer 8080
    fi
    open http://0.0.0.0:8080;
}

function _gitclean() {
    git repack -a -d --depth=100 --window=100
    git gc --aggressive --prune
}
alias a='_aopen'
alias abi='ssh rabshakeh@abi.active8.nl'
alias abigail='ssh -v rabshakeh@abigail.a8.nl'
alias abigail_logs='_abigail_logs'
alias abigailsp_logs='_abigail_sp_logs'
alias acat='/bin/cat'
alias acommpush='globalpython3 $HOME/workspace/git_utils/make_exclude_dirs.py; $HOME/workspace/git_utils/commitfast.sh; $HOME/workspace/git_utils/apush.sh; wait'
alias acompush='cd ~/workspace/documentation; git pull;$HOME/workspace/git_utils/commitfast.sh; $HOME/workspace/git_utils/apush.sh; wait'
alias act='open /Applications/Utilities/Activity\ Monitor.app'
alias adad='ssh rabshakeh@adad.active8.nl'
alias add='_add'
alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport'
alias all2mp3='_all2mp3'
alias allhtml2md='_allhtml2md'
alias allhtml2pdf='_allhtml2pdf'
alias alljpg2png='echo "for i in *.jpg ; do echo \$i&&convert \"\$i\" \"${i%.*}.png\" ; done"|sh'
alias allmd2epub='_allmd2epub'
alias allmd2html='_allmd2html'
alias allmd2md='_allmd2md'
alias allmd2pdf='_allmd2pdf'
alias allmdcheck='_allmdcheck'
alias allmdcheckforce='_allmdcheckforce'
alias allmp4ipad='_allmp4ipad'
alias allpng2jpg='echo "for i in *.png ; do echo \$i&&convert \"\$i\" \"${i%.*}.jpg\" ; done"|sh'
alias allreposbook='cd $HOME/workspace/markdown-to-ebook/bookcvwait; gcp -vLnr $HOME/workspace/github/_projects/* .; cd ..'
alias allrst='_allrst'
alias allrstcf='_makedocs'
alias allrstf='_allrstfq'
alias allsafe='_allsafe'
alias allsafefiles='_allsafefiles'
alias amzi='ssh rabshakeh@amzi.active8.nl'
alias androidemu='"/Applications/Android Studio.app/sdk/tools/emulator" -avd android -netspeed full -netdelay none'
alias ao='_aopen'
alias aopen='_aopen'
alias app='cd $HOME/workspace/cryptobox/cryptobox_app/source/commands/'
alias applycover='_apply_coverjp'
alias araxis='_araxis'
alias ascripts='open /Users/rabshakeh/Library/Services'
alias audiobitpool='defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40'
alias backups='ssh rabshakeh@backups.active8.nl'
alias balder='ssh rabshakeh@balder.active8.nl'
alias bbrew='_brew'
alias bcat='/bin/cat'
alias beta='ssh rabshakeh@beta.active8.nl'
alias bp='bpython'
alias brewown='sudo chown -R rabshakeh /usr/local'
alias brf='_brf'
alias brokk='ssh rabshakeh@brokk.active8.nl'
alias bru='_bru'
alias c='_c'
alias ca='cd $HOME/workspace/cryptobox/crypto_data/'
alias caff='echo '\''running: caffeinate -dimsu'\''; caffeinate -dimsu'
alias capitalize_files='globalpython3 ~/workspace/devenv/var/capitalize_all_files.py'
alias cb='cd $HOME/workspace/cryptobox'
alias cbbuildfrontend='$HOME/workspace/cryptobox/www_cryptobox_nl/scripts/build/build_frontend.sh'
alias cbcli='cd $HOME/workspace/cryptobox/cryptoboxcli;'
alias cbd='cd $HOME/workspace/cryptobox/cryptobox_design'
alias cbp='cd $HOME/workspace/cryptobox/cryptobox_provisioning/kubecoreos'
alias cbt='cd $HOME/workspace/cryptobox/cryptobox_test'
alias cbx='globalpython3 /Users/rabshakeh/workspace/cryptobox/cryptoboxcli/cryptoboxcli/__init__.py'
alias ccat='_ccat'
alias ccurl='_ccurl'
alias cd..='cd ../'
alias cdflex='cd /Users/rabshakeh/workspace/governet_rabo_modules_v2/flexpaper/static/flexpaper'
alias cdl='_cdlastpath'
alias cfi='_cfi'
alias checkpip='cat $HOME/workspace/pip/mods/* > /dev/null'
alias chrome='_chrome'
alias chromeclose='osascript -e "tell application "Google Chrome" to close every window"'
alias cic='ssh 192.168.0.7'
alias ciphers='_ciphers'
alias cl='$HOME/workspace/cryptobox/cryptobox_provisioning/clustercli/cluster.py'
alias cleangit='_gitclean'
alias cleansearch='globalpython3 ~/workspace/devenv/code/searchfiles.py -c'
alias cleanup='find . -type f -name "*.iml" -ls -delete; find . -type f -name "*.DS_Store" -ls -delete'
alias cleanup_ds='find . -type f -name "*.DS_Store" -ls -delete'
alias cleanuphg='find . -type d -name ".hg" -print -exec rm -rf {} \;'
alias cleanupsvn='find . -type d -name ".svn" -print -exec rm -rf {} \;'
alias clipcopy='pbcopy'
alias clock='_clock'
alias close='_button '\''close'\''  '
alias close_app='_close_app'
alias closeterms='_close_terms'
alias cls='printf "\033c"'
alias cman='_man'
alias co2='globalpython3 ~/workspace/research/netatmo/parse_netatmo.py CO2'
alias cockpitjophiel='open https://188.166.52.154:9090/'
alias cockpituriel='open https://188.166.41.246:9090/'
alias cockpituzziel='open https://188.166.115.155:9090/'
alias colors='globalpython3 $HOME/workspace/research/printcolors.py'
alias com='_com'
alias comm='globalpython3 $HOME/workspace/git_utils/make_exclude_dirs.py&&$HOME/workspace/git_utils/commit.sh&&$HOME/workspace/git_utils/push.sh'
alias commit='git commit -am "-"'
alias comoud='$HOME/workspace/git_utils/commitfast.sh;'
alias compush='$HOME/workspace/git_utils/commitpush.sh'
alias concatmp3='_concatmp3'
alias configs='_configs'
alias coolname='globalpython3 $HOME/workspace/research/coolname.py'
alias copr='/Users/rabshakeh/workspace/devenv_private/commander_one_pro.sh'
alias cp='cp -iv'
alias cp8='globalpython3 $HOME/workspace/cp-pep8/cp.py -f '
alias cpa='$HOME/workspace/cryptobox/www_cryptobox_nl/scripts/run_cp_all.sh;'
alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'
alias cr='cd $HOME/workspace/cryptobox/crypto_api'
alias createcb='cd $HOME/workspace/cryptobox/www_cryptobox_nl;$HOME/workspace/cryptobox/www_cryptobox_nl/scripts/create/create_cryptobox.sh'
alias cryptobox='cbx'
alias csearch='_csearch'
alias ct='_cterm'
alias cterm='_cterm'
alias cto='_cto'
alias ctr='cd $HOME/workspace/cryptobox/crypto_tree'
alias cwd='cd `cat ~/.cwds`'
alias cwd1='cd `cat ~/.cwds1`'
alias cwd2='cd `cat ~/.cwds2`'
alias cwd3='cd `cat ~/.cwds3`'
alias cwd4='cd `cat ~/.cwds4`'
alias cwd5='cd `cat ~/.cwds5`'
alias cwds='_cwds'
alias cwv='printf "\033c"; $HOME/workspace/cryptobox/crypto_taskworker/starter.py -v -w 1'
alias dash='_dash'
alias dashboard='ssh dashboard@dashboard.customerheartbeat.nl'
alias dashboard_disable='defaults write com.apple.dashboard mcx-disabled -boolean YES; killall Dock'
alias dashboard_enable='defaults write com.apple.dashboard mcx-disabled -boolean NO; killall Dock'
alias decfile='_decfile'
alias defaultjavapycharm='rm ~/Library/Preferences/PyCharm2016.1/pycharm.jdk'
alias deletecb='cd $HOME/workspace/cryptobox/www_cryptobox_nl;$HOME/workspace/cryptobox/www_cryptobox_nl/scripts/create/delete_cryptobox.sh;'
alias delstore='sudo find / -name .DS_Store -depth -exec rm {} \;'
alias desk='cd $HOME/Desktop'
alias diff='colordiff'
alias disableardsystemkeys='defaults write com.apple.RemoteDesktop DoNotSendSystemKeys -bool YES; defaults write com.apple.ScreenSharing DoNotSendSystemKeys -bool YES'
alias disablebounce='defaults write com.apple.dock no-bouncing -bool TRUE; /usr/bin/killall Finder;'
alias disabledesktop='hidedeskicons'
alias disableicons='hidedeskicons'
alias disablenotications='sudo launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.agent; sudo killall -v NotificationCenter.app'
alias diskuse='_diskuse'
alias doc='cd ~/workspace/documentation'
alias dockerfedora='docker run -it --rm fedora-docker-base-24-1.2.x86_64 bash'
alias docs='cd ~/workspace/documentation'
alias docx2md='_docx2md'
alias done='_done'
alias down='cd; cd Downloads'
alias dps='_dps'
alias drrm='docker rm `docker ps -aq --no-trunc --filter "status=exited"` 2> /dev/null'
alias dt='tee $HOME/Desktop/terminalOut.txt'
alias dump='$HOME/workspace/cryptobox/www_cryptobox_nl/scripts/create/make_local_copy_databases.sh'
alias dupi='ssh rabshakeh@dupi.active8.nl'
alias dusort='du -hs * | gsort -hr'
alias edit='subl'
alias enable_eve='_enable_eve'
alias enablebounce='defaults write com.apple.dock no-bouncing -bool FALSE; /usr/bin/killall Finder;'
alias enabledesktop='showdeskicons'
alias enableicons='showdeskicons'
alias enablenotications='sudo launchctl load -w /System/Library/LaunchAgents/com.apple.notificationcenterui.agent; open "/System/Library/CoreServices/NotificationCenter.app"'
alias encfile='_encfile'
alias encoding='_filemimeencoding'
alias epub2pdf='_epub2pdf'
alias esf='subl $HOME/workspace/sort_photo/sort_photos.py'
alias esther='ssh rabshakeh@esther.active8.nl'
alias eve='enable_eve'
alias evemachinecreatevmware='_evemachinecreate'
alias existingrepos_book='_existingrepos_book'
alias faith='ssh rabshakeh@faith.active8.nl'
alias fan='sudo /Users/rabshakeh/.pyenv/versions/3.5.2/bin/python $HOME/workspace/pip/openmacapp/openmacapp/__init__.py smc'
alias fbq='globalpython3 $HOME/workspace/brainyquote/printbrainyquote.py -r -d $HOME/workspace/brainyquote/quotes;'
alias filetool='globalpython3 ~/workspace/filetool/filetool.py'
alias finder='ofi'
alias finder_hide_hidden=' defaults write com.apple.finder AppleShowAllFiles -boolean false; sudo killall Finder'
alias finder_show_hidden=' defaults write com.apple.finder AppleShowAllFiles -boolean true; sudo killall Finder'
alias firewalloff='_firewalloff'
alias firewallon='_firewallon'
alias fiveterms='_five_terms'
alias fix_stty='stty sane'
alias fixwrappedmd='_fixwrappedmd'
alias flac2mp3='_flac2mp3'
alias flush='redis-cli flushall; celery purge -f'
alias flush_dns='dscacheutil -flushcache'
alias folders='find . -type ds -depth 1  | puf "['\''\033[34m'\''+x.replace('\''./'\'', '\'''\'')+'\''\033[0m'\'' for x in lines]"'
alias forcequitall='kill $(osascript -e '\''tell app "System Events" to unix id of processes where background only is false'\''|tr -d ,)'
alias fortune='globalpython3 $HOME/workspace/brainyquote/printbrainyquote.py -l 120 -r -d $HOME/workspace/brainyquote/quotes;'
alias fortuneclean='globalpython3 $HOME/workspace/brainyquote/printbrainyquote.py -c -l 30 -r -d $HOME/workspace/brainyquote/quotes;'
alias fpath='_fpath'
alias fpaths='_fpaths'
alias ft='fiveterms'
alias fwdr='cd ~/dropboxpers/2016_focus/uptempo'
alias fww='cd ~/workspace/research/focusatwill'
alias g='_google'
alias gcom='_gcom'
alias gcompush='_gcompush'
alias gconf='_ccat .git/config'
alias gdash='_gdash'
alias genindex='_genindex'
alias genpassword='globalpython3 /Users/rabshakeh/workspace/devenv/genpassword.py 3 5'
alias gestsubs='(getsubsnl &)&&getsubsen'
alias get_font_smoothing='_get_font_smoothing'
alias getsubs='_getallsubs'
alias getsubsen='subliminal download -l en *'
alias getsubsnl='subliminal download -l nl *'
alias gg='_gopen'
alias ggc='$HOME/workspace/git_utils/gc.sh'
alias gh='open "https://github.com/settings/repositories"'
alias ghb='cd $HOME/workspace/github'
alias ghsearch='_ghsearch'
alias ghstar='_ghstar'
alias ghstarnew='_ghstarnew'
alias gicd='globalpython3 $HOME/workspace/ghresearch/genindex.py .'
alias gitclean='_gitclean'
alias github_readmes='_github_readmes'
alias gitreset='_gitreset'
alias gofocus='_gofocus'
alias google='_google'
alias gopen='_gopen'
alias governet_download_all='_governet_download_all'
alias gpaste='google "`pbpaste`"'
alias gpull='git pull'
alias gpush='git push'
alias grepsearch='_grepsearch'
alias grepsearchpy='_grepsearchpy'
alias gstats='git status'
alias hannah='ssh rabshakeh@hannah.active8.nl'
alias hide='_hide'
alias hide_file='_hide_file'
alias hidedeskicons='defaults write com.apple.finder CreateDesktop false; /usr/bin/killall Finder;'
alias hidefile='_hide_file'
alias hidemenubar='sudo defaults write "Apple Global Domain" "_HIHideMenuBar" 1; /usr/bin/killall Finder; '
alias highcpu='globalpython3 /Users/rabshakeh/workspace/research/highcpu.py'
alias hist='_hist'
alias hpaste='pbpaste && echo'
alias html2docx='_html2docx'
alias html2md='_html2md'
alias html2mdmammoth='_html2mdmammoth'
alias html2pdf='_html2pdf'
alias htt='_httpheaders'
alias httpie='_httpheaders'
alias idle='idle3'
alias iliad='ssh rabshakeh@iliad.active8.nl'
alias ip='echo "pub: "`curl -s ip.appspot.com`; ifconfig | grep 192.168.0 |  puf "\"loc: \"+str(cols[1][0])"'
alias ip_info0='ipconfig getpacket en0'
alias ip_info1='ipconfig getpacket en1'
alias ipsilon_dl='_ipsilon_dl'
alias isr='_isrunning'
alias isrunning='_isrunning'
alias j2c='js2coffee -X -i4 test.js > test.coffee'
alias java92pycharm='echo "/Library/Java/JavaVirtualMachines/jdk1.8.0_91.jdk" > ~/Library/Preferences/PyCharm2016.1/pycharm.jdk'
alias javan='ssh rabshakeh@javan.active8.nl'
alias jc='_jc'
alias jophiel='ssh -v jophiel.a8.nl'
alias jophiel_idp='_jophiel_download idp /var/lib/ipsilon/idp; mv ~/Desktop/idp ~/Desktop/ipsilon_idp'
alias jophiel_ipsilon='_ipsilon_dl'
alias jophiel_logs='_jophiel_logs'
alias jophiel_usr_lib_python7_site_packages='_jophiel_download ipsilon /usr/lib/python/site-packages/ipsilon; mv ~/Desktop/ipsilon ~/Desktop/ipsilon_usr_lib_python7_site_packages'
alias jophiel_usr_share_ipsilon='_jophiel_download ipsilon /usr/share/ipsilon; mv ~/Desktop/ipsilon ~/Desktop/ipsilon_usr_share'
alias jophiel_var_lib_ipsilon='_jophiel_download ipsilon /var/lib/ipsilon; mv ~/Desktop/ipsilon ~/Desktop/ipsilon_var_lib'
alias joy='ssh rabshakeh@joy.active8.nl'
alias jsjpicks='_jsjpicks'
alias json2md='_json2md'
alias judah='ssh rabshakeh@judah.active8.nl'
alias judas='ssh rabshakeh@judas.active8.nl'
alias kain='ssh rabshakeh@kain.active8.nl'
alias keepfaith='ssh rabshakeh@keepfaith.active8.nl'
alias killallfinder='restartfinder'
alias killfinder='killall Finder'
alias kindleclean='cd "/Users/rabshakeh/Library/Containers/com.amazon.Kindle/Data/Library/Application Support/Kindle/My Kindle Content"; mv * $HOME/Desktop;'
alias kkillall='_killall'
alias koa='ssh rabshakeh@koa.active8.nl'
alias kohath='ssh -v rabshakeh@kohath.a8.nl'
alias kohathcouch='ssh -L5984:127.0.0.1:5984 rabshakeh@kohath.a8.nl'
alias kp='_kp'
alias kube_version_change='_kube_version_change'
alias kvc='_kube_version_change'
alias latestpy2='pyenv install --list | grep -v-| grep -v 3. | tail -1'
alias latestpy3='pyenv install --list | grep -v-| grep -v b | grep -v a | tail -1'
alias latestpypy='pyenv install --list | grep pypy | grep -v a | grep -v src | grep -v dev'
alias ld='ls'
alias leah='ssh rabshakeh@leah.active8.nl'
alias less='less -FSRXc'
alias linkmergesh='rm merge.sh; ln -s ~/workspace/git_utils/merge.sh .'
alias lintpy='_lintpy'
alias listusb='system_profiler SPUSBDataType'
alias lnd='ssh 192.168.0.3'
alias loadnginx='launchctl load ~/Library/LaunchAgents/homebrew.mxcl.nginx-full.plist;'
alias locate='globalpython3 ~/workspace/pip/locatebash/locatebash/__init__.py'
alias locgrep='_locgrep'
alias lock='globalpython3 /Users/rabshakeh/workspace/research/swapbaseloginimg.py; /System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
alias logout='globalpython3 $HOME/workspace/research/swapbaseloginimg.py; osascript -e '\''tell application "loginwindow" to «event aevtrlgo»'\'''
alias logoutnow='_logout'
alias lower='lwr'
alias lr='ls -R | grep ":$" | sed -e "s/:$//" -e "s/[^-][^\/]*\//--/g" -e "s/^/     /" -e "s/-/|/" | less'
alias ls2='ls -lrth'
alias lsock='sudo /usr/sbin/lsof -i -P'
alias lsock_t='sudo /usr/sbin/lsof -nP | grep TCP'
alias lsock_u='sudo /usr/sbin/lsof -nP | grep UDP'
alias lss='_ls'
alias lyb2d='$(machine env lydo)'
alias lyc='ssh 192.168.0.50'
alias lycia='ssh -v 192.168.0.50'
alias lydoc='ssh lydoc.a8.nl'
alias m4a2mp3='_m4a2mp3'
alias m4b2mp3='_m4b2mp3'
alias macprocss='subl ~/Library/Application\ Support/MacDown/Styles/pro.css; cp ~/Library/Application\ Support/MacDown/Styles/pro.css ~/workspace/macdown/MacDown/Resources/Styles/'
alias madai='ssh rabshakeh@madai.active8.nl'
alias make10mb='mkfile 10m ./10MB.dat'
alias make1mb='mkfile 1m ./1MB.dat'
alias make5mb='mkfile 5m ./5MB.dat'
alias make_github_book='_allrst; _allmdcheckforce;'
alias make_project_links='_make_project_links;'
alias makeallfiles='_makeallfiles'
alias makedocs='_makedocs'
alias mammothdocx2md='_mamdocx2md'
alias man='_mandash'
alias man2='_man2'
alias man2md='_man2md'
alias manage='ssh rabshakeh@manage.active8.nl'
alias md2docx='_md2docx'
alias md2epub='_md2epub'
alias md2html='_md2html'
alias md2man='_md2man'
alias md2md='_md2md'
alias md2mdmammoth='_md2mdmammoth'
alias md2pdf='_md2pdf'
alias mdbook='cd $HOME/workspace/markdown-to-ebook'
alias mdcat='_mdcat'
alias mdcheck='_mdcheck'
alias mdclean='_mdclean'
alias mem_hogs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'
alias mem_hogs_ps='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'
alias mem_hogs_top='/usr/bin/top -l 1 -o rsize | head -20'
alias mfind='mdfind -name "$@"'
alias mimetype='_filemimetype'
alias minimize='_button '\''minimize'\'' '
alias mkdir='mkdir -pv'
alias mkv2mp4='_mkv2mp4'
alias motd='subl ~/.motd'
alias mount_read_write='/sbin/mount -uw /'
alias mountnain='mkdir /Volumes/nain; sshfs -o IdentityFile=~/.ssh/id_rsa rabshakeh@nain.a8.nl:/home/rabshakeh /Volumes/nain'
alias mov='cd $HOME/Movies/youtube'
alias movconv='cd $HOME/Movies/youtube; globalpython3 youtubedownload/process_youtube.py'
alias move_in_folders='_move_in_folders'
alias mtar='_mtar'
alias mu='_mu'
alias mv='mv -iv'
alias myip='curl -s '\''https://api.ipify.org?format=json'\'' | puf '\''json.loads(lines[0]).get("ip", "-")'\''; ifconfig | grep 192.168.0 |  puf '\''str(cols[1][0])'\'''
alias mzip='_mzip'
alias n1='ssh node1-us.a8.nl'
alias n2='ssh node2-us.a8.nl'
alias nain='ssh nain.a8.nl'
alias naioth='ssh naioth.a8.nl'
alias nbook='_nbook'
alias net_cons='lsof -i'
alias netatmo='globalpython3 ~/workspace/research/netatmo/netatmo.py; globalpython3 ~/workspace/research/netatmo/parse_netatmo.py -c all'
alias new_python_file='_new_python_file'
alias newfolder='uniqfolder'
alias newmail='_newmail'
alias newquote='globalpython3 /Users/rabshakeh/workspace/brainyquote/printbrainyquote.py -r -d ~/quotes  > /Users/rabshakeh/quote.txt'
alias newrepos='_newrepos'
alias newrepos_book='_newrepos_book'
alias newrepos_end='_newrepos_end'
alias newrepos_readmes_book='_newrepos_readmes_book'
alias newsem='ssh rabshakeh@newsem.active8.nl'
alias nimrod='ssh nimrod.a8.nl'
alias nohuptempsens='_nohuptempsens'
alias noprompt='export PS1="$ "'
alias normalmode='sudo nvram boot-args="-v"'
alias notebook='jupyter notebook'
alias notebook3='jupyter notebook'
alias notebr='open http://127.0.0.1:8080'
alias nq='globalpython3 /Users/rabshakeh/workspace/brainyquote/printbrainyquote.py -r -d $HOME/workspace/brainyquote/quotes  > /Users/rabshakeh/quote.txt'
alias num_files='echo $(ls -1 | wc -l)'
alias numcpus='_numcpus'
alias nxrestart='nginx -s stop; nginx'
alias o2f='_ofi2'
alias ocp='/Users/rabshakeh/workspace/devenv_private/commander_one_pro.sh'
alias odin='ssh rabshakeh@odin.active8.nl'
alias ofi='_ofi'
alias ofi2='_ofi2'
alias ofit='osascript -e "tell application \"Finder\" to close every window">/dev/null&&open . >/dev/null&&osascript -e "tell application \"Finder\" to set the current view of the front Finder window to column view">/dev/null&&osascript -e "tell application \"Terminal\" to activate"'
alias only='_only'
alias open_ports='sudo lsof -i | grep LISTEN'
alias opendir='_opendir'
alias openf='_openf'
alias openmacapp='globalpython3 /Users/rabshakeh/workspace/pip/openmacapp/openmacapp/__init__.py'
alias opus2mp3='_opus2mp3'
alias overloadsite='_overloadsite'
alias p3='bpython'
alias path='echo -e ${PATH//:/\\n}'
alias pcqd='globalpython3 $HOME/workspace/pip/pycodequality/pycodequality/__init__.py'
alias pcwd='cat ~/.cwd'
alias pdf='ssh rabshakeh@pdf.active8.nl'
alias pdfservice='ssh rabshakeh@pdfservice.active8.nl'
alias pf='puf'
alias phau='ssh rabshakeh@phau.active8.nl'
alias pinga8='ping www.a8.nl'
alias pip2='pip2.7'
alias pipinstall='_pipinstall'
alias poweroff='echo "shutdown"&&_stopvms&&globalpython3 $HOME/workspace/research/swapbaseloginimg.py; osascript -e "tell app \"System Events\" to shut down"'
alias poweroffconfirmation='echo "shutdown"&&globalpython3 $HOME/workspace/research/swapbaseloginimg.py&&osascript -e "tell app "loginwindow" to «event aevtrsdn»"'
alias prettyjson='_prettyjson'
alias printonlytime='~/workspace/research/printonlytime.py'
alias prismcopy='rm /Applications/MacDown/MacDown.app/Contents/Resources/Prism/themes/prism-dark.css&&cp /Users/rabshakeh/workspace/devenv/code/macdown/Prism/themes/prism-dark.css /Applications/MacDown/MacDown.app/Contents/Resources/Prism/themes/prism-dark.css'
alias processhasfile='_processhasfile'
alias profile='_profile'
alias project='ssh rabshakeh@project.active8.nl'
alias pss='_pss'
alias pull='_pull'
alias pullall='_pull_all'
alias pullcompush='$HOME/workspace/git_utils/pull.sh; $HOME/workspace/git_utils/commitfast.sh; $HOME/workspace/git_utils/push.sh;'
alias push='$HOME/workspace/git_utils/push.sh;'
alias py='puf'
alias py2html='_py2html'
alias pygmentize='_ccat'
alias pyhist='globalpython3 ~/workspace/devenv/code/sortpyhist.py ~/pycmdpaths.txt '
alias pyin='globalpython3 setup.py install'
alias python='python'
alias pyun='pip3 uninstall openmacapp'
alias q='_gopen'
alias qfind='find . -name '
alias qfind1='cd ..&&pwd&&find . -name '
alias qfind2='cd ../..&&pwd&&find . -name '
alias qfinda='_qfinda'
alias qfindu='find $HOME -name '
alias qfindw='find $HOME/workspace -name '
alias quitall='_quitall'
alias rachel='ssh rabshakeh@rachel.active8.nl'
alias rahab='ssh rabshakeh@rahab.active8.nl'
alias ratecode='_ratecode'
alias realpath='_realpath'
alias reboot='restart'
alias rebootconfirmation='echo '\''rebooting'\''&&globalpython3 $HOME/workspace/research/swapbaseloginimg.py&&osascript -e '\''tell app "loginwindow" to «event aevtrrst»'\'''
alias recodemp3128='_recodemp3128'
alias recursiveallsafe='_recursive_allsafe'
alias refreshfinder='osascript $HOME/workspace/research/osresetfinder.applescript'
alias reloadnginx='launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.nginx-full.plist; launchctl load ~/Library/LaunchAgents/homebrew.mxcl.nginx-full.plist;'
alias remove_code='_remove_code'
alias renameall='_renameall'
alias renameallext='_renameallext'
alias renamesafe='_renamesafe'
alias repairext='sudo diskutil repairVolume tmnas; sudo diskutil repairVolume fastraid;'
alias report='ssh rabshakeh@report.active8.nl'
alias res='cd $HOME/workspace/research'
alias resbar='resetbartender'
alias reset='stty sane; clear; cd $HOME/workspace'
alias resetbartender='killall bartender; sleep 1; ao bartender;'
alias resetconsole='stty sane'
alias resetpyhist='rmpyhist'
alias resetworkspace='_resetworkspace'
alias restart='_restart'
alias restartaudio='sudo killall coreaudiod'
alias restartfinder='killall Finder;open /System/Library/CoreServices/Finder.app'
alias restartnow='rebootnow'
alias restartvmnet='_restartvmnet'
alias riphath='ssh -v riphath.a8.nl'
alias rmdstore='find . -name ".DS_Store" -depth -exec rm {} \;'
alias rmgitconfig='find . -type d -name .git -print -exec rm -rf {} \;'
alias rmpyc='find . -type f -name "*.pyc" -exec rm {} \;'
alias rmpyhist='rm ~/pycmdpaths.txt; touch ~/pycmdpaths.txt'
alias rmstalesymlinks='find -L . -name . -o -type d -prune -o -type l -exec rm {} +'
alias rmt='_rmt'
alias rmyoutag='globalpython3 ~/workspace/devenv/code/removeyoutubetag.py "`pwd`"'
alias rps='_running_procs'
alias rredis='launchctl unload $HOME/Library/LaunchAgents/homebrew.mxcl.redis.plist; launchctl load $HOME/Library/LaunchAgents/homebrew.mxcl.redis.plist'
alias rs2md='_rst2md'
alias rsb='resetbartender'
alias rsscurl='_rsscurl'
alias rst2md='_rst2md'
alias rstxt2docx='_rstxt2docx'
alias rsyncfolder='_rsyncfolder'
alias running_procs='_running_procs'
alias runserver='_runserver'
alias runserverip='globalpython3 ~/workspace/research/www/wwwserver.py 192.168.0.50'
alias rw='_resetworkspace'
alias s3='ssh rabshakeh@s3.active8.nl'
alias safari='_safari'
alias safariclose='osascript -e '\''tell application "Safari" to close every window'\'''
alias safemode='sudo nvram boot-args="-x -v"'
alias safename='_safename'
alias sali='_sal'
alias salias='_sal'
alias scr='cd $HOME/workspace/cryptobox/www_cryptobox_nl/scripts'
alias screensaver='_screensaver'
alias screensaverphotodelay='_screensaverphotodelay'
alias screensaverphotodelay15='_screensaverphotodelay 15'
alias screensharingon='_screensharingon'
alias scwd='pwd > ~/.cwds'
alias scwd1='pwd > ~/.cwds1'
alias scwd2='pwd > ~/.cwds2'
alias scwd3='pwd > ~/.cwds3'
alias scwd4='pwd > ~/.cwds4'
alias scwd5='pwd > ~/.cwds5'
alias search='_search'
alias searchcode='_searchcode'
alias searchquote='_searchquote'
alias servers='_print_servers'
alias set_font_smoothing='_set_font_smoothing'
alias setp3='unset PYTHONPATH;'
alias setpy2='_setpy2'
alias setpy3='_setpy3'
alias sf='_sf'
alias shortdate='date -r `date +%s` +"%y:%m:%d-%H:%M"'
alias show_blocked='sudo ipfw list'
alias show_options='shopt'
alias showdeskicons='defaults write com.apple.finder CreateDesktop true; /usr/bin/killall Finder;'
alias showmenubar='sudo defaults write "Apple Global Domain" "_HIHideMenuBar" 0; /usr/bin/killall Finder; '
alias sideterm='_two_terms'
alias siera='ssh rabshakeh@siera.active8.nl'
alias sites='find /etc/nginx/sites-available -type f -print0 | xargs -0 egrep '\''^(\s|\t)*server_name'\'' | puf "[x.split('\''server_name'\'')[1].replace('\'':'\'', '\'': '\'').replace('\''\t'\'', '\'''\'').strip('\'';'\'').strip()+'\'' -> '\''+x.split('\''server_name'\'')[0].replace('\'':'\'', '\'': '\'').replace('\''\t'\'', '\'''\'').strip() for x in lines]"'
alias skips='ssh rabshakeh@skips.active8.nl'
alias sopen='_aopen'
alias sortalias='/bin/cat $HOME/.bash_profile > $HOME/.bash_profile.backup; /bin/cat $HOME/.bash_profile | grep -v alias | grep -v '\''^$'\'' > $HOME/.bash_profile_without_alias; alias | grep -v '\''^$'\'' > $HOME/.bash_profile_only_alias; /bin/cat $HOME/.bash_profile_without_alias > $HOME/.bash_profile; echo -e '\''\n'\'' >>    $HOME/.bash_profile; /bin/cat $HOME/.bash_profile_only_alias >>    $HOME/.bash_profile; rm $HOME/.bash_profile_without_alias; rm $HOME/.bash_profile_only_alias; globalpython3 ~/workspace/cp-pep8/cp.py -f $HOME/workspace/devenv_private/bash_profile.sh; '
alias sorter='_sorter'
alias sortmpx='_sortmpx'
alias spaste='_spaste'
alias speedtest='speedtest --simple'
alias spip='_spip'
alias sqs='ssh rabshakeh@sqs.active8.nl'
alias ss='_screensaver'
alias sso_logs='_sso_logs'
alias st='cd $HOME/study'
alias startb='sudo ~/workspace/research/bridge.sh'
alias startdata='rm nohup.out; nohup $HOME/workspace/google/gcd-v1beta2-rev1-2.1.1/gcd.sh start $HOME/workspace/google/cryptobox2013/ &'
alias startnain='vmrun start ~/vms/nain/nain.vmx nogui'
alias startnaioth='vmrun start ~/vms/fedora_64_ipsilon.vmwarevm/fedora_64_ipsilon.vmx nogui'
alias startnimrod='vmrun start ~/vms/fedora_64.vmwarevm/fedora_64.vmx nogui'
alias startserverubuntu='vmrun start ~/vms/Ubuntu\ 64-bit\ Server\ 15.10.vmwarevm/Ubuntu\ 64-bit\ Server\ 15.10.vmx nogui'
alias startvms='_startvms'
alias stats='$HOME/workspace/git_utils/status.sh;'
alias stopb='sudo ~/workspace/research/bridge.sh stop'
alias stopnaioth='vmrun stop ~/vms/fedora_64_ipsilon.vmwarevm/fedora_64_ipsilon.vmx nogui'
alias stopnimrod='vmrun stop ~/vms/fedora_64.vmwarevm/fedora_64.vmx nogui'
alias strip_prefix_num='_strip_prefix_num'
alias subl='_subl'
alias superlocate='_superlocate'
alias support='ssh rabshakeh@support.active8.nl'
alias suriel='ssh suriel.a8.nl'
alias suriel_remote_desktop='/Users/rabshakeh/.active8/suriel_start_remote_desktop.sh'
alias survey='ssh rabshakeh@survey.customerheartbeat.com'
alias swaploginpic='globalpython3 /Users/rabshakeh/workspace/research/swapbaseloginimg.py'
alias sync2ssd='_synctossd'
alias syncfromssd='_syncfromssd'
alias synctossd='_synctossd'
alias tarsnap='_tarsnap'
alias temp='_temp'
alias tempsens='_tempsens'
alias test='cd $HOME/workspace/cryptobox/www_cryptobox_nl/scripts/test'
alias testecho='echo -e '
alias testsslserver='java -jar ~/workspace/research/TestSSLServer.jar'
alias tfe='_try_file_encodings'
alias throttlepid='_throttlepid'
alias timedelta='_timedelta'
alias tls='_tls'
alias to_utf8='_to_utf8'
alias toascii='_toascii'
alias todo='_todo'
alias todoh='_todohelp'
alias todohelp='_todohelp'
alias top2='/usr/bin/top -s 1 -stats pid,command,cpu,mem,time,state,uid,faults'
alias top_forever='/usr/bin/top -l 9999999 -s 10 -o cpu'
alias topy3='_topy3'
alias topy3all='futurize -w *.py; pasteurize -w *.py'
alias tosd='globalpython3 ~/workspace/research/youtubedownload/camelize_to_spaces.py ~/Movies/youtube/mp3  | sh'
alias tosdr='globalpython3 ~/workspace/research/youtubedownload/camelize_to_spaces.py ~/Movies/youtube/mp3 -r | sh'
alias touchall='find . -name "*.coffee" -exec touch {} \;&&find . -name "*.less" -exec touch {} \;'
alias tre='trash -l; trash -e'
alias trl='trash -l'
alias trm='_trm'
alias tryrenameall='_tryrenameall'
alias tt='twoterms'
alias ttop='/usr/bin/top'
alias tu='_tinyurl'
alias turbo='cat ~/.turbo'
alias turbo_off='sudo kextutil -v /Users/rabshakeh/workspace/research/tempsens/DisableTurboBoost.kext 2> foo.txt&&cat foo.txt| puf "[x for x in lines if '\''fail'\'' in x.lower()]"&&rm foo.txt'
alias turbo_on='sudo kextunload -v /Users/rabshakeh/workspace/research/tempsens/DisableTurboBoost.kext'
alias turbooff='turbo_off'
alias turboon='turbo_on'
alias twoterms='_two_terms'
alias txt2md='_txt2md'
alias tyaml='_tyml'
alias tyml='_tyml'
alias tyre='ssh rabshakeh@tyre.active8.nl'
alias unhide='_unhide'
alias unhide_file='_unhide_file'
alias unhidefile='_unhide_file'
alias unilnr='_unicode_line_nr'
alias uniqext='ls | puf "[ext for ext in set([x[x.rfind(\".\")+1:] for x in lines])]"'
alias uniqfolder='_uniqfolder'
alias unloadnginx='launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.nginx-full.plist; '
alias updatedblycia='export LC_ALL=C;sudo gupdatedb &;/usr/libexec/locate.updatedb &; wait'
alias updatedbcicilia='LC_ALL="C"&&sudo gupdatedb --localpaths="/Volumes/ssd/Users"'
alias upgrade='_upgrade'
alias upgradebrew='sudo date; brew update; brew cask update; brew upgrade --all; brew cleanup -s --force; sudo chown -R rabshakeh /usr/local/bin; cloud -q components update; brew doctor&&gem update bropages;'
alias upgradecal='cd ~/Desktop/installers; rm -f osx.dmg; wget http://code.calibre-ebook.com/dist/osx; mv osx osx.dmg; open osx.dmg; sleep 12; cd /Volumes/calibre*; rm -Rf /Applications/calibre.app; cp -r ./calibre.app /Applications; sleep 2; cd ~/Desktop/installers; diskutil eject /Volumes/calibre*; sleep 2; rm osx.dmg; cd; _killall Finder'
alias uriel='ssh -v rabshakeh@uriel.a8.nl'
alias uriel_ldifs='_uriel_ldifs'
alias utar='_utar'
alias uzziel='open https://uzziel.a8.nl'
alias uzzielssh='ssh uzziel.a8.nl'
alias vali='ssh rabshakeh@vali.active8.nl'
alias vckube='/Users/rabshakeh/workspace/pip/vckube/vckube/__init__.py'
alias verifydisk='diskutil verifyVolume /'
alias video='ssh rabshakeh@video.active8.nl'
alias webmail='ssh rabshakeh@webmail.active8.nl'
alias welcome='osascript -e "tell application \"Google Chrome\" to open location \"https://my.netatmo.com/app/camera\""&&osascript -e "tell application \"Google Chrome\" to activate"'
alias westbetuwe='ssh rabshakeh@westbetuwe.active8.nl'
alias wget='_wget'
alias whichrealpath='_whichrealpath'
alias writegb='time dd if=/dev/zero bs=1024k of=tstfile count=1024; rm tstfile;'
alias writenetatmo='/Users/rabshakeh/workspace/research/netatmo/netatmo.py&&/Users/rabshakeh/workspace/research/netatmo/write_wallpaper_time.py'
alias ws='cd $HOME/workspace'
alias wsd='cd ~/workspace/documentation'
alias wserver='globalpython3 -m http.server'
alias wsf='cd $HOME/workspace/forks'
alias wsp='cd $HOME/workspace/pip'
alias wspc='cd $HOME/workspace/pip/consoleprinter/consoleprinter'
alias wttr='clear;curl wttr.in/rotterdam'
alias wwhich='_wwhich'
alias www='cd $HOME/workspace/cryptobox/www_cryptobox_nl/source/coffee'
alias wwwserver='_wwwserver'
alias xanthos='ssh xanthos.a8.nl'
alias xtar='_xtar'
alias xtop='/usr/bin/top -o cpu -O +rsize -s 1 -n 20'
alias yitro='ssh yitro.a8.nl'
alias yt='cd ~/Movies/youtube; osascript -e "tell application \"Google Chrome\" to open location \"http://youtube.com\""&&osascript -e "tell application \"Google Chrome\" to activate"'
alias ytdlmp3='_ytdlmp3'
alias ytdlmp4='_ytdlmp4'
alias ytdp='cd ~/Movies/youtube; globalpython3 process_youtube.py downloadprocess; globalpython3 process_youtube.py podcast'
alias ytdpa='cd ~/Movies/youtube; globalpython3 process_youtube.py --audio downloadprocess'
alias ytep='ytdlmp4'
alias ytln='ln -s ~/workspace/research/youtubedownload/process_youtube.py .'
alias ytpl='_ytplayl'
alias ytplayl='_ytplayl'
alias ytpod='cd ~/Movies/youtube; globalpython3 process_youtube.py podcast'
alias ytpodcast='cd ~/Movies/youtube; globalpython3 process_youtube.py podcast'
alias ytreset='cd /Users/rabshakeh/Movies/youtube; rm -Rf *; ln -s ~/workspace/research/youtubedownload/process_youtube.py .&&osascript -e "tell application \"Google Chrome\" to open location \"https://www.youtube.com/playlist?list=WL\""&&osascript -e "tell application \"Google Chrome\" to activate"'
