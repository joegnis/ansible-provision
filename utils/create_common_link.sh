#!/bin/bash
# Create a symlink of shared directories for a role
# Input:
# 1. name of the directory (e.g. tasks, files, ...)
# 2. root dir of a role
cd "$2"/$1
ln -s ../../common/$1 common_$1
