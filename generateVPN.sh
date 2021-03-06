#!/bin/sh
#USER="$(whoami)"
#GROUP="vpns"

SOCKETFILE="/tmp/socketIPC.s"
SOCKET_DIR="$(dirname ${SOCKETFILE})"
VPN_DIR="/etc/openvpn/clientconfigurations/"
CHECKER_NEW_VPN="$SOCKET_DIR""/finish/"

mkdir -p "${SOCKET_DIR}"
mkdir -p "$CHECKER_NEW_VPN"
#chown "${USER}:${GROUP}" "${SOCKET_DIR}"

chmod 777 "${SOCKET_DIR}"

rm -f "${SOCKETFILE}"

change_permission() {
  # Wait for the file creation and then change the permissions.
  while ! test -e "$1" ; do
    sleep .3
    echo "File not found sleeping"
  done

  echo "File found, changing permission"
  chmod 660 "$1"
}

change_permission "${SOCKETFILE}" &

nc -klU "${SOCKETFILE}" | while read USERNAME; do
  if echo "${USERNAME}" | egrep -q '^[a-fA-F0-9]+$'; then
    ksh $(which generate_certificate.sh) "$USERNAME"
    ln -s "$VPN_DIR""$USERNAME" "$CHECKER_NEW_VPN""$USERNAME"
  fi
done