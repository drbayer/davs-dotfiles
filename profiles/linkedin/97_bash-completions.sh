#!/usr/bin/env bash

if [ -d /export/content/linkedin/etc/bash/ ]; then
    for completionfile in /export/content/linkedin/etc/bash/*.bash ; do
        if [ -f "$completionfile" ]; then
            source "$completionfile"
        fi
    done
fi

