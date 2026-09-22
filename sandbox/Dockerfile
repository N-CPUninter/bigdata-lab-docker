# syntax=docker/dockerfile:1.7
# Sandbox Big Data (UNINTER) — substituto da VM HDP 2.6.5.
# Rocky Linux 9 + Ambari (Clemlab) + ODP (fork aberto do HDP), instalado por blueprint no build.
FROM rockylinux:9 AS pkgs

ARG AMBARI_BUILD=2.7.11.0.0-161
ARG ODP_BUILD=1.2.4.0-108
ARG ODP_UTILS_VERSION=1.2.4.0
ARG SANDBOX_FQDN=sandbox.hortonworks.com
ENV AMBARI_BUILD=${AMBARI_BUILD} ODP_BUILD=${ODP_BUILD} ODP_UTILS_VERSION=${ODP_UTILS_VERSION} \
    SANDBOX_FQDN=${SANDBOX_FQDN} LANG=en_US.UTF-8 container=docker

# 1) Sistema base, JDK 8, Python 3, usuários, sshd, ttyd
COPY sandbox/build/10-os.sh /build/
RUN bash /build/10-os.sh

# 2) Repositórios Clemlab (Ambari + ODP)
COPY sandbox/build/20-repos.sh /build/
RUN bash /build/20-repos.sh

# 3) Pacotes Ambari + ODP (camada grande e cacheável; o blueprint depois só configura).
#    O cache do dnf fica num cache mount do BuildKit: rebuilds não baixam os ~5 GB de novo.
COPY sandbox/build/packages.txt /build/
RUN --mount=type=cache,target=/var/cache/dnf,sharing=locked \
    V="$(echo "$ODP_BUILD" | tr '.-' '__')" \
    && dnf -y --setopt=keepcache=1 install $(grep -vE '^\s*(#|$)' /build/packages.txt | sed "s/@V@/$V/g")

FROM pkgs AS ambari
# 4) PostgreSQL + MariaDB + ambari-server/agent configurados (sem systemd)
COPY sandbox/build/30-ambari.sh /build/
RUN bash /build/30-ambari.sh

FROM ambari AS cluster
# 5) Cluster de um nó via blueprint (INSTALL_ONLY), NameNode formatado, HDFS semeado, tudo parado
COPY sandbox/build/40-blueprint.sh sandbox/build/blueprint.json sandbox/build/cluster-template.json sandbox/build/configs-8g.json sandbox/build/configs-16g.json /build/
COPY data/ /build/data/
COPY sandbox/runtime/oozie-sharelib-fix.sh /opt/lab/oozie-sharelib-fix.sh
RUN chmod +x /opt/lab/oozie-sharelib-fix.sh && bash /build/40-blueprint.sh

FROM cluster AS final
# 6) Extras fora do ODP: Pig, Flume, Storm, tarballs (Drill/Presto/Flink), Python (mrjob etc.), cache Ivy
COPY sandbox/runtime/presto-etc /opt/lab/presto-etc
# tarballs pré-baixados no host (sandbox/build/prefetch.sh) entram por bind mount: não viram camada da imagem
COPY sandbox/build/50-extras.sh sandbox/build/phoenix_utils.py /build/
RUN --mount=type=bind,source=sandbox/build/downloads,target=/build/downloads bash /build/50-extras.sh
COPY sandbox/build/55-downloads.sh /build/
RUN --mount=type=bind,source=sandbox/build/downloads,target=/build/downloads bash /build/55-downloads.sh
COPY sandbox/build/60-python.sh /build/
RUN --mount=type=bind,source=sandbox/build/downloads,target=/build/downloads bash /build/60-python.sh
COPY sandbox/build/70-ivy-cache.sh /build/
RUN bash /build/70-ivy-cache.sh

# 7) Runtime
COPY sandbox/runtime/ /opt/lab/
COPY sandbox/build/configs-8g.json sandbox/build/configs-16g.json /opt/lab/
RUN chmod +x /opt/lab/entrypoint.sh /opt/lab/lab /opt/lab/*.sh && ln -sf /opt/lab/lab /usr/local/bin/lab

EXPOSE 8080 8888 4200 22 8020 8050 8088 50070 10000 11000 16010 8765 6667 8082 8744 8756 8090 4040 9995 8889
VOLUME ["/hadoop", "/var/lib/mysql", "/var/lib/pgsql/data", "/home/maria_dev"]
ENTRYPOINT ["/opt/lab/entrypoint.sh"]
