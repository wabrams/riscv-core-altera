module clkdiv #(parameter DIVIDER = 2) (input logic clk_in, input logic rst, output logic clk_out);
	logic [31:0] counter;

	always_ff @(posedge clk_in)
		begin
			if (rst ==  1'b1)
				begin
					counter <= 32'b0;
					clk_out  <=  1'b0;
				end
			else if (counter == DIVIDER - 1)
				begin
					counter <= 32'b0;
					clk_out  <= ~clk_out;
				end
			else    
				begin
					counter <= counter + 1'b1;
				end
		end
endmodule