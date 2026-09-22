#!/usr/bin/env bash
# Configura os repositórios Clemlab (Ambari + ODP) para dnf.
# Os arquivos .repo oficiais apontam para o S3 da Clemlab.
set -euo pipefail
: "${AMBARI_BUILD:?}" "${ODP_BUILD:?}" "${ODP_UTILS_VERSION:?}"
ARCHIVE=https://archive.clemlab.com/centos9
curl -fsSL "$ARCHIVE/ambari-release/${AMBARI_BUILD}/ambari.repo" -o /etc/yum.repos.d/ambari.repo
curl -fsSL "$ARCHIVE/odp-release/${ODP_BUILD}/odp.repo" -o /etc/yum.repos.d/odp.repo
curl -fsSL https://archive.clemlab.com/RPM-GPG-KEY-SHA256-Jenkins -o /etc/pki/rpm-gpg/RPM-GPG-KEY-Clemlab
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-Clemlab
# Os RPMs do ODP não são assinados (só o repo tem chave): gpgcheck desligado, download via HTTPS.
sed -i "s#^gpgkey=.*#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Clemlab#; s/^gpgcheck=1/gpgcheck=0/" /etc/yum.repos.d/ambari.repo /etc/yum.repos.d/odp.repo
dnf -y makecache
dnf repolist
