#TODO:
Pamięci RAM i ROM z użyciem BRAM z FPGA. W vivado są gotowe moduły IP BRAM controller, ale nie wiem czy będziemy z tego korzystać.
W każdym razie trzeba się zastanowić jak to zorganizować. Na ten moment postaraj się zrobić jakiś moduł ROM i moduł RAM które będą
się łączyć z tymi kontrolerami BRAM i żeby dało się tam z nimi komunikować. 
ROM ma być pamięcią programu także komórki mają być 16-bitowe i ma mieć jeden port zapisu (ale tylko kiedy proceesor jest zatrzymany) 
i jeden port odczytu z którego będzie korzystał control unit (ale to potem na ten moment 
dodaj tylko jeden port odczytu a będziemy go programować inaczej).
RAM ma mieć porty zapisu i odczytu i on już ma być szerokości 8-bit tak jak w AVR.
No i oby dwie te pamięci mają być synchroniczne czyli zapisywać tylko na zboczu zegara.


Instrukcje  ALU zaimplementowane 6-bitowe:
ADD
ADC
SUB
SBC
AND
OR
EOR
INC
DEC
CLR
SER
PASS
Jeszcze nie dodane do ALU:
COM
NEG
LSR
ASR
ROR

Ogólne 16-bit opcode:
- artmetyczno logiczne
ADD
ADC
SUB
SBC
AND
OR
EOR
COM
NEG
INC
DEC
-przesunięcia
LSR
ASR
ROR
-operacje na danych
MOV
LDI
LDS
STS
-skoki i rozgałęzienia
RJMP
JMP
BREQ
BRNE
NOP
