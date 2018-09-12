#!/usr/bin/env bash

backup=""
overwrite=1
relative=0
dryrun=0
newfile=()
exist=()
curdir=$(pwd -P)
isserver=0
onlyfile=0

# help
HELP="Usage: $0 [-rndcsFh] [-b <backup file postfix>]

Arguments:
      -b  Set backup postfix, like \"bak\" (default: \"\": no back up is made)
      -r  Use relative path (default: absolute path)
      -n  Don't overwrite if file is already exist
      -d  Dry run, don't install anything
      -s  Install puppet server.
      -F  Install only files.
      -h  Print Help (this message) and exit
"

while getopts b:rndcsFh OPT;do
  case $OPT in
    "b" ) backup=$OPTARG ;;
    "r" ) relative=1 ;;
    "n" ) overwrite=0 ;;
    "d" ) dryrun=1 ;;
    "s" ) isserver=1 ;;
    "F" ) onlyfile=1 ;;
    "h" ) echo "$HELP" 1>&2; exit;;
    * ) echo "$HELP" 1>&2; exit 1;;
  esac
done

myinstall () {
  origin="$1"
  target="$2"
  if [ -z "$origin" ] || [ -z "$target" ];then
    echo "Wrong args for myinstall: origin=$origin, target=$target"
    exit 1
  fi

  install_check=1
  if [ $dryrun -eq 1 ];then
    install_check=0
  fi
  if [ "$(ls "$target" 2>/dev/null)" != "" ];then
    exist=("${exist[@]}" "$(basename "$target")")
    if [ $dryrun -eq 1 ];then
      echo -n ""
    elif [ $overwrite -eq 0 ];then
      install_check=0
    elif [ "$backup" != "" ];then
      mv "$target" "${target}.$backup"
    else
      rm "$target"
    fi
  else
    newfile=("${newfile[@]}" "$(basename "$target")")
  fi
  if [ $install_check -eq 1 ];then
    mkdir -p "$(dirname "$target")"
    cp -r  "$origin" "$target"
  fi
}

if [ $relative -eq 1 ];then
  curdir=$(pwd)
fi

if [ $dryrun -eq 1 ];then
  echo "*** This is dry run, not install anything ***"
fi

if [ $onlyfile -eq 0 ];then
  echo "**********************************************"
  echo "Install puppet 5, ruby, librarian-puppet"
  echo "**********************************************"
  echo
  if [ $dryrun -ne 1 ];then
    rpm -Uvh https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
    if [ $isserver -eq 1 ];then
      yum install -y puppetserver
      systemctl enable puppetserver
      systemctl start puppetserver
    else
      yum install -y puppet-agent
    fi
    yum install -y git
    yum install -y ruby
    gem install librarian-puppet
    export PATH=/opt/puppetlabs/bin:$(gem environment|grep "EXECUTABLE DIRECTORY"|cut -d' ' -f6):$PATH
  fi
fi

echo "**********************************************"
echo "Install puppet files"
echo "**********************************************"
echo
for f in $(find ./etc/ -type f|sed 's/^.//');do
  myinstall "${curdir}${f}" "$f"
done
if [ $dryrun -eq 0 ];then
  mkdir -p /etc/puppetlabs/code/environments/production/files/
  if [ $isserver -eq 1 ];then
    chown -R puppet /etc/puppetlabs/code/environments/production/files/*
  fi
fi

if [ $onlyfile -eq 0 ];then
  echo "**********************************************"
  echo "Install puppet modules"
  echo "**********************************************"
  echo
  if [ $dryrun -ne 1 ];then
    cd /etc/puppetlabs/code/environments/production
    [[ -z "$HOME" ]] && export HOME=/root
    librarian-puppet clean
    rm -rf modules .tmp Puppetfile.lock
    librarian-puppet install
    cd "$curdir"
  fi
fi

# Summary
if [ $dryrun -eq 1 ];then
  echo "Following files don't exist:"
else
  echo "Following files were newly installed:"
fi
echo "  ${newfile[*]}"
echo
echo -n "Following files existed"
if [ $dryrun -eq 1 ];then
  echo "Following files exist:"
elif [ $overwrite -eq 0 ];then
  echo "Following files exist, remained as is:"
elif [ "$backup" != "" ];then
  echo "Following files existed, backups (*.$backup) were made:"
else
  echo "Following files existed, replaced old one:"
fi
echo "  ${exist[*]}"
if [ $dryrun -eq 0 ];then
  echo ""
  echo "$ diff -r {$curdir/,}/etc/puppetlabs/code/environments/production/data"
  diff -r {$curdir/,}/etc/puppetlabs/code/environments/production/data
fi
echo
