module shunt
(
	input clk,rst,		//Clock,Reset
	
	output reg dclk,	//Divide 2 clock
	
	output reg  [3:0] cntr,	//4bits counter for reading data from ROM
	
	output reg  [7:0] data,	//Input data
	
	output reg  [7:0] D1o,D2o,D3o,D4o,	//Upper row of circuits
	
	output reg  [7:0] LD1o,LD2o,LD3o,LD4o,LD5o,	//Bottom row of circuits
	
	output wire [7:0] Sub1,Sub2,Add1,Add2,	//Operations in between registers	
	
	output wire [7:0] odd,even //Data split
);

	assign odd  = dclk ? 8'hz : data;
	assign even = dclk ? data : 8'hz;
	
	assign Sub1 = even - D1o;
	assign Sub2 = D3o  - D1o;
	
	assign Add1 = (D4o>>2) + LD2o;
	assign Add2 = (D4o>>2) + LD4o;


always@(posedge clk)		//Divide 2 clock
begin
	if(rst==1'b1)
		begin
			dclk<=1'b0;
		end
	else
		begin
			dclk<=~dclk;
		end
end

always@(posedge clk)	  //Data counter
begin
	if(rst==1'b1)
		begin
			cntr<=4'd0;
		end
	else if(cntr==4'd8)
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
		4'd0: data<=8'd10;
		4'd1: data<=8'd40;
		4'd2: data<=8'd20;
		4'd3: data<=8'd50;
		4'd4: data<=8'd30;
		4'd5: data<=8'd60;
		4'd6: data<=8'd28;
		4'd7: data<=8'd46;
		4'd8: data<=8'd18;
		default: begin end
	endcase
end

always@(posedge clk)
begin
	begin
		if(rst==1'b1)		//Uppder-half of circuits
		begin
			D1o<=8'd0;
			D2o<=8'd0;
			D3o<=8'd0;
			D4o<=8'd0;
			
		end
	else
		begin
			D1o<=(data>>1);
			D2o<=Sub1;
			D3o<=D2o;
			D4o<=Sub2;
		
		end
	end
	
	begin
		if(rst==1'b1)		//Bottom-half of circuits
			begin
				LD1o<=8'd0;
				LD2o<=8'd0;
				LD3o<=8'd0;
				LD4o<=8'd0;
				LD5o<=8'd0;
			end
		else
			begin
				LD1o<=data;
				LD2o<=LD1o;
				LD3o<=Add1;
				LD4o<=LD3o;
				LD5o<=Add2;
			end
	end
end


endmodule
