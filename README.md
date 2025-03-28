# MicroCrontoladores
Esse repositório contém os códigos referentes as atividades da disciplina Microcontroladores no curso de Eng de Computação (UFPB)


#  Atividade 1
Tema: Produto de dois números em assembly
Objetivo: Exercícios de familiarização com o conjunto de instruções do PIC.
Especificações:
• Dado dois valores em hexadecimal, armazenados nas variáveis X1 e X2 (1 byte cada), implemente
um programa na linguagem assembly (PIC12F675) para efetuar o produto desses números;
• Como o resultado do produto pode ser um valor maior que FF, considera-se que os resultados devem
ser apresentados em dois bytes (variáveis R1 e R2);
• A variável R2 será utilizada como byte mais significativo e a variável R1 como byte menos significativo;
• Se o resultado do produto for menor ou igual a 00FF, a variável R2 deverá conter zero.

# Atividade 2
Tema: Semáforo de trânsito
Objetivo: Exercício de aplicação da linguagem Assembly, com controle de portas.
Contexto: Implemente um aplicativo em Assembly (PIC12F675) para controlar o semáforo de um
cruzamento simples de rua: fecha para um lado e abre para o outro, utilizando 1 dígito BCD e 1
porta (LEDs).
Especificações:
• Utilize dois LEDs (verde e vermelho) aplicados a uma única porta para funcionar em oposição,
segundo a notação:
• quando a porta é HIGH → LED1 é ON e LED2 é OFF;
• quando a porta é LOW → LED1 é OFF e LED2 é ON;
• A transição de estado (verde → vermelho ou vermelho → verde), ocorrerá após uma contagem
decrescente e cíclica, de 9 até 0;
• Por se tratar de um semáforo didático, cada transição da contagem (indicada no display) deve ocorrer a
cada 500 ms.
• A contagem deve ser indicada em um display de 7 segmentos, utilizando a codificação BCD;
• Para que todos tenham a mesma conectividade, siga a seguinte configuração:
• GP0 → para conectividade dos LEDs (verde/vermelho)
• GP1 → b0 (MENOS significativo) do BCD
• GP2 → b1 do BCD
• GP4 → b2 do BCD
• GP5 → b3 (MAIS significativo) do BCD


# Atividade 3
Tema: Controlador do brilho de um LED
Objetivo: Exercício com comparador.
Contexto: Dimmer para um LED.
Especificações:
• O LED será acionado pela porta GP4;
• O sinal enviado pela porta GP4 será modulado pela largura do pulso, alterando o duty cycle;
• O controle do brilho do LED será, portanto, efetuado pela alteração do duty cycle (de 0 a 100%);
• Após o RESET, o LED deve iniciar apagado;
• A indicação do percentual do duty cycle será dada a partir de uma comparação, em que 3,5V
corresponde a 100%;
• Quando houver duty cycle diferente de 100%, a frequência do sinal deve ser de 500Hz;
• GP1 deverá ser utilizado para a entrada do sinal de tensão a ser comparado.

# Atividade 4
Tema: Controlador do brilho de um LED (segunda parte)
Objetivo: Exercício com conversor A/D.
Contexto: Dimmer para um LED.
Especificações:
• O LED será acionado pela porta GP0;
• O sinal enviado pela porta GP0 será modulado pela largura do pulso, alterando o duty cycle;
• O controle do brilho do LED será, portanto, efetuado pela alteração do duty cycle (de 0 a 100%);
• Após o RESET, o LED deve iniciar apagado;
• A indicação do percentual do duty cycle será dada a partir de uma conversão A/D (8 bits), em que
valores da conversão maiores de 249 corresponde a 100%. Para valores da conversão menores de
250, o duty cycle deverá ser proporcional ao valor da conversão;
• Quando houver duty cycle diferente de 100%, a frequência do sinal deve ser de 500Hz;
• GP4 deverá ser utilizado para efetuar a conversão A/D. 

# Atividade 5
Tema: Controlador de LED RGB
Objetivo: Exercícios para implementação de portas com PWM.
Contexto: Controle da cor e da intensidade do brilho de um LED RGB. Como resultado, o LED pode
fornecer mais de 15 milhões de combinações de cores!
Especificações:
• Após o RESET, os LEDs deverão estar apagados;
• Duas chaves serão utilizadas para selecionar o LED que será ajustado, segundo a tabela:
Chaves Cor do LED:

