#!/usr/bin/env python3
"""Valida proxies prontos, incluindo sidecars nativos, em uma lista JSON de Pods."""
import json
import sys


def ready(pod):
    spec = pod.get("spec", {})
    status = pod.get("status", {})
    regular = any(c["name"] == "istio-proxy" for c in spec.get("containers", []))
    native = any(c["name"] == "istio-proxy" and c.get("restartPolicy") == "Always"
                 for c in spec.get("initContainers", []))
    statuses = status.get("containerStatuses" if regular else "initContainerStatuses", [])
    return (regular or native) and any(c["name"] == "istio-proxy" and c.get("ready")
                                      for c in statuses)


if __name__ == "__main__":
    pods = [p for p in json.load(sys.stdin).get("items", [])
            if not p.get("metadata", {}).get("deletionTimestamp")]
    if not pods or not all(ready(p) for p in pods):
        sys.exit("FAIL: proxy ausente ou não pronto")
    print(f"PASS: proxy pronto em {len(pods)} Pod(s)")
