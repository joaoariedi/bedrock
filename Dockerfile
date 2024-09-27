FROM alpine:3.20.1@sha256:b89d9c93e9ed3597455c90a0b88a8bbb5cb7188438f70953fede212a0c4394e0
LABEL maintainer="Fleet Developers"

RUN apk --update add ca-certificates
RUN apk --no-cache add jq openssl

# Create FleetDM group and user
RUN addgroup -S fleet && adduser -S fleet -G fleet

# Add a certificate for TLS encryption
RUN mkdir -p /etc/fleet/certs
RUN echo -e "[san]\nsubjectAltName=IP:100.93.31.1" | openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout /etc/fleet/certs/key.pem -out /etc/fleet/certs/cert.pem -subj "/CN=Trustly" -extensions san -config /proc/self/fd/0
RUN chown -R fleet:fleet /etc/fleet/certs

COPY ./fleet.yml ./home/fleet/fleet.yml
COPY ./build/binary-bundle/linux/fleet ./build/binary-bundle/linux/fleetctl /usr/bin/

USER fleet
CMD ["fleet", "serve"]
