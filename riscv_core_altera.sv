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


	////////////////////////////////////////////////////////////////
	//// Reset Button
	//////// Reset signal comes from PB3
	////////////////////////////////////////////////////////////////
	logic rst, rstz;
	button PB_RST(KEY[3], rst);
	assign rstz = ~rst;

	////////////////////////////////////////////////////////////////
	//// Clock Management
	//////// Onboard clock is scaled down using PLL, then CLKDIV
	//////// Debug clock comes from manual button presses
	//////// System clock is either from PLL or DBG, based on SW9
	////////////////////////////////////////////////////////////////
	logic pll_clk;
	pll PLL_SYSTEM_CLOCK(CLOCK_50, rst, pll_clk); // PLL resets on a HIGH reset value

	logic div_clk;
	clkdiv #(.DIVIDER (5000000)) CLOCK_DIVIDER(pll_clk, rstz, div_clk);

	logic dbg_clk;
	button PB_CLOCK(KEY[2], dbg_clk);

  // Clock signal
	logic clk;

	logic mux_clk_sel;
	switch SW_MUX_CLOCK(SW[9], mux_clk_sel);

	// TODO: clock gating isn't a great practice, this should only happen if the .vh DEBUG is defined
	always_comb begin : clockMux
		clk = (mux_clk_sel) ? dbg_clk : div_clk;
	end

	////////////////////////////////////////////////////////////////
	//// LED Status Area
	//////// LED8 - reset signal (lit up if system is reset)
	//////// LED9 - clk signal   (to show clock to user)
	////////////////////////////////////////////////////////////////
	assign LEDR[0] = 1'b0;
	assign LEDR[1] = 1'b0;
	assign LEDR[2] = 1'b0;
	assign LEDR[3] = 1'b0;
	assign LEDR[4] = 1'b0;
	assign LEDR[5] = 1'b0;
	assign LEDR[6] = 1'b0;
	assign LEDR[7] = 1'b0;
	assign LEDR[8] =  rst;
	assign LEDR[9] =  clk;

	////////////////////////////////////////////////////////////////
	//// HEX Status Area
	//////// HEX4 - instr_addr & 0x0000003C
	//////// HEX5 - instr_addr & 0x000003C0
	////////////////////////////////////////////////////////////////
	hex HEXDISP5(instr_addr[9:6], HEX5);
	hex HEXDISP4(instr_addr[5:2], HEX4);
	assign HEX3 = ~7'b0;
	assign HEX2 = ~7'b0;
	assign HEX1 = ~7'b0;
	assign HEX0 = ~7'b0;

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
