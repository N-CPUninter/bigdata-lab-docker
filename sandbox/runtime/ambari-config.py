#!/usr/bin/env python3
"""Atualiza propriedades de configuração de um cluster Ambari via REST (substitui o configs.py do Ambari,
que não funciona em Python 3).

Uso:
  ambari-config.py set  <tipo> <chave>=<valor> [<chave>=<valor> ...]
  ambari-config.py get  <tipo> [<chave>]
  ambari-config.py apply-json <arquivo.json>     # {"tipo": {"chave": "valor", ...}, ...}

Exemplo:
  ambari-config.py set zoo.cfg admin.enableServer=false
"""
import base64
import json
import os
import sys
import time
import urllib.request

AMB = os.environ.get("AMBARI_URL", "http://localhost:8080/api/v1")
CLUSTER = os.environ.get("AMBARI_CLUSTER", "sandbox")
AUTH = base64.b64encode(os.environ.get("AMBARI_AUTH", "admin:admin").encode()).decode()


def req(method, path, body=None):
    data = json.dumps(body).encode() if body is not None else None
    r = urllib.request.Request(AMB + path, data=data, method=method,
                               headers={"Authorization": "Basic " + AUTH, "X-Requested-By": "ambari"})
    with urllib.request.urlopen(r, timeout=60) as resp:
        raw = resp.read()
        return json.loads(raw) if raw else {}


def current(ctype):
    """Retorna (properties, properties_attributes) da versão desejada atual do tipo de config."""
    c = req("GET", f"/clusters/{CLUSTER}?fields=Clusters/desired_configs")
    tag = c["Clusters"]["desired_configs"].get(ctype, {}).get("tag")
    if tag is None:
        return {}, {}
    d = req("GET", f"/clusters/{CLUSTER}/configurations?type={ctype}&tag={tag}")
    item = d["items"][0]
    return item.get("properties", {}) or {}, item.get("properties_attributes", {}) or {}


def set_props(ctype, changes):
    props, attrs = current(ctype)
    props.update(changes)
    tag = f"version{int(time.time() * 1000)}"
    body = {"Clusters": {"desired_config": [{"type": ctype, "tag": tag, "properties": props,
                                              "properties_attributes": attrs}]}}
    req("PUT", f"/clusters/{CLUSTER}", body)
    return tag


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    cmd = argv[1]
    if cmd == "get":
        props, _ = current(argv[2])
        if len(argv) > 3:
            print(props.get(argv[3], ""))
        else:
            print(json.dumps(props, indent=2, sort_keys=True))
    elif cmd == "set":
        ctype = argv[2]
        changes = dict(kv.split("=", 1) for kv in argv[3:])
        print(ctype, set_props(ctype, changes), ", ".join(changes))
    elif cmd == "apply-json":
        for ctype, changes in json.load(open(argv[2], encoding="utf-8")).items():
            print(ctype, set_props(ctype, changes), ", ".join(changes))
    else:
        print(__doc__)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
