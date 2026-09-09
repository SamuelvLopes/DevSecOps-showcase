# KORP-047 — Beyla para auto-instrumentação opcional

Status: planned. Risco: alto. Depende de KORP-046.

## Objetivo

Avaliar Beyla como complemento opcional de auto-instrumentação eBPF para o
ambiente Kubernetes.

## Implementação e limites

Beyla deve ser bônus, não caminho obrigatório. A implementação só deve seguir se
o cluster alvo aceitar as permissões necessárias de eBPF sem enfraquecer a
segurança do core.

## Aceite e verificação

- [ ] Valores Helm ou manifests opcionais para Beyla.
- [ ] Permissões necessárias documentadas.
- [ ] Consulta ou dashboard demonstrando telemetria automática.
- [ ] Caminho de remoção documentado.

## Segurança, observabilidade e recuperação

Por exigir capacidades sensíveis no nó, Beyla deve ficar desabilitado por padrão
e documentado como experimento controlado.

## Evidências

Pendentes para a implementação do ticket.
