#!/bin/bash
fpath=$(readlink -f $1)'
cd /opt/stack/tempest && $fpath
