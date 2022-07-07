#!/bin/bash
PODNAME="dotnet-appmonitoring"
podman pod create --name ${PODNAME}  -p 5000:80 -p 52323:52323 -p 30090:9090 -p 3000:3000
podman run -d --rm --name memoryleak --pod ${PODNAME} --mount type=volume,src=dotnet-tmp,target=/tmp memoryleak-image
podman run -d --rm --name monitor --pod ${PODNAME} --mount type=volume,src=dotnet-tmp,target=/tmp mcr.microsoft.com/dotnet/monitor --urls http://*:52323 --no-auth
podman run -d --rm --name prometheus-container -e TZ=UTC --pod ${PODNAME} -v ${PWD}/prometheus.yml:/etc/prometheus/prometheus.yml ubuntu/prometheus
podman run --pod ${PODNAME} --rm --name grafana -d grafana/grafana
