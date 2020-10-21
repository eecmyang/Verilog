//-----------------------
//0-9999 counter 
//Filename: counter.v
//-----------------------
module counter(clk,reset,de_o,led_o);
    input clk;
    input reset;
    output [7:0] de_o;
    output [7:0] led_o;

    wire nreset;
    wire [2:0] led_clk;	  //3 bits to select one of LEDs 
    wire ones_en, tens_en;
    wire huns_en, thas_en;
    wire tc_ones, tc_tens, tc_huns;
    wire [3:0] cnt_1s;	  // counter outputs
    wire [3:0] cnt_10s;
    wire [3:0] cnt_100s;
    wire [3:0] cnt_1000s;
    wire [7:0] led1_out, led10_out;
    wire [7:0] led100_out, led1000_out;
  
div_64K DIV_64K (
                   .clk(clk),
                   .clk_480(led_clk)
                  );
	              
div_16M DIV_16M(
                .clk(clk),
                .tc_1s(ones_en)
               );

cnt_10 ONES(                
            .ce(ones_en),
            .clk(clk),
            .clr(nreset),
            .tc(tc_ones),
            .qout(cnt_1s)
           );
		   
cnt_10 TENS(
            .ce(tens_en),
            .clk(clk),
            .clr(nreset),
            .tc(tc_tens),
            .qout(cnt_10s)
           );

cnt_10 HUND(
            .ce(huns_en),
            .clk(clk),
            .clr(nreset),
            .tc(tc_huns),
            .qout(cnt_100s)
           );

cnt_10 THAU(
            .ce(thas_en),
            .clk(clk),
            .clr(nreset),
            .tc(tc_thas),
            .qout(cnt_1000s)
		  );

		   
hex2led ONES_LED(
                 .hex(cnt_1s),
                 .led(led1_out)
                );

hex2led TENS_LED(
                 .hex(cnt_10s),
                 .led(led10_out)
                );


hex2led HUNS_LED(
                 .hex(cnt_100s),
                 .led(led100_out)
                );


hex2led THAS_LED(
                 .hex(cnt_1000s),
                 .led(led1000_out)
                );
			  

led_dsp DISP_1_1000(
	             .clr(nreset),
			   .data1(led1_out),
			   .data10(led10_out),
			   .data100(led100_out),
			   .data1000(led1000_out),
			   .sel(led_clk),
			   .ledout(led_o),
			   .de(de_o)
			   );

assign tens_en = tc_ones & ones_en;
assign huns_en = tc_tens & tens_en;
assign thas_en = tc_huns & huns_en;
assign nreset  = ~reset;

endmodule
