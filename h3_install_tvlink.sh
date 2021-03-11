#!/bin/sh

# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2011-present Alex@ELEC (https://alexelec.tv)

sed -i -re 's/^(option check_signature.*)/#\1/g' /etc/opkg.conf

echo ""
echo "TVLINK: update and install depends..."
echo ""
opkg update
opkg install curl

(
  cd /usr/bin
  ln -sf python3.8 python
)

python -m pip install --upgrade pip

pip install pycountry
pip install isodate
pip install pysocks
pip install websocket-client

echo ""
echo "TVLINK: enable Swap 512M..."
echo ""
/etc/enable-swap.sh

URL_MAIN="https://github.com/AlexELEC/TVLINK-arm7/releases/download"
URL_LAST="https://github.com/AlexELEC/TVLINK-arm7/releases/latest"

TVLINK_DIR="/opt/tvlink"
TVLINK_URL=

UPD_VER=`curl -s "$URL_LAST" | sed 's|.*tag\/||; s|">redirected.*||')`

if curl --output /dev/null --silent --head --fail "$URL_MAIN/$UPD_VER/TVLINK-$UPD_VER.tar.bz2"
then
    TVLINK_URL="$URL_MAIN/$UPD_VER/TVLINK-$UPD_VER.tar.bz2"
else
    echo "ERROR: not found TVLINK release."
    exit 1
fi

TEMP_FILE="/tmp/TVLINK-$UPD_VER.tar.bz2"
echo ""
echo "TVLINK: download TVLINK-$UPD_VER release..."
echo ""

curl --retry 3 --connect-timeout 10 -L -o "$TEMP_FILE" "$TVLINK_URL"

echo ""
echo "TVLINK: install TVLINK-$UPD_VER release..."
echo ""

rm -fR $TVLINK_DIR
mkdir -p $TVLINK_DIR
tar -jxvf $TEMP_FILE -C $TVLINK_DIR
rm -f $TEMP_FILE

cat <<EOF > /etc/init.d/tvlink
#!/bin/sh /etc/rc.common

# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2011-present Alex@ELEC (https://alexelec.tv)

START=99
STOP=12
USE_PROCD=1

start_service() {
	procd_open_instance tvlink
	procd_set_param command /opt/tvlink/tvlink

	procd_set_param respawn

	procd_set_param limits nofile=16384
	procd_set_param stdout 0
	procd_set_param stderr 0
	procd_close_instance
}

stop_service() {
	rm -f /run/tvlink
}
EOF

chmod +x /etc/init.d/tvlink

echo ""
echo "TVLINK: install completed."
echo ""
echo "TVLINK: start service."

/etc/init.d/tvlink enable
/etc/init.d/tvlink start

echo ""
echo "TVLINK: Done! See log in /opt/tvlink/log/tvlink.log"
echo ""
exit 0
