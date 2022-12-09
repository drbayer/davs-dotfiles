#!/usr/bin/env bash

from=$1
to=$2

mv ~/.kube/config ~/.kube/config.$to
mv ~/.kube/config.$from ~/.kube/config

