# SEL0433-2026-Thales-Felipe
# Sistema de Dosagem Rotativa Crítica (Baseado em 8051)
**Autor:** Thales Vasconcelos Aguiar de Oliveira | **NUSP:** 15489730
**Autor:** Felipe Assis Bernardes Falvo| **NUSP:** 15004433
**Disciplina:** SEL0433 - Aplicação de Microprocessadores

🚀 1. Visão Geral do Projeto
Este projeto consiste no desenvolvimento de um sistema embarcado bare-metal para o controlo de uma unidade de dosagem rotativa. Utilizando o microcontrolador 8051 (família MCS-51), o sistema monitoriza a rotação de um motor DC e contabiliza ciclos de dosagem.

Em cenários reais de engenharia aeroespacial, esta lógica é aplicada em sistemas de telemetria e controlo de válvulas, onde a precisão da contagem de eventos externos e a rapidez de resposta a interrupções de emergência são fundamentais.

🛠️ 2. Arquitetura de Hardware e I/O (Simulador EdSim51)
O sistema foi validado no simulador EdSim51, utilizando o seguinte mapeamento de periféricos:

P3.5 (T1): Entrada do contador. Recebe os pulsos (eventos) provenientes do motor.

P1.0 - P1.7: Saída para Display de 7 Segmentos (Ânodo Comum). Exibe a contagem de 0 a 9.

P3.0 e P3.1: Saídas para controlo do motor (Ponte-H).

P2.0 (SW0): Entrada digital para a chave de reversão de emergência.

P1.7 (DP): O Ponto Decimal do display é utilizado como indicador visual de sentido de rotação.

⚙️ 3. Lógica do Firmware
3.1 Temporização e Contagem de Eventos
O firmware utiliza o Timer 1 configurado no Modo 2 (Auto-reload de 8 bits).

Os registadores TH1 e TL1 são inicializados com #0FFh.

Desta forma, cada pulso externo em P3.5 provoca um overflow imediato, desviando a execução para o vetor de interrupção em 001Bh.

Esta abordagem desonera a CPU, eliminando a necessidade de polling constante para a contagem de voltas.

3.2 Rotina de Serviço de Interrupção (ISR)
A ISR interromper_timer é responsável por incrementar o registador R0 (variável de processo). Ao atingir 10 voltas, o sistema reinicia o ciclo de dosagem automaticamente.

3.3 Controlo de Fluxo e Reversão
O loop principal monitoriza o estado da chave P2.0. Caso seja detectada uma mudança no sentido de rotação:

O motor é invertido via P3.0 e P3.1.

O sistema executa a sub-rotina zera_e_reseta, que reinicia o contador R0 e prepara o Timer para um novo ciclo de dosagem no novo sentido.

💻 4. Como Simular
Carregue o ficheiro checkfinal.asm no EdSim51.

Configure a frequência de atualização (Update Freq.) para 5 (recomendado para visualização suave da rotação do motor).

Execute o programa (Run).

Observe que o display incrementa a cada volta completa do motor.

Ative o interruptor SW0 para testar a lógica de reversão e o reset imediato da contagem.
