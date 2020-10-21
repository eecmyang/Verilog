module sap
(
	input clk,clr,
	output reg LDA,ADD,SUB,OUT,
	output reg [3:0] pcout,marout,opcode,operandtemp,
	output reg [5:0] T,
	output reg [7:0] data1,acc,breg,
	output reg [11:0] con,
	output wire [7:0] wbus
	
);

	assign wbus = con[10] ? ({4'bz,pcout}) : (con[8] ? (con[6] ? (con[2] ? (con[3] ? acc-breg : acc+breg): 8'bz) : operandtemp) : data1);  //Tri-state W-Bus ctrl,in other words,MUX combined.




always@(negedge clk or negedge clr)		//Ring counter,Generating addresses.
begin
	if(!clr)
		T=6'b000_001;
	else
		T={T[4:0],T[5]};
end

always@(T or LDA or ADD or SUB or OUT)		//Combinational contorlling array.
begin
	con[11]= T[1];													//Cp
	con[10]= T[0];													//Ep
	con[9] =~((LDA&T[3])|(ADD&T[3])|(SUB&T[3])|T[0]);	//Lm
	con[8] =~((LDA&T[4])|(ADD&T[4])|(SUB&T[4])|T[2]);	//Ce
	con[7] =~T[2];													//Li
	con[6] =~((LDA&T[3])|(ADD&T[3])|(SUB&T[3]));			//Ei
	con[5] =~((LDA&T[4])|(ADD&T[5])|(SUB&T[5]));			//La
	con[4] =(OUT&T[3]);											//Ea
	con[3] =(SUB&T[5]);											//Su
	con[2] =((ADD&T[5])|(SUB&T[5]));							//Eu
	con[1] =~((ADD&T[4])|(SUB&T[4]));						//Lb
	con[0] =(OUT&T[3]);											//Lo
end

always@(negedge clk or negedge clr)		//Program counter.
begin
	if(!clr)
		pcout=4'd0;
	else if(con[11]==1'b1)
		pcout=pcout+4'd1;
	else
		pcout=pcout;
end

always@(negedge clk or negedge clr)		//MAR counter.
begin
	if(!clr)
		marout=4'd0;
	else if(con[9]==1'b0)
		marout=wbus[3:0];
	else
		marout=marout;
end

always@(marout)		//MAR ROM.
begin
	case(marout)
		4'd0 	: data1 = 8'h09 ;
		4'd1 	: data1 = 8'h1a ;
		4'd2 	: data1 = 8'h1b ;
		4'd3 	: data1 = 8'h2c ;
		4'd4 	: data1 = 8'he0 ;
		4'd5 	: data1 = 8'hf0 ;
		4'd6 	: data1 = 8'hf0 ;
		4'd7 	: data1 = 8'h00 ;
		4'd8 	: data1 = 8'h00 ;
		4'd9 	: data1 = 8'h10 ;
		4'd10 : data1 = 8'h14 ;
		4'd11 : data1 = 8'h18 ;
		4'd12 : data1 = 8'h20 ;
		4'd13 : data1 = 8'h00 ;
		4'd14 : data1 = 8'h00 ;
		4'd15 : data1 = 8'h00 ;
		default : data1 = 8'h00 ;
	endcase
end

always@(posedge clk or negedge clr)		//Instruction Register. 
begin
	if(!clr)
		opcode=4'd0;
	else if(con[7]==0)
		opcode=wbus[7:4];
	else
		opcode=opcode;
end

always@(posedge clk or negedge clr)			//Instruction Register con'd.
begin
	if(!clr)
		operandtemp=4'd0;
	else
		if(con[7]==1'b0)
			operandtemp=wbus[3:0];
end

always@(opcode)		// Instruction Register Decoder.
begin
	case(opcode)
		4'd0		:	begin LDA=1;ADD=0;SUB=0;OUT=0;end
		4'd1		:	begin LDA=0;ADD=1;SUB=0;OUT=0;end
		4'd2		:	begin LDA=0;ADD=0;SUB=1;OUT=0;end
		4'd14		:	begin LDA=0;ADD=0;SUB=0;OUT=1;end
		default	:	begin LDA=0;ADD=0;SUB=0;OUT=0;end
	endcase
end

always@(posedge clk)		//ACC.
begin
	if(!clr)
		acc=8'd0;
	else
		if(con[5]==1'b0)
			acc=wbus;
end

always@(posedge clk)		//Reg B.
begin
	if(!clr)
		breg=8'd0;
	else
		if(con[1]==1'b0)
			breg=wbus;
end



endmodule

