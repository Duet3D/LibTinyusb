/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2019 Ha Thach (tinyusb.org)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#ifndef _TUSB_CONFIG_H_
#define _TUSB_CONFIG_H_

#ifdef __cplusplus
 extern "C" {
#endif

//--------------------------------------------------------------------
// COMMON CONFIGURATION
//--------------------------------------------------------------------

 /* USB DMA on some MCUs can only access a specific SRAM region with restriction on alignment.
  * Tinyusb use follows macros to declare transferring memory so that they can be put
  * into those specific section.
  * e.g
  * - CFG_TUSB_MEM SECTION : __attribute__ (( section(".usb_ram") ))
  * - CFG_TUSB_MEM_ALIGN   : __attribute__ ((aligned(4)))
  */

#ifndef CFG_TUSB_MCU
# if defined(__SAME54P20A__)
#  define CFG_TUSB_MCU				OPT_MCU_SAME5X
#  define CFG_TUSB_MEM_SECTION		__attribute__((section(".DmaBuffers")))
#  define CFG_TUSB_MEM_ALIGN		__attribute__((aligned(4)))
# elif defined(__SAME70Q20B__)
#  define CFG_TUSB_MCU				OPT_MCU_SAMX7X
#  define CFG_TUSB_MEM_SECTION		__attribute__((section(".ram_nocache")))
#  define CFG_TUSB_MEM_ALIGN		__attribute__((aligned(4)))
# else
# error Unsupported MCU
# endif
#endif

//#define CFG_TUSB_RHPORT0_MODE     (OPT_MODE_DEVICE | OPT_MODE_FULL_SPEED)
#define CFG_TUSB_RHPORT0_MODE     (OPT_MODE_DEVICE)

#ifndef CFG_TUSB_OS
# define CFG_TUSB_OS              OPT_OS_FREERTOS
#endif

// CFG_TUSB_DEBUG is defined by compiler in DEBUG build
#ifndef CFG_TUSB_DEBUG
#define CFG_TUSB_DEBUG           0
#endif

//--------------------------------------------------------------------
// DEVICE CONFIGURATION
//--------------------------------------------------------------------

#ifndef CFG_TUD_ENDPOINT0_SIZE
#define CFG_TUD_ENDPOINT0_SIZE    64
#endif

//------------- CLASS -------------//
#define CFG_TUD_HID              (0)
#define CFG_TUD_CDC              (1)
#define CFG_TUD_MSC              (0)
#define CFG_TUD_MIDI             (0)
#define CFG_TUD_VENDOR           (0)

// CDC FIFO size of TX and RX
#define CFG_TUD_CDC_RX_BUFSIZE   (TUD_OPT_HIGH_SPEED ? 512 : 128)
#define CFG_TUD_CDC_TX_BUFSIZE   (TUD_OPT_HIGH_SPEED ? 512 : 128)

// CDC Endpoint transfer buffer size, more is faster
#define CFG_TUD_CDC_EP_BUFSIZE   (TUD_OPT_HIGH_SPEED ? 512 : 128)

#ifdef __cplusplus
 }
#endif

#endif /* _TUSB_CONFIG_H_ */
