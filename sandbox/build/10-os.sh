#!/usr/bin/env bash
# Base do sistema: pacotes, JDK 8, Python 3, usuários da sandbox, sshd, ttyd (web shell).
set -euo pipefail

# Mirrors espelhados do Rocky ficam desencontrados entre BaseOS e AppStream (openssl-libs vs openssl-devel);
# o repositório canônico garante versões consistentes e builds reproduzíveis.
sed -i 's/^mirrorlist=/#mirrorlist=/; s|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://dl.rockylinux.org/pub/rocky|' /etc/yum.repos.d/rocky*.repo
dnf -y makecache
dnf -y install epel-release
# --allowerasing: o curl completo substitui o curl-minimal da imagem base (scripts do Ambari fazem `yum install curl`)
dnf -y install --allowerasing --nobest \
  curl wget unzip tar gzip bzip2 sed which procps-ng hostname iproute net-tools diffutils findutils \
  sudo passwd shadow-utils openssh-server openssh-clients nc telnet nano vim-minimal less \
  gcc gcc-c++ make openssl openssl-devel krb5-workstation krb5-libs snappy snappy-devel \
  java-1.8.0-openjdk-devel \
  python3 python3-pip python3-devel \
  postgresql-server postgresql mariadb-server mariadb \
  git rsync
dnf clean all

# `python` sem sufixo: odp-select e vários scripts do stack usam #!/usr/bin/env python
alternatives --install /usr/bin/python python /usr/bin/python3 1 || ln -sf /usr/bin/python3 /usr/bin/python

# JAVA_HOME estável (sem /jre no fim) — o mesmo caminho é passado ao ambari-server setup
JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")"
cat > /etc/profile.d/java.sh <<EOP
export JAVA_HOME=${JAVA_HOME}
export PATH=\$JAVA_HOME/bin:\$PATH
EOP
echo "$JAVA_HOME" > /etc/java_home

# Usuários iguais aos da VM HDP 2.6.5 (guias dos alunos usam estas credenciais)
useradd -m -s /bin/bash maria_dev && echo "maria_dev:maria_dev" | chpasswd
useradd -m -s /bin/bash raj_ops   && echo "raj_ops:raj_ops"     | chpasswd
usermod -aG wheel raj_ops
echo "root:hadoop" | chpasswd
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

# sshd (porta 22 dentro do container; publicada como 2222 no host, igual ao HDP)
ssh-keygen -A
sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#\?UseDNS .*/UseDNS no/' /etc/ssh/sshd_config

# ttyd: terminal web na porta 4200 (substitui o shell-in-a-box do HDP)
TTYD_VERSION=1.7.7
ARCH="$(uname -m)"
curl -fsSL "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${ARCH}" -o /usr/local/bin/ttyd
chmod +x /usr/local/bin/ttyd

# Limites usados pelo Hadoop
cat >> /etc/security/limits.conf <<EOL
* soft nofile 65536
* hard nofile 65536
* soft nproc 65536
* hard nproc 65536
EOL

# O Ambari grava /etc/security/limits.d/*.conf pedindo nproc 65536. Quando o container roda
# com um hard limit menor (é o caso do runner do GitHub Actions), o pam_limits falha e o
# "su" usado pelo agente recusa a sessão: "su: cannot open session: Permission denied".
# Em sandbox esses limites não agregam segurança, então o pam_limits passa a ser opcional.
for f in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
  sed -i --follow-symlinks -E 's/^(session[[:space:]]+)required([[:space:]]+)pam_limits\.so/\1optional\2pam_limits.so/' "$f"
done

# Locale UTF-8 (roteiros usam dados em pt-BR / ISO-8859-1)
dnf -y install glibc-langpack-en glibc-langpack-pt && dnf clean all
echo 'export LANG=en_US.UTF-8' > /etc/profile.d/lang.sh
