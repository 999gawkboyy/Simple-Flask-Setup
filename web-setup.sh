#!/bin/bash

if [ -z "$1" ]; then
        echo "Usage: ./web-setup.sh {project_name}"
        exit 1
fi

if sudo -v >/dev/null 2>&1; then
        echo "sudo"
fi

SUDO="sudo"
$SUDO apt-get update
$SUDO apt-get upgrade

BASE_PATH="~/$1"

if command -v nginx &>/dev/null; then
        echo "nginx is installed"
else
        echo "nginx is not installed, start installing"
        apt-get install nginx
fi

if command -v python3 &>/dev/null; then
        echo "python is installed"
        python3 --version
else
        echo "python is not installed, start installing"
        apt-get install python3
fi

pip3 install flask
pip3 install uwsgi

mkdir $BASE_PATH/templates
mkdir $BASE_PATH/static/imgs
mkdir $BASE_PATH/static/css
mkdir $BASE_PATH/static/js

echo "www\nwww" > wsgi.py

