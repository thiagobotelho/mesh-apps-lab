# Ver Allow/Drop na interface

## Pré-requisitos

- Cenário 02 ou 06 aplicado em mesh-lab.
- Loki/Logging e UIPlugin de logs disponíveis.
- Overlay de desenvolvimento do loki-gitops com input OVN e pipeline
  ovn-audit-mesh-lab sincronizado.
- Conta com acesso aos logs de auditoria. Não conceda acesso a audit a todos
  os usuários apenas para visualizar os exercícios.

O namespace da base habilita auditoria de decisões OVN:

```yaml
metadata:
  annotations:
    k8s.ovn.org/acl-logging: '{"allow":"info","deny":"info"}'
```

A anotação não altera o resultado das políticas nem exige FeatureGate.
Os eventos são enviados ao Loki de logging, tenant audit. O Loki de fluxos do
Network Observability continua separado.

## Consultar pelo Console

1. Abra Observe → Logs.
2. Selecione tipo de log Audit e uma janela recente.
3. No modo de consulta LogQL, consulte:

```logql
{log_type="audit"} |= "NP:mesh-lab:"
```

Somente bloqueios:

```logql
{log_type="audit"} |= "NP:mesh-lab:" |= "verdict=drop"
```

Somente permissões:

```logql
{log_type="audit"} |= "NP:mesh-lab:" |= "verdict=allow"
```

Não filtre por kubernetes.namespace_name=mesh-lab: esses registros são auditoria
do nó, e o namespace da política está no texto da ACL.
Expanda a linha e confira name, verdict, direction, nw_src, nw_dst e tp_dst.

## Interpretar o cenário 02

| Cliente | curl esperado | Evidência OVN esperada |
|---|---|---|
| sleep | HTTP 200 | verdict=allow, regra NP:mesh-lab:httpbin-somente-sleep:Ingress:0 |
| sleep-denied | timeout/HTTP 000 | verdict=drop, regra de isolamento NP:mesh-lab:Ingress |

O drop implícito pode identificar o namespace/direção sem nomear uma política.
NetworkPolicies são aditivas; o bloqueio decorre da ausência de uma permissão
aplicável ao destino isolado. Não atribua esse drop a uma regra deny explícita.

Compare os IPs atuais, não nomes/IPs de execuções antigas:

```bash
oc -n mesh-lab get pods -o wide
oc -n mesh-lab get networkpolicy
```

Gere novas chamadas com os comandos do exercício e atualize Logs.
Os eventos são sujeitos aos limites e à rotação da auditoria OVN.

## Consulta direta no Console

Se Loki estiver indisponível, abra Workloads → Pods, selecione o projeto
openshift-ovn-kubernetes e o pod ovnkube-node do nó do exercício. Na aba Logs,
selecione o container ovn-acl-logging e procure NP:mesh-lab: e verdict=drop
ou verdict=allow. A conta precisa de permissão para logs nesse namespace.

## Diferença para Network Traffic

Network Traffic mostra fluxos, drops de kernel, DNS e RTT. Um SYN para
Service:8000 sem resposta não informa sozinho a decisão da ACL.
Observe → Logs fornece a evidência de auditoria OVN para o exercício.

A coluna Network Events dentro de Network Traffic exige OVNObservability
e NetworkEvents. O procedimento documentado usa TechPreviewNoUpgrade,
irreversível e incompatível com atualizações menores. Esse recurso não é
habilitado por este laboratório.

## Reduzir ou desativar auditoria

Para registrar apenas bloqueios, altere a anotação na base e reaplique o
cenário manualmente. Para desativar temporariamente:

```bash
oc annotate namespace mesh-lab k8s.ovn.org/acl-logging-
```

Uma nova aplicação da base restaura a anotação versionada. Para desativar
permanentemente, remova-a também do Git. Logs armazenados seguem a retenção
do Loki; remover a anotação não apaga o histórico.

## Referências

- [Red Hat: auditoria de rede](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html-single/network_security/index)
- [Red Hat Logging: input audit OVN](https://docs.redhat.com/en/documentation/red_hat_openshift_logging/6.5/html/configuring_logging/configuring-log-forwarding)
- [Network Events e pré-requisitos](https://docs.redhat.com/en/documentation/openshift_container_platform/4.21/html/network_observability/nw-observe-network-traffic)
