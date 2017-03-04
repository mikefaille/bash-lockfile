#!/bin/bash

##  LockFile function ##
# example:
#   main() {
#       source LockFile.sh
#       LockFile create
#       RunScriptStuff
#       LockFile remove
#   }

set -o errexit
set -o nounset
set -o pipefail

#Globals
Prog=$(basename "$0")
Pid=$$
PidFile=/tmp/$Prog.pid


LockFile() {
    ## Manage LockFile ##
    # Usage:  LockFile [ create | remove | test ] #
    _LockCmd=$1
    rcode=0
    _LockPid=―"unassigned"
    case $_LockCmd in
        test)   [ -f $PidFile ] && _LockPid=$(cat $PidFile) && rcode=1
                [ $_LockPid ] && [ -d /proc/$_LockPid ] && rcode=2
                [ $rcode -eq 1 ] && echo "Stale Lockfile (pid:$_LockPid)"
                [ $rcode -eq 2 ] && echo "Active Lockfile (pid:$_LockPid)"
                return $rcode
                ;;
        remove) [ -f $PidFile ] && rm -f $PidFile
                ;;
        create) LockFile test
                RetVal=$?
                [ $RetVal -eq 2 ] && echo "Error: $Prog already running." && exit 1
                if [ $RetVal -eq 1 ]; then
                    echo "Info: Removing stale lockfile."
                    LockFile remove
                fi
                touch $PidFile
                echo $Pid >$PidFile
                ;;
        *)  echo "[Internal Error] $FUNCNAME: unknown argument '$_LockCmd'."
                ;;
    esac

}
