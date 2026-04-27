# Sistema de Dosagem Rotativa (Baseado em 8051)

**Disciplina:** SEL0433 - Aplicação de Microprocessadores

**Alunos:** 
* Felipe Assis Bernardes Falvo | NUSP: 15004433 
* Thales Vasconcelos Aguiar de Oliveira | NUSP: 15489730 


## 🚀 1. Visão Geral do Projeto 
Este projeto consiste no desenvolvimento de um sistema embarcado para o controle de uma unidade de dosagem rotativa. Assim, utilizando o microcontrolador 8051, o sistema verifica a rotação de um motor DC e conta os ciclos de dosagem limitados a 10 voltas.

## 🛠️ 2. Arquitetura de Hardware e I/O (Simulador EdSim51) 
O sistema foi validado no simulador EdSim51, utilizando o seguinte mapeamento de periféricos:

* **P3.5 (T1):** Entrada do contador. Recebe os pulsos do sensor do motor.
* **P1.0 a P1.7:** Saída para Display de 7 Segmentos (Ânodo Comum), exibindo a contagem de 0 a 9.
* **P1.7 (DP):** Ponto Decimal do display utilizado para indicar o sentido de rotação do motor.
* **P3.0 e P3.1:** Saídas para controle de direção do motor DC.
* **P2.0 (SW0):** Chave de interface para o operador inverter a rotação do motor em caso de travamento na linha.

## ⚙️ 3. Lógica do Firmware 

### 3.1. Temporização e Contagem de Eventos

O firmware utiliza o **Timer 1** configurado no Modo 2. Os registradores `TH1` e `TL1` são inicializados com o valor `#0FFh`, permitindo que cada rotação completa do motor cause um pulso em P3.5, provocando um overflow imediato e desviando a execução para o vetor de interrupção em `001Bh`. Outrossim, dentro da interrupção, uma variável de processo (`R0`) é incrementada e verificada, no qual ao atingir 10 voltas, o contador é automaticamente reiniciado para 0.

### 3.2. Controle de Rotação e Ponto Decimal
O sistema utiliza a variável de referência `F0` para armazenar o sentido de rotação do motor:
* **F0 = 1:** Motor gira no sentido horário (chave SW0 solta).
* **F0 = 0:** Motor gira no sentido anti-horário (chave SW0 pressionada).

Além disso, para indicar a direção no display, a lógica do ponto decimal muda o bit 7 do Acumulador (`ACC.7`) com as instruções `CLR` ou `SETB` *antes* de enviar a informação final para a porta `P1`. Essa ideia foi escolhida ao invés do P1.7, para evitar que o ponto ficasse piscando, garantindo agora que o número e o ponto sejam atualizados ao mesmo tempo.

### 3.3. Controle de Fluxo, Reversão e Reset
O loop principal verifica continuamente o estado da chave `P2.0` (SW0) através da sub-rotina `verificar_sw0`, no qual caso seja detectada uma mudança no sentido de rotação:
1. O motor é invertido alternando as saídas P3.0 e P3.1, através da sub-rotina `inverte_variaveis`.
2. O sistema executa a sub-rotina `zera_e_reseta`, que interrompe o timer, reinicia o contador `R0` e prepara o Timer 1 para um novo ciclo no novo sentido.

Os valores hexadecimais para o acionamento do display de 7 segmentos foram colocados na memória de programa (endereço `0800h`) e são buscados por meio da instrução `MOVC A, @A+DPTR`.

## 💻 4. Como Simular 

1. Carregue o arquivo `checkfinal.asm` no simulador **EdSim51**.
2. Configure a frequência de atualização (**Update Freq.**) para **5** (recomendado para uma visualização suave e fluida da rotação do motor).
3. Execute o programa clicando em **Run**.
4. Observe que o display incrementa a cada volta completa do motor, indo de 0 a 9.
5. **Teste de Reversão:** Com o programa rodando (motor no sentido horário), pressione a chave **SW0** (P2.0). O motor inverterá a rotação, e o ponto decimal acenderá e a contagem será zerada, iniciando um novo ciclo.
