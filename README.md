# 8-bit AVR Softcore Processor on FPGA

This project aims to design, implement in SystemVerilog, and functionally verify a softcore processor compatible with a subset of the 8-bit AVR microcontroller architecture (e.g., ATmega328PB). The target hardware platform is the Digilent Arty S7-50 board with a Spartan-7 FPGA.

## Project Goals
Based on the project requirements (mimicking the AVR architecture):
- 8-bit architecture.
- AVR instruction set (RISC) allowing the execution of programs compiled by, e.g., `avr-gcc`.
- Harvard architecture – separate buses for program memory (Flash/ROM) and data memory (SRAM).
- Memory-Mapped I/O: 32 general-purpose registers (R0-R31), 64 I/O registers, 2 KB SRAM, 32 KB Flash.
- Support for I/O ports physically available on the evaluation board.
- Interrupt support (interrupt pins added).
- Instruction pre-fetching.
- Stack Pointer.

## Technologies Used
- **Hardware Description Language:** SystemVerilog
- **Environment:** Vivado ML Standard 2023.x / 2025.2
- **Target Platform:** Digilent Arty S7-50 (Xilinx XC7S50-CSGA324)

---

## Current Tasks and Working Notes (TODO)

### RAM and ROM Memories (BRAM on FPGA)
Vivado provides ready-to-use BRAM Controller IP modules. Currently, the main goal is to design ROM and RAM modules that will communicate with BRAM.
- **ROM (Program Memory):**
  - 16-bit cells.
  - Synchronous to the clock.
  - Currently: one read port for the Control Unit.
  - Eventually: one write port active only when the processor is halted (e.g., for uploading programs).
- **RAM (Operational Memory):**
  - 8-bit width (according to AVR).
  - Has read and write ports.
  - Fully synchronous (writing occurs only on the clock edge).

### ALU Instructions Implementation Status

**Implemented (6-bit codes in ALU):**
`ADD`, `ADC`, `SUB`, `SBC`, `AND`, `OR`, `EOR`, `INC`, `DEC`, `CLR`, `SER`, `PASS`

**Not yet added to ALU:**
`COM`, `NEG`, `LSR`, `ASR`, `ROR`

**List of target general 16-bit opcodes (decoded in the Control Unit module):**
- *Arithmetic-logic:* `ADD`, `ADC`, `SUB`, `SBC`, `AND`, `OR`, `EOR`, `COM`, `NEG`, `INC`, `DEC`
- *Shifts:* `LSR`, `ASR`, `ROR`
- *Data operations:* `MOV`, `LDI`, `LDS`, `STS`
- *Jumps and branches:* `RJMP`, `JMP`, `BREQ`, `BRNE`, `NOP`
