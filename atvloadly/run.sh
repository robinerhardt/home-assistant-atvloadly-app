#!/bin/bash
set -Eeuo pipefail

DBUS_PID=""
AVAHI_PID=""
ATVLOADLY_PID=""

log() {
    printf '[atvloadly-app] %s\n' "$*"
}

stop_processes() {
    trap - TERM INT
    for pid in "${ATVLOADLY_PID}" "${AVAHI_PID}" "${DBUS_PID}"; do
        if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
            kill -TERM "${pid}" 2>/dev/null || true
        fi
    done
    wait 2>/dev/null || true
}

trap 'stop_processes; exit 143' TERM INT

mkdir -p /config /data /run/dbus /run/avahi-daemon
rm -f /run/dbus/pid /run/dbus/system_bus_socket /run/avahi-daemon/pid

# Make the editable upstream configuration available in Home Assistant's
# app-specific addon_configs directory. Migrate an existing private config on
# the first start after upgrading, while keeping all sensitive runtime data in
# /data.
if [[ ! -f /config/config.yaml ]]; then
    if [[ -f /data/config.yaml && ! -L /data/config.yaml ]]; then
        cp -p /data/config.yaml /config/config.yaml
    else
        cp /keep/config.yaml /config/config.yaml
        chmod 0644 /config/config.yaml
    fi
fi
ln -sfn /config/config.yaml /data/config.yaml

# Ubuntu container images can intentionally ship an existing but empty
# /etc/machine-id. dbus-uuidgen --ensure refuses to replace an invalid file,
# so keep a valid ID in persistent app data and install it in both locations
# used by D-Bus before starting the private bus.
if ! MACHINE_ID="$(dbus-uuidgen --get=/data/machine-id 2>/dev/null)"; then
    MACHINE_ID="$(dbus-uuidgen)"
    printf '%s\n' "${MACHINE_ID}" > /data/machine-id
    chmod 0644 /data/machine-id
fi

printf '%s\n' "${MACHINE_ID}" > /etc/machine-id
chmod 0444 /etc/machine-id
mkdir -p /var/lib/dbus
ln -sfn /etc/machine-id /var/lib/dbus/machine-id

log "Starting private system D-Bus"
dbus-daemon --system --nofork --nopidfile &
DBUS_PID="$!"

for _ in {1..50}; do
    [[ -S /run/dbus/system_bus_socket ]] && break
    if ! kill -0 "${DBUS_PID}" 2>/dev/null; then
        log "D-Bus stopped before its socket became ready"
        stop_processes
        exit 1
    fi
    sleep 0.1
done

if [[ ! -S /run/dbus/system_bus_socket ]]; then
    log "Timed out waiting for the D-Bus socket"
    stop_processes
    exit 1
fi

log "Starting private Avahi browser"
avahi-daemon --no-chroot --debug &
AVAHI_PID="$!"

for _ in {1..50}; do
    [[ -s /run/avahi-daemon/pid ]] && break
    if ! kill -0 "${AVAHI_PID}" 2>/dev/null; then
        log "Avahi stopped before becoming ready"
        stop_processes
        exit 1
    fi
    sleep 0.1
done

if [[ ! -s /run/avahi-daemon/pid ]]; then
    log "Timed out waiting for Avahi"
    stop_processes
    exit 1
fi

export SERVICE_PORT=5533
log "Starting atvloadly on TCP port ${SERVICE_PORT}"
/entrypoint.sh &
ATVLOADLY_PID="$!"

set +e
wait -n "${DBUS_PID}" "${AVAHI_PID}" "${ATVLOADLY_PID}"
EXIT_STATUS="$?"
set -e

if kill -0 "${ATVLOADLY_PID}" 2>/dev/null; then
    log "A required discovery service stopped unexpectedly"
    EXIT_STATUS=1
else
    log "atvloadly stopped"
fi

stop_processes
exit "${EXIT_STATUS}"
