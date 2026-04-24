# SEL0433-2026-Thales-Felipe
# Sistema de Dosagem Rotativa Crítica (Baseado em 8051)
**Autor:** Thales Vasconcelos Aguiar de Oliveira | **NUSP:** 15489730
**Autor:** Felipe Assis Bernardes Falvo| **NUSP:** 15004433
**Disciplina:** SEL0433 - Aplicação de Microprocessadores

## 🚀 Visão Geral do Projeto
Este projeto implementa o firmware *bare-metal* para um sistema de dosagem rotativa utilizando o microcontrolador da família MCS-51 (8051).

O sistema conta pulsos de um motor DC. A cada 10 voltas (eventos), um ciclo de dosagem é concluído e o contador é reiniciado. Um interruptor de emergência permite a reversão imediata do fluxo para expurgo e destravamento, abortando a contagem atual.
