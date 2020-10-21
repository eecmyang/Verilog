//-----------------------------------------------------------------------
// This module divides the incoming 40 MHz clock by 2^24 and generates a 
// terminal count pulse of one clock width during the counter rollover.
// Filename : div_16M.v
//-----------------------------------------------------------------------

module div_16M(clk,tc_1s);
    input clk;
    output tc_1s;

reg [17:0] count;
reg        tc_1s;

always @ (posedge clk)
begin
     count <= count + 1;
     tc_1s = &count;
end

endmodule
