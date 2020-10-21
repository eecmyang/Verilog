module odd_even (clk,rst,cntr,data,odd,even,dclk);

	input clk,rst;
	output reg [3:0] cntr,data;
	output reg dclk;
	output wire [3:0] odd,even;

	assign odd=dclk ? 8'hz : data;
	assign even= dclk ? data : 8'hz;

always@(posedge clk)
begin
	if(rst==1'b1)
		begin
			dclk<=1'b0;
		end
	else
		begin
			dclk<=~dclk;
		end
end

always@(posedge clk)
begin
	if(rst==1'b1)
		begin
			cntr<=4'd0;
		end
	else if(cntr==4'd9)
		begin
			cntr<=4'd0;
		end
	else
		begin
			cntr<=cntr+4'd1;
		end
end

always@(cntr)
begin
	case(cntr)
		4'd0:	data<=4'd9;
		4'd1:	data<=4'd8;
		4'd2:	data<=4'd7;
		4'd3:	data<=4'd6;
		4'd4:	data<=4'd5;
		4'd5:	data<=4'd4;
		4'd6:	data<=4'd3;
		4'd7:	data<=4'd2;
		4'd8:	data<=4'd1;
		4'd9:	data<=4'd15;
		default: data<=4'd0;
	endcase
end

endmodule
