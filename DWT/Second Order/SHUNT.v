module SHUNT
(
	input clk,rst,		//Clock,Reset
	
	output reg sel,seL2even,seL2odd,	//Divide 2 clock
	
	output reg  [3:0] cntr,	//4bits counter for reading data from ROM
	
	output reg 	[1:0] cntr2,
	
	output reg  [7:0] data,	//Input data
	
	output reg  [7:0] D1o,D2o,D3o,D4o,	//Upper row of circuits

	output reg  [7:0] LD1o,LD2o,LD3o,LD4o,LD5o,	//Bottom row of circuits
	
	output reg 	[7:0] LR1,LR2,
	
	output wire [7:0] Sub1,Sub2,Add1,Add2,	//Operations in between registers	
	
	output wire [7:0] odd,even //Data split
);

//*******************************************************//
	
	//Combined 1st&2nd ode ODD circuit 4 to 1 MUX
	assign odd  = sel ? (seL2odd ? LR2 : 8'hz) : data;
	
	//Combined 1st&2nd ode EVEN circuit 4 to 1 MUX
	assign even = sel ? data : (seL2even ? LR1: 8'hz);  	
	
	assign Sub1 = even - D1o;
	assign Sub2 = D3o  - D1o;
	
	assign Add1 = (D4o>>2) + LD2o;
	assign Add2 = (D4o>>2) + LD4o;
	
//*******************************************************//


always@(posedge clk)		//Divide 2 clock
begin
	if(rst==1'b1)
		begin
			sel<=1'b0;
		end
	else
		begin
			sel<=~sel;
		end
end

always@(posedge clk)
begin
	if(rst==1'b1)
		begin
			cntr2<=2'd0;
		end
	else if((cntr2 >= 2'd0) && (cntr2 < 2'd1))
		begin
			seL2odd<=~seL2odd;
			seL2even<=1'b0;
			cntr2<=cntr2+2'd1;
		end
	else if((cntr2 >= 2'd1) && (cntr2 < 2'd2))
		begin
			seL2odd<=1'b0;
			seL2even<=~seL2even;
			cntr2<=cntr2+2'd1;
		end
	else
		begin
			cntr2<=cntr2+2'd1;
			seL2odd<=seL2odd;
			seL2even<=1'b0;
		end
end

always@(posedge clk)	  //Data counter
begin
	if(rst==1'b1)
		begin
			cntr<=4'd0;
		end
	else
		begin
			cntr<=cntr+4'd1;
		end
end

always@(cntr)		//ROM
begin
	case(cntr)
		4'd0	 : begin data<=8'd10; end
		4'd1	 : begin data<=8'd40; end
		4'd2	 : begin data<=8'd20; end
		4'd3	 : begin data<=8'd50; end
		4'd4	 : begin data<=8'd30; end
		4'd5	 : begin data<=8'd60; end
		4'd6	 : begin data<=8'd28; end
		4'd7	 : begin data<=8'd46; end
		4'd8	 : begin data<=8'd18; end
		4'd9	 : begin data<=8'd20; end
		4'd10	 : begin data<=8'd12; end
		4'd11	 : begin data<=8'd34; end 
		4'd12	 : begin data<=8'd10; end
		4'd13	 : begin data<=8'd16; end
		4'd14	 : begin data<=8'd08; end 
		4'd15	 : begin data<=8'd00; end 
		default: begin data<=8'd00; end 
	endcase
end

always@(posedge clk)
begin
	begin
		if(rst==1'b1)		//First order circuit
		begin
			begin
				D1o<=8'd0;
				D2o<=8'd0;
				D3o<=8'd0;
				D4o<=8'd0;
			end
			begin
				LD1o<=8'd0;
				LD2o<=8'd0;
				LD3o<=8'd0;
				LD4o<=8'd0;
				LD5o<=8'd0;
			end
		end
	else
		begin
			begin
				D1o<=odd>>1;
				D2o<=Sub1;
				D3o<=D2o;
				D4o<=Sub2;
			end
			begin
				LD1o<=data;
				LD2o<=LD1o;
				LD3o<=Add1;
				LD4o<=LD3o;
				LD5o<=Add2;
			end
		end
	end
	
	begin
		if(rst==1'b1)		//Second order circuit
			begin
				LR1<=8'd0;
				LR2<=8'd0;
			end
		else
			begin
				LR1<=LD5o;
				LR2<=LR1;
			end
	end
	
end


endmodule
