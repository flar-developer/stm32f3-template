PROJECT = stm32f3-template

STDPERIPH_LIB_SRCS = \
stm32f30x_adc.c \
stm32f30x_can.c \
stm32f30x_comp.c \
stm32f30x_crc.c \
stm32f30x_dac.c \
stm32f30x_dbgmcu.c \
stm32f30x_dma.c \
stm32f30x_exti.c \
stm32f30x_flash.c \
stm32f30x_gpio.c \
stm32f30x_i2c.c \
stm32f30x_iwdg.c \
stm32f30x_misc.c \
stm32f30x_opamp.c \
stm32f30x_pwr.c \
stm32f30x_rcc.c \
stm32f30x_rtc.c \
stm32f30x_spi.c \
stm32f30x_syscfg.c \
stm32f30x_tim.c \
stm32f30x_usart.c \
stm32f30x_wwdg.c


STDPERIPH_DIR = lib/STM32F30x_StdPeriph_Driver/src

SRCS = main.c stm32f3_discovery.c

CPU = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard -march=armv7e-m

CFLAGS = -Wall -nostdlib -fno-common $(CPU) -ffunction-sections -fdata-sections \
        -DUSE_STDPERIPH_DRIVER -DSTM32F30X \
        --std=gnu99
CFLAGS_RELEASE = -O3
CFLAGS_DEBUG = -g -O0

LDFLAGS = -Wl,-Map,map.txt -T stm32_flash.ld $(CPU) -Wl,--gc-sections -nostartfiles
LDFLAGS_RELEASE = -s

INC_DIRS = \
-I lib/CMSIS/Device/ST/STM32F30x/Include \
-I lib/CMSIS/Include \
-I lib/CMSIS/Device/ST/STM32F30x/Source/Templates \
-I lib/STM32F30x_StdPeriph_Driver/inc \
-I lib/Utilities \
-I include

CC  = arm-none-eabi-gcc
GDB = arm-none-eabi-gdb
OBJCOPY = arm-none-eabi-objcopy
OBJDUMP = arm-none-eabi-objdump
SIZE = arm-none-eabi-size

STARTUP = lib/CMSIS/Device/ST/STM32F30x/Source/Templates/TrueSTUDIO/startup_stm32f30x.s \
lib/CMSIS/Device/ST/STM32F30x/Source/Templates/system_stm32f30x.c


OBJS := $(addprefix objs/,$(SRCS:.c=.o))
DEPS := $(addprefix deps/,$(SRCS:.c=.d))
SRCS := $(addprefix src/,$(SRCS))

LIB_OBJS := $(addprefix objs/,$(STDPERIPH_LIB_SRCS:.c=.o))

all: $(PROJECT).bin $(PROJECT).hex

show:
	@echo $(OBJS)
	@echo $(SRCS)

-include $(DEPS)

$(PROJECT).bin: $(PROJECT).elf
	$(OBJCOPY) -O binary $(PROJECT).elf $@

$(PROJECT).hex: $(PROJECT).elf
	$(OBJCOPY) -O ihex $(PROJECT).elf $@

deps:
	mkdir -p deps objs

$(PROJECT).elf: $(OBJS) $(LIB_OBJS)
	$(CC) $(LDFLAGS) $(CFLAGS) $(INC_DIRS) $^ -o $@ $(STARTUP)
	$(OBJDUMP) -St $(PROJECT).elf >$(PROJECT).lst
	$(SIZE) $(PROJECT).elf

objs/%.o : src/%.c deps
	$(CC) $(CFLAGS) $(CFLAGS_DEBUG) $(INC_DIRS) -c $< -o $@ -MMD -MF deps/$(*F).d

objs/%.o : $(STDPERIPH_DIR)/%.c deps
	$(CC) $(CFLAGS) $(CFLAGS_DEBUG) $(INC_DIRS) -c $< -o $@ -MMD -MF deps/$(*F).d

clean:
	find ./ -name '*~' | xargs rm -f
	rm -f objs/*.o
	rm -f deps/*.d
	rm -f dirs
	rm -f map.txt
	rm -f $(PROJECT).elf
	rm -f $(PROJECT).hex
	rm -f $(PROJECT).bin
	rm -f $(PROJECT).map
	rm -f $(PROJECT).lst
