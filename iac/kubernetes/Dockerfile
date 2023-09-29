FROM bitnami/kubectl
USER root
RUN install_packages apt
RUN apt update && \
    apt install -y vim && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
USER 1001
WORKDIR /kubernetes/