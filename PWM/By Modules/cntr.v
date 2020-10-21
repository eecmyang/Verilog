module cntr
(
	input clk,rst,
	
	output reg [3:0] cntr_main
);

always@(posedge clk or posedge rst)
begin
	if(rst==1'b1)
		cntr_main<=4'd0;
	else
		cntr_main<=cntr_main+4'd1;
end

endmodule
