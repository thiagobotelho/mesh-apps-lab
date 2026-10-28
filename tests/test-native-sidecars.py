#!/usr/bin/env python3
"""Cobertura de sidecars tradicionais/nativos e recusa de proxies não prontos."""
import importlib.util
from pathlib import Path

path = Path(__file__).resolve().parents[1] / 'scripts/check-proxy.py'
spec = importlib.util.spec_from_file_location('proxy_check', path)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
for native in [False, True]:
    container = {'name': 'istio-proxy', **({'restartPolicy': 'Always'} if native else {})}
    key = 'initContainers' if native else 'containers'
    statuses = 'initContainerStatuses' if native else 'containerStatuses'
    for state in [False, True]:
        pod = {'spec': {key: [container]}, 'status': {statuses: [{'name': 'istio-proxy', 'ready': state}]}}
        assert module.ready(pod) == state
assert not module.ready({'spec': {'containers': [{'name': 'sleep'}]}, 'status': {}})
assert not module.ready({'spec': {'initContainers': [{'name': 'istio-proxy'}]},
                         'status': {'initContainerStatuses': [{'name': 'istio-proxy', 'ready': True}]}})
print('PASS: sidecars tradicionais/nativos, prontidão e recusa de init convencional')
