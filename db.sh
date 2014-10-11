#!/bin/bash -

cd /usr/home/qubing/data

function check_process_lock()
{
    if [ -f $1 ]; then
        if /bin/ps -p `cat $1` >/dev/null 2>&1; then
            echo "processing $1"
            return 0
        else
            unlink $1
        fi
    fi
    return 1
}

check_process_lock tmp/export.pid

if [ $? = "1" ]; then
  /bin/bash export.sh
fi

check_process_lock tmp/import.pid

if [ $? = "1" ]; then
  /bin/bash import.sh
fi


