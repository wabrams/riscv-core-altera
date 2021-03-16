// Copyright (c) 2020 Sonal Pinto
// SPDX-License-Identifier: Apache-2.0

/*
Kronos ALU

The ALU takes two operands OP1 and OP2 to generate a RESULT,
as per the ALUOP

Functions
  ADD     : r[0] = op1 + op2
  SUB     : r[0] = op1 - op2
  AND     : r[1] = op1 & op2
  OR      : r[2] = op1 | op2
  XOR     : r[3] = op1 ^ op2
  LT      : r[4] = op1 < op2
  LTU     : r[4] = op1 <u op2
  SHL     : r[5] = op1 << op2[4:0]
  SHR     : r[5] = op1 >> op2[4:0]
  SHRA    : r[5] = op1 >>> op2[4:0]

Where r[0-5] are the intermediate results of these major functions
  0: ADDER
  1: AND
  2: OR
  3: XOR
  4: COMPARATOR
  5: BARREL SHIFTER
*/

module kronos_alu
  import kronos_types::*;
(
  input  logic [31:0] op1,
  input  logic [31:0] op2,
  input  logic [3:0]  aluop,
  output logic [31:0] result
);

logic cin, rev, uns;

logic [31:0] r_adder, r_and, r_or, r_xor, r_shift;

logic [31:0] adder_A, adder_B;
logic cout;

logic A_sign, B_sign, R_sign;
logic r_lt, r_ltu, r_comp;

logic [31:0] data;
logic [4:0] shamt;
logic shift_in;
logic [31:0] p0, p1, p2, p3, p4;

// ============================================================
//  Operation Decode
assign cin = aluop[3] || aluop[1];
assign rev = ~aluop[2];
assign uns = aluop[0];

// ============================================================
// Operation Execution

// ADDER
always_comb begin
  // OP2 can be negated for subtraction
  adder_A = op1;
  adder_B = cin ? ~op2 : op2;

  // Add Operation
  /* verilator lint_off WIDTH */
  {cout, r_adder} = {1'b0, adder_A} + {1'b0, adder_B} + cin;
  /* verilator lint_on WIDTH */
end

// LOGIC
always_comb begin
  r_and = op1 & op2;
  r_or  = op1 | op2;
  r_xor = op1 ^ op2;
end

// COMPARATOR
always_comb begin
  // Use adder to subtract operands: op1(A) - op2(B), 
  //  and obtain the sign of the result
  A_sign = op1[31];
  B_sign = op2[31];
  R_sign = r_adder[31];

  // Signed Less Than (LT)
  // 
  // If the operands have the same sign, we use r_sign
  // The result is negative if op1<op2
  // Subtraction of two positive or two negative signed integers (2's complement)
  //  will _never_ overflow
  case({A_sign, B_sign})
    2'b00: r_lt = R_sign; // Check subtraction result
    2'b01: r_lt = 1'b0;   // op1 is positive, and op2 is negative
    2'b10: r_lt = 1'b1;   // op1 is negative, and op2 is positive
    2'b11: r_lt = R_sign; // Check subtraction result
  endcase

  // Unsigned Less Than (LTU)
  // Check the carry out on op1-op2
  r_ltu = ~cout;

  // Aggregate comparator results as per ALUOP
  r_comp = (uns) ? r_ltu : r_lt;
end

// BARREL SHIFTER
always_comb begin
  // Reverse data to the shifter for SHL operations
  //// TODO: Quartus does not support SystemVerilog stream operators
  //// original code was: data = rev ? {<<{op1}} : op1;
  data = rev ? {op1[00], op1[01], op1[02], op1[03] ,op1[04], op1[05], op1[06], op1[07],
    op1[08], op1[09], op1[10], op1[11], op1[12], op1[13], op1[14], op1[15], 
    op1[16], op1[17], op1[18], op1[19], op1[20], op1[21], op1[22], op1[23], 
    op1[24], op1[25], op1[26], op1[27], op1[28], op1[29], op1[30], op1[31], } 
    : op1;
  shift_in = cin & op1[31];
  shamt = op2[4:0];

  // The barrel shifter is formed by a 5-level fixed RIGHT-shifter
  // that pipes in the value of the last stage

  p0 = shamt[0] ? {    shift_in  , data[31:1]} : data;
  p1 = shamt[1] ? {{ 2{shift_in}}, p0[31:2]}   : p0;
  p2 = shamt[2] ? {{ 4{shift_in}}, p1[31:4]}   : p1;
  p3 = shamt[3] ? {{ 8{shift_in}}, p2[31:8]}   : p2;
  p4 = shamt[4] ? {{16{shift_in}}, p3[31:16]}  : p3;

  // Reverse last to get SHL result
  //// TODO: Quartus does not support SystemVerilog stream operators
  //// original code was: r_shift = rev ? {<<{p4}} : p4;
  r_shift = rev ? {p4[00], p4[01], p4[02], p4[03] ,p4[04], p4[05], p4[06], p4[07],
    p4[08], p4[09], p4[10], p4[11], p4[12], p4[13], p4[14], p4[15], 
    p4[16], p4[17], p4[18], p4[19], p4[20], p4[21], p4[22], p4[23], 
    p4[24], p4[25], p4[26], p4[27], p4[28], p4[29], p4[30], p4[31], } 
    : op1;
end

// ============================================================
// Result Mux
always_comb begin
  unique case(aluop)
    SLT,
    SLTU        : result = {31'b0, r_comp};
    XOR         : result = r_xor;
    OR          : result = r_or;
    AND         : result = r_and;
    SLL,
    SRL,
    SRA         : result = r_shift;
    default     : result = r_adder; // ADD, SUB
  endcase
end

endmodule
