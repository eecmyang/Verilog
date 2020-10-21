module shift
(
	input clk,en,
	input [2:0] number,
	output reg [7:0] shift_out,
	output reg [3:0] state,
	output reg [2:0] cmp_num

);
reg [2:0] cmp_num_prime;

always@(posedge clk)
begin

case(state)
	0:	begin
			cmp_num <= number;
			cmp_num_prime <= number;
			if(en == 1) 
			begin
				shift_out <= 8'b0000_0001;
				state <= 1;
			end
			else
				state <= state;
		end
	1:	begin
			if(cmp_num > 0)
			begin
				cmp_num <= cmp_num - 1;
				shift_out <= shift_out << 1;
				state <= state;
			end
			else if(cmp_num==0 && cmp_num_prime > 0)                                      
			begin
				cmp_num_prime <= cmp_num_prime - 1;
				shift_out <= shift_out >> 1;
				state <= state;
			end
			else
			begin
			shift_out <= 0;
				state <= 2;  
				end
		end
	2:	begin
			cmp_num <= 0;
			cmp_num_prime <= 0;
			state <= 0;
			
		end
	endcase
end
endmodule
