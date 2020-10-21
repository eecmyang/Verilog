//-----------------------------------------------------
//Transmit 4 digits to 4-port multiplexer with 8 bits  
//Filename : led_dsp.v
//-----------------------------------------------------
module led_dsp(clr, sel, data1, data10, data100, data1000, de, ledout);

input   clr;
input   [2:0]  sel;
input   [7:0]  data1, data10, data100, data1000;
output  [7:0]	de;
output  [7:0]	ledout;


reg [7:0] de_tem;
reg [7:0] led_tem;
	  

always @(clr or sel or data1 or data10 or data100 or data1000)
begin
 if(clr)
  begin
  led_tem <=  8'b11111111;
  de_tem <=8'b11111111;
  end
 else 
   case(sel)	//Select one of the 6 seven-segment displayer
     3'b000 :
	 begin
	  led_tem <= data1;
	  de_tem <= 8'b1111_1110;
      end
     3'b001 :
	 begin
	  led_tem <= data10;
	  de_tem <= 8'b1111_1101;
      end
     3'b010 :
	 begin
	  led_tem <= data100;
	  de_tem <= 8'b1111_1011;
      end
     3'b011 :
	 begin
	  led_tem <= data1000;
	  de_tem <= 8'b1111_0111;
      end
	3'b100 :
	 begin
	  led_tem <= 8'b11111111;
	  de_tem <= 8'b1110_1111;
      end
	3'b101 :
	 begin
	  led_tem <= 8'b11111111;
	  de_tem <= 8'b1101_1111;
      end
     default:
      begin
	  led_tem <= 8'b11111111;
	  de_tem <= 8'b1111_1111;
      end
    endcase
end

 assign ledout = led_tem;
 assign de = de_tem;

endmodule
