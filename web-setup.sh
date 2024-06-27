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

BASE_PATH=~/"$1"

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

mkdir -p $BASE_PATH
mkdir -p $BASE_PATH/templates
mkdir -p $BASE_PATH/static
mkdir -p $BASE_PATH/static/imgs
mkdir -p $BASE_PATH/static/css
mkdir -p $BASE_PATH/static/js
cd $BASE_PATH
echo -e "from app import app\nif __name__ == '__main__':\n	app.run('0.0.0.0', 1234)" > wsgi.py
echo -e "from flask import Flask\napp = Flask(__name__)\n@app.route('/')\ndef index():\nreturn 'Hello World'" > app.py
echo -e "[uwsgi]\nsocket=127.0.0.1:1234\nmodule=wsgi:app\nprocesses=2\nchmod-socket=666\npidfile=./uwsgi.pid\ndaemonize=./uwsgi.log\nlog-reopen=true\ndie-on-term=true\nmaster=true\nvacuum=true\nenable-threads=true" > uwsgi.ini
echo -e "uwsgi --ini uwsgi.ini" > start.sh
echo -e "uwsgi --stop uwsgi.pid" > stop.sh
cd /etc/nginx/sites-available/
rm default
echo -e "server {\nlisten 80 default_server;\nlisten [::]:80 default_server\nlocation / {\ninclude /etc/nginx/uwsgi_params;\nuwsgi_pass 127.0.0.1:1234;\n}\n}" > default

if pgrep nginx > /dev/null then
	systemctl restart nginx
else
	systemctl start nginx
fi

