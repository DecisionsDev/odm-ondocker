ARG SOURCEIMAGE
FROM ${SOURCEIMAGE}
ARG USERID

USER root

RUN set -ex; \
    dnf erase -y python3-subscription-manager-rhsm --disableplugin=subscription-manager; \
    dnf -y upgrade --disableplugin=subscription-manager; \
    dnf -y install nss nss-tools unzip procps-ng net-tools --disableplugin=subscription-manager; \
    dnf clean all --disableplugin=subscription-manager; \
    rm -rf /var/cache/dnf; 

USER $USERID