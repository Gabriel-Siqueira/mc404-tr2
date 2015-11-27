# ----------------------------------------
# Disciplina: MC404 - 1o semestre de 2015
# Professor: Edson Borin
#
# DescriÃ§Ã£o: Makefile para o segundo trabalho 
# ----------------------------------------

# ----------------------------------
# SOUL object files -- Add your SOUL object files here 
SOUL_OBJS=soul_core.o soul_gpio.o soul_gpt.o soul_tzic.o soul_svc.o soul_al_call.o

# ----------------------------------
# Compiling/Assembling/Linking Tools and flags
AS=arm-eabi-as
AS_FLAGS=-g

CC=arm-eabi-gcc
CC_FLAGS=-g

LD=arm-eabi-ld
LD_FLAGS=-g

# ----------------------------------
# Default rule
all: disk.img

# ----------------------------------
# Generic Rules
%.o: %.s
	$(AS) $(AS_FLAGS) $< -o $@

%.o: %.c
	$(CC) $(CC_FLAGS) -c $< -o $@

# ----------------------------------
# Specific Rules
SOUL.x: $(SOUL_OBJS)
	$(LD) $^ -o $@ $(LD_FLAGS) --section-start=.iv=0x778005e0 -Ttext=0x77800700 -Tdata=0x77801800 -e 0x778005e0

LOCO1.x: segue-parede2.o bico.o
	$(LD) $^ -o $@ $(LD_FLAGS) -Ttext=0x77802000

LOCO2.x: ronda2.o bico.o
	$(LD) $^ -o $@ $(LD_FLAGS) -Ttext=0x77802000

# test
LOCO.x: loco.o bico.o
	$(LD) $^ -o $@ $(LD_FLAGS) -Ttext=0x77802000

# Para gerar o disk.img para o outro codigo trocar LOCO(1,2).x
disk.img: SOUL.x LOCO2.x
	mksd.sh --so SOUL.x --user LOCO2.x

clean:
	rm -f SOUL.x LOCO*.x disk.img *.o
