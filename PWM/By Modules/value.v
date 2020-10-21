module val
(
	input clk,rst,
	
	input [3:0] cntr_main,
	
	output reg [3:0] value	
);

always@(posedge clk or posedge rst)
begin
	if(rst==1'b1)
		value<=4'd0;
	else if(cntr_main==4'd15)
		value<=value+4'd1;
	else
		value<=value;
end

endmodule
