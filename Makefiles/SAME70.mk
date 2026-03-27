# LibTinyusb SAME70 Configuration Makefile

SAME70_BUILD_DIR := SAME70
SAME70_TARGET := $(SAME70_BUILD_DIR)/libLibTinyusb.a

SAME70_SRC_DIR := src

# Find all C source files, excluding test/lib/hw/tools/examples directories as per Eclipse
SAME70_C_SRCS := $(shell find $(SAME70_SRC_DIR)/tinyusb/src -name '*.c' \
	! -path '*/tinyusb/test/*' \
	! -path '*/tinyusb/lib/*' \
	! -path '*/tinyusb/hw/*' \
	! -path '*/tinyusb/tools/*' \
	! -path '*/tinyusb/examples/*')

# Include paths (matching Eclipse .cproject)
SAME70_INCLUDES := \
	-I$(SAME70_SRC_DIR)/tinyusb/src \
	-I$(SAME70_SRC_DIR) \
	-I../CoreN2G/src/SAM4S_4E_E70/asf/sam/utils/cmsis/same70/include \
	-I../CoreN2G/src/SAM4S_4E_E70/SAME70 \
	-I../CoreN2G/src/arm/CMSIS/5.4.0/CMSIS/Core/Include \
	-I../FreeRTOS/src/include \
	-I../FreeRTOS/src/portable/GCC/ARM_CM7/r0p1

# Preprocessor defines (from Eclipse .cproject)
SAME70_DEFINES := \
	-D__SAME70Q20B__ \
	-Dnoexcept= \
	-D_ecv_array=

# Compiler flags - C (matching Eclipse, corrected to Cortex-M7)
SAME70_CFLAGS := -c \
	-mcpu=cortex-m7 \
	-mthumb \
	-mfpu=fpv5-d16 \
	-mfloat-abi=hard \
	-mfp16-format=ieee \
	-mno-unaligned-access \
	-ffunction-sections \
	-fdata-sections \
	-nostdlib \
	-Wundef \
	-Wdouble-promotion \
	-Werror=return-type \
	-Werror=implicit \
	-fsingle-precision-constant \
	-fstack-usage \
	-fdump-rtl-expand \
	-O3 \
	-Wall \
	$(SAME70_INCLUDES) \
	$(SAME70_DEFINES)

# Add debug flags if DEBUG=1
ifeq ($(DEBUG),1)
SAME70_CFLAGS += -O0 -g3
endif

# Object files
SAME70_OBJS := $(SAME70_C_SRCS:%.c=$(SAME70_BUILD_DIR)/%.o)
SAME70_DEPS := $(SAME70_OBJS:.o=.d)

# Target rule
.PHONY: SAME70
SAME70: $(SAME70_TARGET)

$(SAME70_TARGET): $(SAME70_OBJS)
	$(Q)echo "  AR      $@"
	$(Q)mkdir -p $(@D)
	$(Q)$(AR) rcs $@ $^

# Compile C files
$(SAME70_BUILD_DIR)/%.o: %.c
	$(Q)echo "  CC      $<"
	$(Q)mkdir -p $(@D)
	$(Q)$(CC) $(SAME70_CFLAGS) -MMD -MP -o $@ $<

# Include dependencies
-include $(SAME70_DEPS)

# Clean target
.PHONY: clean-SAME70
clean-SAME70:
	$(Q)echo "  RM      $(SAME70_BUILD_DIR)"
	$(Q)rm -rf $(SAME70_BUILD_DIR)
