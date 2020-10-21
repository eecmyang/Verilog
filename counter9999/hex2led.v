//-----------------------
//Seven-segment decoder
//Filename : hex2led.v
//-----------------------
module hex2led(hex,led);
    input [3:0] hex;
    output [7:0] led;

    reg    [7:0] led;

// segment encoding
//      0
//     ---  
//  5 |   | 1
//     ---   <- 6
//  4 |   | 2
//     ---
//      3
 
always @(hex)
begin
   case (hex)
       4'b0001 : led = 8'b11111001;   //1
       4'b0010 : led = 8'b10100100;   //2
       4'b0011 : led = 8'b10110000;   //3
       4'b0100 : led = 8'b10011001;   //4
       4'b0101 : led = 8'b10010010;   //5
       4'b0110 : led = 8'b10000010;   //6
       4'b0111 : led = 8'b11111000;   //7
       4'b1000 : led = 8'b10000000;   //8
       4'b1001 : led = 8'b10010000;   //9
       4'b1010 : led = 8'b10001000;   //A
       4'b1011 : led = 8'b10000011;   //b
       4'b1100 : led = 8'b11000110;   //C
       4'b1101 : led = 8'b10100001;   //d
       4'b1110 : led = 8'b10000110;   //E
       4'b1111 : led = 8'b10001110;   //F
       default : led = 8'b11000000;   //0
    endcase
end

endmodule
