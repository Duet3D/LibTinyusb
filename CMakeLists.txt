# TinyUSB device stack for the Duet3D firmware, built for DUET_MCU, which the consuming project's
# toolchain file sets along with the core's code generation flags.
#
#   DUET_MCU          SAME70 or SAME5x
#   DUET_PART_DEFINE  the macro naming the MCU part, e.g. __SAME70Q20B__
#   DUET_RTOS         build against Duet::FreeRTOS, which must already exist
#
# Target: Duet::LibTinyusb. Needs Duet::CoreN2G for the MCU's device headers. The stack is
# configured by src/tusb_config.h.

cmake_minimum_required(VERSION 3.25)
project(LibTinyusb LANGUAGES C)

if(NOT DUET_MCU MATCHES "^(SAME70|SAME5x)$")
    message(FATAL_ERROR "LibTinyusb: unsupported DUET_MCU '${DUET_MCU}'")
endif()

file(GLOB_RECURSE _srcs CONFIGURE_DEPENDS src/tinyusb/src/*.c)

add_library(LibTinyusb STATIC ${_srcs})
add_library(Duet::LibTinyusb ALIAS LibTinyusb)

target_include_directories(LibTinyusb PUBLIC src/tinyusb/src src)
target_compile_definitions(LibTinyusb PRIVATE ${DUET_PART_DEFINE} noexcept= _ecv_array=)

target_link_libraries(LibTinyusb PRIVATE Duet::CoreN2G)
if(DUET_RTOS)
    target_link_libraries(LibTinyusb PRIVATE Duet::FreeRTOS)
endif()

target_compile_options(LibTinyusb PRIVATE
    $<$<CONFIG:Release>:-O3>
    -fsingle-precision-constant
    -Wall
    -Wundef
    -Wdouble-promotion
    -Werror=return-type
    -Werror=implicit
    -fstack-usage
    -fdump-rtl-expand
    # __FILE__ relative to the library root, so the image does not depend on the checkout location
    -fmacro-prefix-map=${CMAKE_CURRENT_SOURCE_DIR}/=)
