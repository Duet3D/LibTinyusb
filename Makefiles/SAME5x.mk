# LibTinyusb SAME5x Configuration Makefile

SAME5X_BUILD_DIR := SAME5x
SAME5X_TARGET := $(SAME5X_BUILD_DIR)/libLibTinyusb.a

SAME5X_SRC_DIR := src

# Find all C source files, excluding test/lib/hw/tools/examples directories as per Eclipse
SAME5X_C_SRCS := $(shell find $(SAME5X_SRC_DIR)/tinyusb/src -name '*.c' \
	! -path '*/tinyusb/test/*' \
	! -path '*/tinyusb/lib/*' \
	! -path '*/tinyusb/hw/*' \
	! -path '*/tinyusb/tools/*' \
	! -path '*/tinyusb/examples/*')

# Include paths (matching Eclipse .cproject)
SAME5X_INCLUDES := \
	-I$(SAME5X_SRC_DIR)/tinyusb/src \
	-I$(SAME5X_SRC_DIR) \
	-I../CoreN2G/src/atmel/SAME54_DFP/1.1.134/include \
	-I../CoreN2G/src/arm/CMSIS/5.4.0/CMSIS/Core/Include \
	-I../FreeRTOS/src/include \
	-I../FreeRTOS/src/portable/GCC/ARM_CM4F

# Preprocessor defines (from Eclipse .cproject)
SAME5X_DEFINES := \
	-D__SAME54P20A__ \
	-Dnoexcept= \
	-D_ecv_array=

# Compiler flags - C (matching Eclipse)
SAME5X_CFLAGS := -c -std=gnu11 \
	-mcpu=cortex-m4 \
	-mthumb \
	-mfpu=fpv4-sp-d16 \
	-mfloat-abi=hard \
	-mfp16-format=ieee \
	-ffunction-sections \
	-fdata-sections \
	-nostdlib \
	-Wall \
	-Werror \
	-Wundef \
	-Wwrite-strings \
	-Wdouble-promotion \
	-Werror=return-type \
	-fsingle-precision-constant \
	-O2 \
	$(SAME5X_INCLUDES) \
	$(SAME5X_DEFINES)

# Add debug flags if DEBUG=1
ifeq ($(DEBUG),1)
SAME5X_CFLAGS += -O0 -g3
else
SAME5X_CFLAGS += -O2
endif

# Object files
SAME5X_OBJS := $(SAME5X_C_SRCS:%.c=$(SAME5X_BUILD_DIR)/%.o)
SAME5X_DEPS := $(SAME5X_OBJS:.o=.d)

# Target rule
.PHONY: SAME5x
SAME5x: $(SAME5X_TARGET)

$(SAME5X_TARGET): $(SAME5X_OBJS)
	$(Q)echo "  AR      $@"
	$(Q)mkdir -p $(@D)
	$(Q)$(AR) rcs $@ $^

# Compile C files
$(SAME5X_BUILD_DIR)/%.o: %.c
	$(Q)echo "  CC      $<"
	$(Q)mkdir -p $(@D)
	$(Q)$(CC) $(SAME5X_CFLAGS) -MMD -MP -o $@ $<

# Include dependencies
-include $(SAME5X_DEPS)

# Clean target
.PHONY: clean-SAME5x
clean-SAME5x:
	$(Q)echo "  RM      $(SAME5X_BUILD_DIR)"
	$(Q)rm -rf $(SAME5X_BUILD_DIR)
