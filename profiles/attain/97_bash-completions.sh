#!/usr/bin/env bash

completions_dir='/opt/attain/etc/bash/'
if [ -d $completions_dir ]; then
    for completionfile in $completions_dir/*.bash ; do
        if [ -f "$completionfile" ]; then
            source "$completionfile"
        fi
    done
fi