00 Desligados
01 Red
10 Green
11 Blue

• Um canal será utilizado para conversão A/D. O valor da conversão será utilizado para controlar a
intensidade (duty cycle) do brilho do LED selecionado;
• O percentual do duty cycle será dado a partir de uma conversão A/D (8 bits), em que valores da
conversão maiores de 249 corresponde a 100%. Para valores da conversão menores de 250, o duty
cycle deverá ser proporcional ao valor da conversão (semelhante à atividade 05);
• A intensidade do LED ajustado deverá ser mantida após a alteração da seleção para outro LED;
• Quando houver duty cycle diferente de 100%, a frequência do sinal deve ser de 500Hz;
• GP0, GP1 e GP2 deverão ser utilizados para produzir os sinais PWM, respectivamente, para os LED
R, G e B;
• GP3 e GP5 deverão ser utilizados para efetuar a seleção do LED que será ajustado;
• GP4 deverá ser utilizado efetuar a conversão A/D;

# Atividade 6

Tema: Determinando o valor máximo de um sinal e gravá-lo na EEPROM
Objetivo: Medir o valor máximo de um sinal, gravar este valor na EEPROM e sinalizar sua ocorrência.
Contexto: O sinal mostrado na Figura 1 corresponde ao registro da altitude de um foguete durante seu
lançamento. A duração deste evento é estimada em 60 segundos, a partir do início do acionamento do motor
do foguete. Cinco segundos após o foguete atingir a altura máxima (apogeu) o sistema de paraquedas deve
ser acionado para permitir que o foguete reduza sua velocidade de queda e seja recuperado sem danos. Para
certificar seu desempenho, o valor apogeu deve ser registrado para conferência após a recuperação do
foguete.

Especificações:
• Considere que o altímetro fornece um sinal analógico cuja proporção é linear em relação à altitude,
fornecendo 1 V para cada 100 m e sendo 0 V a altitude correspondente ao nível do solo;

• Considere que o foguete está projetado para que o apogeu não ultrapasse 420 m;

• Considere que, instantes antes do lançamento do foguete, um botão (configurado em pull up) deve ser
pressionado para acionar o início da aquisição de dados;

• Um sistema para aquisição e registro da altitude deve ser implementado utilizando o microcontrolador
PIC12F675, programado em Assembly;

• O botão enviará nível lógico LOW à porta GP0 quando pressionado, indicando que a aquisição deve
ser iniciada;

• O valor do apogeu deve ser armazenado na posição 13h da EEPROM;
• A porta GP1 deve ser utilizada para acionar o paraquedas;

• A porta GP2 deve ser utilizada para conversão A/D em 8 bits;

• A conversão A/D deve ser tão rápido quanto possível (limitada pela velocidade do microcontrolador);
• Cada medida da altura deve corresponder à média aritmética de 32 conversões A/D do sinal
analógico fornecido pelo altímetro;

• Os procedimentos a seguir só devem iniciar após o microcontrolador identificar nível LOW na porta
GP0;

• O procedimento de medição da altitude deve ficar em loop enquanto o altímetro indicar um valor
inferior a 10 m de altura;

• Quando o valor da altura for maior que o equivalente a 10 m de altitude (nível de trigger), um
outro loop de medida de altitude deve ser iniciado e permanecer até que o sistema identifique o
apogeu do foguete;

• Cada novo valor de altitude deve ser comparado para buscar a MAIOR altitude no evento;

• Quando o apogeu for identificado, seu valor deve ser armazenado na EEPROM na posição 13h;

• Após a identificação do apogeu,
um TIMER deve ser inicializado
para acionar o paraquedas 5 s
após o foguete atingir seu apogeu;
• A abertura do paraquedas será
efetuada com um pulso de 2 s de
duração em nível lógico HIGH na
porta GP1;

• Após o pulso de abertura do
paraquedas, o sistema deve
permanecer em loop sem
atividade (FIM GOTO FIM).

![image](https://github.com/user-attachments/assets/ac0a2b83-81b8-445e-95cd-267b2e4cc7fa)


