#!/bin/sh

# Python 3.9.4 installation
# adapted from: https://www.ramoonus.nl/2021/04/10/how-to-install-python-3-9-4-on-raspberry-pi/
# you can change the build number here if you want a different version

varVersion=3.9.6

PYTHONVER="$(python -V 2>&1)"
if [[ "$PYTHONVER" = "Python ${varVersion}"]]; then
    echo "Python ${varVersion} is installed."
else
    echo "Python ${PYTHONVER} is installed, will proceed with Python ${varVersion} installation."
    apt-get install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libffi-dev

    mkdir /home/pi/installers
    cd /home/pi/installers

    wget "https://www.python.org/ftp/python/${varVersion}/Python-${varVersion}.tar.xz"
    tar xf "Python-${varVersion}.tar.xz"
    cd "Python-${varVersion}"
    ./configure --prefix="/usr/local/opt/python-${varVersion}"
    make -j 4
    make altinstall

    cd ..
    rm -r "Python-${varVersion}"
    rm "Python-${varVersion}.tar.xz"
fi
