module riscv_core_altera
(
	// SYS Clocks
	input CLOCK_50, input CLOCK2_50, input CLOCK3_50, input CLOCK4_50, 
	// User I/O
	input  [3:0]  KEY, input  [9:0]	 SW, output [9:0] LEDR,
	// 7SEG Displays
	output [6:0] HEX0, output [6:0] HEX1, output [6:0] HEX2, output [6:0] HEX3, output [6:0] HEX4, output [6:0] HEX5,
	// VGA Display
	output VGA_CLK,
	output VGA_HS,
	output VGA_VS,
	output VGA_BLANK_N,
	output VGA_SYNC_N,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B,
  // PS2 Keyboard
	inout PS2_CLK, inout PS2_CLK2, inout PS2_DAT, inout PS2_DAT2,
	// DRAM Memory
	output [12:0] DRAM_ADDR, output [1:0] DRAM_BA, output DRAM_CAS_N,
	output DRAM_CKE, output DRAM_CLK, output DRAM_CS_N, inout [15:0] DRAM_DQ,
	output DRAM_LDQM, output DRAM_RAS_N, output DRAM_UDQM, output DRAM_WE_N
);



endmodule
