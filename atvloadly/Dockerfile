ARG BUILD_FROM="bitxeno/atvloadly:v0.4.8@sha256:f459b916835c724a3ed9e55a450e493f6129b377f9467759338c64e7970af947"
FROM ${BUILD_FROM}

ARG BUILD_VERSION="0.4.8-1"
ARG BUILD_ARCH

LABEL \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.type="app" \
    io.hass.arch="${BUILD_ARCH}" \
    org.opencontainers.image.title="atvloadly Home Assistant App" \
    org.opencontainers.image.source="https://github.com/robinerhardt/home-assistant-atvloadly-app"

ENV SERVICE_PORT="5533" \
    DBUS_SYSTEM_BUS_ADDRESS="unix:path=/run/dbus/system_bus_socket" \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# atvloadly's Linux discovery implementation talks to Avahi through D-Bus.
# Keep both services inside the container instead of exposing the host D-Bus.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        avahi-daemon \
        dbus \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY avahi-daemon.conf /etc/avahi/avahi-daemon.conf
COPY disable-web-terminal.sh /usr/local/sbin/bash
COPY run.sh /run-app.sh

RUN chmod 0755 /usr/local/sbin/bash /run-app.sh

EXPOSE 5533/tcp

ENTRYPOINT ["/run-app.sh"]
