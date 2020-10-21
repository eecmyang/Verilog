module pwm
(
	input clk,rst,
	
	output wire pwm_out,
	
	output wire [3:0] cntr_main_to_value,
	
	output wire [3:0] value_to_cmp
);


cntr cntr0
(
	.clk(clk),
	.rst(rst),
	.cntr_main(cntr_main_to_value)
);

val value0
(
	.clk(clk),
	.rst(rst),
	.cntr_main(cntr_main_to_value),
	.value(value_to_cmp)
);

cmp comparator0
(
	.cntr(cntr_main_to_value),
	.value(value_to_cmp),
	.pwm_out(pwm_out)
);


endmodule
