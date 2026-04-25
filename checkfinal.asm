; Nome:Felipe Assis Bernardes Falvo
; NUSP:15004433

; Nome: Thales Vasconcelos
; Aguiar de Oliveira
; NUSP: 15489730	

; Recomenda-se o uso do Update
; Freq. em 5 para melhor
; visualização da rotação do motor

org 0000h

; Iniciar o programa já guardando
; a tabela display no DPTR

jmp definir_dptr 

; Endereço fixo de interrupção 
; de overflow do temporizador 1.

org 001Bh 

jmp interromper_timer

; Criando tabela do display (0 a 9)
; seguindo o que foi visto na aula

org 0800h

segmentos:
db 0C0h ; 0
db 0F9h; 1
db 0A4h; 2
db 0B0h; 3
db 99h; 4
db 92h; 5
db 82h; 6
db 0F8h; 7
db 80h; 8
db 90h; 9


org 0100h


; Cada linha do segmento, que
; representa a tabela do display,
; será endereçada no DPTR, e como
; são 10 valores, DPTR (16 bits)

definir_dptr:
    MOV DPTR, #segmentos


inicio:
; Posto o ponteiro da pilha
; em #4Fh, por seguranca
    MOV SP, #4Fh

; No reset/inicialização do EdSim51
; como as portas iniciam nível
; lógico alto (1), para o motor
; girar, basta colocar P3.1
; em 0, ou seja, CLR P3.1, para
; definir o sentido do inicial
; do motor

    CLR P3.1

; Variavel de referência (F0), é
; posta em nivel logico alto

; Para F0 = 1, nota-se que o motor
; gira no sentido horário

; Para F0 = 0, nota-se que o motor
; gira no sentido anti-horário

    SETB F0

; TMOD será explicado da esquerda
; para a direita:

; O primeiro bit seta o GATE em 0,
; configurando o acionamento
; do timer via codigo (TR1)
; por isso do "SETB TR1" para
; começar a contagem

; O segundo bit faz referencia 
; ao C/T, onde setado em 1,
; ele conta os pulsos externos,
; no caso, o sensor do motor

; O terceiro e quarto bit são o
; M1 e M0, no qual eles setam o
; modo como o timer ira atuar,
; no caso modo 2 (10), tem-se o
; auto-reload de 8 bits, fazendo
; os registradores TH1 e TL1 
; assumirem funções diferentes

; TH1 ficará parado, guardando
; um valor de recarga (garantimos
; que ele guarda o FFh para o 
; overflow ocorrer a cada 1 pulso)

; TL1 serve para contar as voltas,
; onde quando TL1 passa de 255
; (8 bits completo), ele recarrega
; automaticamente com o valor
; que estava guardado em TH1

    MOV TMOD, #01100000b
    MOV TH1, #0FFh
    MOV TL1, #0FFh
    SETB TR1

; R0 como variavel de processo 
; para contar as voltas
    MOV R0, #0
  
; Habilita as interrupções do
; Timer 1 (ET1) e a global (EA)
    SETB ET1
    SETB EA


loop:
    ACALL verificar_sw0

; Pegar o valor de R0 e enviar
; para o acumulador, para pegar o
; valor correspondente para colocar
; no display

    MOV A, R0

; O valor correspondente é pego
; na tabela 'segmentos' criada
; anteriormente usando:
; MOVC A, @A+DPTR
; então é enviado para o acumulador

    MOVC A, @A+DPTR

; Lógica do ponto decimal (P1.7):
; Se F0=0, o ponto deve acender

; Colocado o bit 7 do Acumulador
; (ACC.7) para 0 antes de enviar
; para P1, para resolver o problema
; de o ponto ficar piscando

    JB F0, ponto_led
    CLR ACC.7
    SJMP fim_loop

; Se F0=1, o ponto deve apagar

ponto_led:
    SETB ACC.7

fim_loop:
; Envia o valor do acumulador
; para o P1, que representa os 
; 8 bits do display
    MOV P1, A
    SJMP loop

; Interrupção, onde para cada
; volta do motor é somado 1
; ao R0
interromper_timer:
    INC R0

    ; Compara se chegou em 10
    ; Se sim, reinicia o contador

    CJNE R0, #10, continuar_volta
    MOV R0, #0

continuar_volta:
    RETI


; A label inverte_variaveis é
; responsável por inverter a
; direcao do motor e da referência

inverte_variaveis:
    CPL F0
    CPL P3.0
    CPL P3.1

; Ao mudar de sentido, o contador
; é zerado e o timer 
; é reiniciado

zera_e_reseta:
    CLR TR1
    MOV R0, #0
    SETB TR1
    RET

; Essa label verifica a chave P2.0
; onde, caso ela esteja 
; pressionada (P2.0 = 0), pula
; para a label sw0_zero 
; para resolver isso, e se caso
; a chave esteja solta, ou seja,
; P2.0 = 1 e o motor já estiver
; no sentido certo (F0 = 1),
; não acontece nada. Porém, se
; estiver pro lado errado, inverte
; na label inverte_variaveis

verificar_sw0:
    JNB P2.0, sw0_zero
    JB F0, retornar_loop
    ACALL inverte_variaveis
    RET

; Resolve o problema da chave
; pressionada (P2.0 = 0), onde
; se o motor já estiver girando
; no sentido certo para essa
; chave, ou seja, F0 = 0, não
; acontece nada, mas se estiver
; girando pro lado errado, 
; inverte a rotação do motor
; na label inverte_variaveis


sw0_zero:
    JNB F0, retornar_loop
    ACALL inverte_variaveis

; Retorna para a label loop

retornar_loop:
    RET


; EXEMPLO DE FUNCIONAMENTO:

; Primeiramente, tem-se que o timer
; 1 é configurado no modo 2, como
; explicado anteriormente, e atua
; como contador externo através
; do P3.5, que recebe os pulsos do
; motor. Ademais, tem-se que os
; registradores TH1 e TL1 são
; inicializados com o valor #0FFh,
; garantindo que ocorra overflow
; a cada pulso recebido.

; Além do mais, no loop tem-se a
; verificação da chave P2.0, onde
; ao ativada, e consequentemente
; a mudança de sentido do motor,
; a label zera_e_reseta para o
; timer, zera o contador R0,
; e reinicia a contagem.

; Por fim, o display de 7 segmentos
; está relacionado com o valor de
; R0 com a tabela por meio do MOVC.
; Além disso, o F0 agora também
; está controlando o ponto (P1.7),
; onde se o motor gira no sentido
; horário (F0 = 1), o ponto está
; desligado (P1.7 = 1), e caso
; contrário, no sentido anti
; horário (F0 = 0), o ponto está
; ligado (P1.7 = 0). Nota-se que
; cada led liga em nível lógico
; baixo, ou seja, quando está
; em 0.

end