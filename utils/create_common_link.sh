#!/bin/bash
# Create a symlink of shared tasks for a role
# Input: root dir of a role
cd "$1"/tasks
ln -s ../../common/tasks common_tasks
