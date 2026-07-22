# LibTinyusb (TinyUSB device stack) as a reusable CMake component.
# See lib/FreeRTOS/FreeRTOS.cmake for the pattern.
#
#   libtinyusb_add_library(TARGET <name> MCU <SAME70|SAME5x> ARCH <interface target>)

set(LIBTINYUSB_DIR "${CMAKE_CURRENT_LIST_DIR}")
set(LIBTINYUSB_LIBRARY_FLAGS)
set(LIBTINYUSB_LIBRARY_ARGS
    "COREN2G_INTERFACE"          # interface target for CoreN2G, if USB is enabled
    "FREERTOS_INTERFACE"        # interface target for FreeRTOS
)

include("${LIBRARIES_DIR}/LibraryUtils.cmake")

function(libtinyusb_add_interface OUT_TARGET)
    cmake_parse_arguments(PARSE_ARGV 1 ARG "${LIBTINYUSB_LIBRARY_FLAGS}" "${DEFAULT_INTERFACE_ARGS}" "")
    if(ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "libtinyusb_add_interface: unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")
    endif()

    get_enabled_features(_enabled_features)
    make_library_name(_target "LibTinyusb" INTERFACE ${ARG_MCU} ${_enabled_features})
    set(${OUT_TARGET} "${_target}" PARENT_SCOPE)
    if(TARGET ${_target})
        return()  # already built for this MCU and feature set
    endif()

    add_library(${_target} INTERFACE)
    target_include_directories(${_target} INTERFACE
        "${LIBTINYUSB_DIR}/src/tinyusb/src"
        "${LIBTINYUSB_DIR}/src"
    )
endfunction()

function(libtinyusb_add_library OUT_TARGET)
    cmake_parse_arguments(PARSE_ARGV 1 ARG "${LIBTINYUSB_LIBRARY_FLAGS}" "${DEFAULT_LIBRARY_ARGS};${LIBTINYUSB_LIBRARY_ARGS}" "")
    if(ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "libtinyusb_add_library: unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")
    endif()

    get_enabled_features(_enabled_features)
    make_library_name(_target "LibTinyusb" STATIC ${ARG_MCU} ${_enabled_features})
    set(${OUT_TARGET} "${_target}" PARENT_SCOPE)
    if(TARGET ${_target})
        return()  # already built for this MCU and feature set
    endif()

    set(_src "${LIBTINYUSB_DIR}/src")

    if(ARG_MCU STREQUAL "SAME70")
    else()
        message(FATAL_ERROR "libtinyusb_add_library: unsupported MCU '${ARG_MCU}' (only SAME70 is wired up so far)")
    endif()

    file(GLOB_RECURSE _srcs CONFIGURE_DEPENDS "${_src}/tinyusb/src/*.c")
    foreach(_ex IN ITEMS "/tinyusb/test/" "/tinyusb/lib/" "/tinyusb/hw/" "/tinyusb/tools/" "/tinyusb/examples/")
        list(FILTER _srcs EXCLUDE REGEX "${_ex}")
    endforeach()

    add_library(${_target} STATIC ${_srcs})

    target_link_libraries(${_target} PUBLIC I_${_target}) # link own interface target
    target_link_libraries(${_target} PRIVATE
        ${ARG_COREN2G_INTERFACE}
        ${ARG_FREERTOS_INTERFACE}
    ) # link library dependencies

    target_include_directories(${_target} PRIVATE
        # "${_src}/tinyusb/src"
        # "${_src}"
        # ${_cmsis_inc}
        # "${_core}/arm/CMSIS/5.4.0/CMSIS/Core/Include"
        # "${_freertos}/include"
        # "${_freertos}/${_freertos_port}"
    )

    target_compile_definitions(${_target} PRIVATE ${_part_define} noexcept= _ecv_array=)

    target_compile_options(${_target} PRIVATE
        -ffunction-sections
        -fdata-sections
        -nostdlib
        -Wall
        -Wundef
        -Wdouble-promotion
        -Werror=return-type
        -Werror=implicit
        -fsingle-precision-constant
        $<$<NOT:$<CONFIG:Debug>>:-O3>
        $<$<CONFIG:Debug>:-O0;-g3>)

    target_link_libraries(${_target} PRIVATE ${ARG_ARCH})
endfunction()
