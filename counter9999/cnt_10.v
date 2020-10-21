//------------------------------------------------------
// This module counts from 0 to 9 and repeatedly.
// Filename : cnt_10.v
//------------------------------------------------------


module cnt_10(ce,clk,clr,tc,qout);
    input ce;
    input clk;
    input clr;
    output tc;
    output [3:0] qout;

reg [3:0] count;

always @(posedge clk or posedge clr)
begin
   if (clr)     //Active-High asynchronous RESET
     count <= 4'b0;
   else
     if (ce)
       if (count==4'h9)
         count <= 4'h0;
       else
         count <= count + 1;
end

assign qout = count;
assign tc = (count==4'h9);

endmodule
