ARG BUILD_FROM="bitxeno/atvloadly:v0.7.2@sha256:7582d461c38e1e74d5fd5d5205bd42b2ac430b0207ce0f91bdaa2e11b8ef9f5f"
FROM ${BUILD_FROM}

ARG BUILD_VERSION
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
