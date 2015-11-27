@=========================================================
@ Codigo responsavel por inicializar o TZIC 
@=========================================================

@ Constantes para os enderecos do TZIC
.set TZIC_BASE,             0x0FFFC000
.set TZIC_INTCTRL,          0x0
.set TZIC_INTSEC1,          0x84 
.set TZIC_ENSET1,           0x104
.set TZIC_PRIOMASK,         0xC
.set TZIC_PRIORITY9,        0x424

@ declara rotulos globais
.global CONFIG_TZIC

.text
.align 4

CONFIG_TZIC:
	
	@ insere em r1 o endereco base para configurar o TZIC
	ldr	r1, =TZIC_BASE

	@ Configura interrupcao 39 do GPT como nao segura
	mov	r0, #(1 << 7)
	str	r0, [r1, #TZIC_INTSEC1]

	@ Habilita interrupcao 39 (GPT)
	mov	r0, #(1 << 7)
	str	r0, [r1, #TZIC_ENSET1]

	@ Configura interrupt39 priority como 1
	ldr r0, [r1, #TZIC_PRIORITY9]
	bic r0, r0, #0xFF000000
	mov r2, #1
	orr r0, r0, r2, lsl #24
	str r0, [r1, #TZIC_PRIORITY9]

	@ Configura PRIOMASK como 0
	eor r0, r0, r0
	str r0, [r1, #TZIC_PRIOMASK]

	@ Habilita o controlador de interrupcoes
	mov	r0, #1
	str	r0, [r1, #TZIC_INTCTRL]

	mov pc, lr


