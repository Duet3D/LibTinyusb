# LibTinyusb Master Makefile
# Builds TinyUSB library for various MCU configurations

# Cross-compiler toolchain.
# RepRapFirmware exports CROSS_COMPILE when building this as a submodule.
# When building LibTinyusb standalone, fall back to a toolchain on PATH.
CROSS_COMPILE ?= arm-none-eabi-
export CROSS_COMPILE

# Toolchain commands
CC = $(CROSS_COMPILE)gcc
CXX = $(CROSS_COMPILE)g++
AS = $(CROSS_COMPILE)gcc
AR = $(CROSS_COMPILE)ar

# Quiet build support (Linux kernel style)
# Use V=1 for verbose output
ifeq ($(V),1)
	Q :=
else
	Q := @
endif
export Q

# Available build configurations
CONFIGS := SAME5x SAME70

# Default target
.DEFAULT_GOAL := SAME5x

# Print available targets
.PHONY: help
help:
	@echo "LibTinyusb Build System"
	@echo "Available targets:"
	@for config in $(CONFIGS); do echo "  make $$config"; done
	@echo ""
	@echo "Other targets:"
	@echo "  make all          - Build all configurations"
	@echo "  make clean        - Clean all build outputs"
	@echo "  make clean-<config> - Clean specific configuration"
	@echo ""
	@echo "Environment variables:"
	@echo "  ArmGccPath=$(ArmGccPath)"

# Build all configurations
.PHONY: all
all:
	$(Q)$(MAKE) SAME5x
	$(Q)$(MAKE) SAME70

# Include configuration-specific makefiles only when building that specific config
ifeq ($(MAKECMDGOALS),SAME5x)
-include Makefiles/SAME5x.mk
endif
ifeq ($(MAKECMDGOALS),SAME70)
-include Makefiles/SAME70.mk
endif

# Generic clean target
.PHONY: clean
clean:
	@echo "Cleaning all LibTinyusb build outputs..."
	@for config in $(CONFIGS); do \
		if [ -d "$$config" ]; then \
			echo "  Cleaning $$config..."; \
			rm -rf "$$config"; \
		fi; \
	done
