

start:
    ldi r21, 0xC0 ; 0
	ldi r22, 0xF9 ; 1
	ldi r23, 0xA4 ; 2 
	ldi r24, 0xB0 ; 3
	ldi r25, 0x99 ; 4
	ldi r26, 0x92 ; 5
	ldi r27, 0x82 ; 6
	ldi r28, 0xF8 ; 7
	ldi r29, 0x80 ; 8
	ldi r30, 0x90 ; 9


	ldi r16, 0xFF
	sts 0x0024, r16
	nop
	ldi r16, 0x00
	sts 0x0027, r16

bruh:
	sts 0x0025, r21
	lds r17, 0x0026
	com r17
	brne bruh
	jmp reset_1
one:
	sts 0x0025, r22
	lds r17, 0x0026
	com r17
	brne bruh
	jmp reset_2
two:
	sts 0x0025, r23
	lds r17, 0x0026
	com r17
	brne bruh
	jmp reset_3
tre:
	sts 0x0025, r24
	lds r17, 0x0026
	com r17
	brne bruh
	jmp reset_4
for:
	sts 0x0025, r25
	lds r17, 0x0026
	com r17
	brne bruh
	jmp reset_5
five:
	sts 0x0025, r26
	lds r17, 0x0026
	com r17
	brne bruh
	jmp reset_6
six:
	sts 0x0025, r27
	lds r17, 0x0026
	com r17
	brne bruh
	jmp reset_7
seven:
	sts 0x0025, r28
	lds r17, 0x0026
	com r17
	brne back
	jmp reset_8
eit:
	sts 0x0025, r29
	lds r17, 0x0026
	com r17
	brne back
	jmp reset_9
nin:
	sts 0x0025, r30
	lds r17, 0x0026
	com r17
	brne back
	jmp reset_10

back:
	jmp bruh


reset_1:
	ldi r20, 255
loop_1:
	ldi r19, 255
loop1_1:
	ldi r18, 20
loop2_1: 
	dec r18
	brne loop2_1
	dec r19
	brne loop1_1
	dec r20
	brne loop_1
	nop
    jmp one
	
reset_2:
	ldi r20, 255
loop_2:
	ldi r19, 255
loop1_2:
	ldi r18, 20
loop2_2: 
	dec r18
	brne loop2_2
	dec r19
	brne loop1_2
	dec r20
	brne loop_2
	nop
    jmp two

reset_3:
	ldi r20, 255
loop_3:
	ldi r19, 255
loop1_3:
	ldi r18, 20
loop2_3: 
	dec r18
	brne loop2_3
	dec r19
	brne loop1_3
	dec r20
	brne loop_3
	nop
    jmp tre

reset_4:
	ldi r20, 255
loop_4:
	ldi r19, 255
loop1_4:
	ldi r18, 20
loop2_4: 
	dec r18
	brne loop2_4
	dec r19
	brne loop1_4
	dec r20
	brne loop_4
	nop
    jmp for

reset_5:
	ldi r20, 255
loop_5:
	ldi r19, 255
loop1_5:
	ldi r18, 20
loop2_5: 
	dec r18
	brne loop2_5
	dec r19
	brne loop1_5
	dec r20
	brne loop_5
	nop
    jmp five

reset_6:
	ldi r20, 255
loop_6:
	ldi r19, 255
loop1_6:
	ldi r18, 20
loop2_6: 
	dec r18
	brne loop2_6
	dec r19
	brne loop1_6
	dec r20
	brne loop_6
	nop
    jmp six

reset_7:
	ldi r20, 255
loop_7:
	ldi r19, 255
loop1_7:
	ldi r18, 20
loop2_7: 
	dec r18
	brne loop2_7
	dec r19
	brne loop1_7
	dec r20
	brne loop_7
	nop
    jmp seven

reset_8:
	ldi r20, 255
loop_8:
	ldi r19, 255
loop1_8:
	ldi r18, 20
loop2_8: 
	dec r18
	brne loop2_8
	dec r19
	brne loop1_8
	dec r20
	brne loop_8
	nop
    jmp eit

reset_9:
	ldi r20, 255
loop_9:
	ldi r19, 255
loop1_9:
	ldi r18, 20
loop2_9: 
	dec r18
	brne loop2_9
	dec r19
	brne loop1_9
	dec r20
	brne loop_9
	nop
    jmp nin

reset_10:
	ldi r20, 255
loop_10:
	ldi r19, 255
loop1_10:
	ldi r18, 20
loop2_10: 
	dec r18
	brne loop2_10
	dec r19
	brne loop1_10
	dec r20
	brne loop_10
	nop
    jmp back