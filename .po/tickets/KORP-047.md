# KORP-047 — Beyla para auto-instrumentação opcional

Status: done. Risco: alto. Depende de KORP-046.

## Objetivo

Avaliar Beyla como complemento opcional de auto-instrumentação eBPF para o
ambiente Kubernetes.

## Implementação e limites

Beyla deve ser bônus, não caminho obrigatório. A implementação só deve seguir se
o cluster alvo aceitar as permissões necessárias de eBPF sem enfraquecer a
segurança do core.

## Aceite e verificação

- [x] Valores Helm opcionais para Beyla.
- [x] Permissões sensíveis documentadas.
- [x] Consulta/demonstração fica vinculada ao ambiente que permitir eBPF.
- [x] Caminho de remoção documentado.

## Segurança, observabilidade e recuperação

Por exigir capacidades sensíveis no nó, Beyla deve ficar desabilitado por padrão
e documentado como experimento controlado.

## Evidências

- `charts/observability/beyla-values.yaml` versionado como bônus controlado.
- `docs/kubernetes-observability.md` documenta Beyla como opcional por causa de eBPF.
