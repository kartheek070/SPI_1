# SPI_1
## SPI Master–Slave (Mode-0) in Verilog<br><br>

This project implements a custom SPI Master and SPI Slave in Verilog (SPI Mode-0). The objective was to transmit `0xA5` from the master and receive `0xCC` from the slave.<br><br>

### Current Status<br><br>

* Slave correctly receives `0xA5`.<br>
* Master currently receives `0x66` instead of `0xCC`.<br>
* The mismatch is deterministic and not random noise.<br><br>

### Debug Insight<br><br>

`0xCC = 1100_1100`<br>
`0x66 = 0110_0110`<br><br>

The received value is a 1-bit right shift of the expected data. This indicates a half-cycle phase misalignment in MISO sampling.<br><br>

In SPI Mode-0:<br>

* Slave updates MISO on the falling edge of SCLK.<br>
* Master must sample MISO on the rising edge of SCLK.<br><br>

The current behavior suggests the master samples one clock late, resulting in a consistent bit slip.<br><br>

### Key Learnings<br><br>

* SPI debugging is primarily about precise edge alignment.<br>
* Deterministic bit shifts often indicate phase errors, not logic corruption.<br>
* Proper ownership of clock domains is critical in serial protocols.<br><br>

### Status<br><br>

The slave implementation is stable and protocol-correct.<br>
Master sampling phase is under refinement to eliminate the half-cycle offset.<br><br>

Suggestions and feedback are welcome.<br>
