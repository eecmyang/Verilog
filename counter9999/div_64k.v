//----------------------------------------------------------------
// This module divides the incoming clock by 2^16 and outputs the 
// bits 19, 18, and 17
// Filename : div_64K.vhd
//----------------------------------------------------------------

module div_64K(clk,clk_480);
    input clk;
    output [2:0] clk_480;

reg [17:0] count;

always @ (posedge clk)
     count <= count + 1;

assign clk_480 = {count[15], count[14], count[13]};

endmodule
