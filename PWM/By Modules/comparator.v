module cmp
(
	input [3:0] cntr,value,
	
	output reg pwm_out
);

always@(cntr or value)
begin
	if(cntr>=value)
		pwm_out<=1'b0;
	else
		pwm_out<=1'b1;
end

endmodule
