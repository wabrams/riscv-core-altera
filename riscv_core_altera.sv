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

	logic clk, rstz;

	// Instruction memory interface
	logic [31:0] instr_addr;
	logic [31:0] instr_data;
	logic instr_req;
	logic instr_ack;

	// Data memory interface
	logic [31:0] data_addr;
	logic [31:0] data_rd_data;
	logic [31:0] data_wr_data;
	logic [3:0] data_mask;
	logic data_wr_en;
	logic data_req;
	logic data_ack;

	// Interrupt Sources
	logic software_interrupt;
	logic timer_interrupt;
	logic external_interrupt;

	kronos_core #(
		.BOOT_ADDR            (32'h0),
		.FAST_BRANCH          (0    ),
		.EN_COUNTERS          (1    ),
		.EN_COUNTERS64B       (0    ),
		.CATCH_ILLEGAL_INSTR  (1    ),
		.CATCH_MISALIGNED_JMP (1    ),
		.CATCH_MISALIGNED_LDST(1    )
	) u_core (
			.clk               (clk               ),
			.rstz              (rstz              ),
			.instr_addr        (instr_addr        ),
			.instr_data        (instr_data        ),
			.instr_req         (instr_req         ),
			.instr_ack         (instr_ack         ),
			.data_addr         (data_addr         ),
			.data_rd_data      (data_rd_data      ),
			.data_wr_data      (data_wr_data      ),
			.data_mask         (data_mask         ),
			.data_wr_en        (data_wr_en        ),
			.data_req          (data_req          ),
			.data_ack          (data_ack          ),
			.software_interrupt(software_interrupt),
			.timer_interrupt   (timer_interrupt   ),
			.external_interrupt(external_interrupt)
	);

endmodule
