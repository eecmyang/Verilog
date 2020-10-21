module pwm
(
	input clk,rst,
	
	output reg [3:0] cntr,value,
	
	output reg pwm_out
);

always@(posedge clk or posedge rst)
begin
	if(rst==1'b1)
		begin
			cntr<=4'd0;
			value<=4'd0;
		end
	else if(cntr==4'd15)
		begin
			cntr<=4'd0;
			value<=value+4'd1;
		end
	else
		begin
			cntr<=cntr+4'd1;
			value<=value;
		end
end

always@(cntr or value)
begin
	if(cntr>=value)
		pwm_out<=1'b0;
	else
		pwm_out<=1'b1;
end

endmodule
