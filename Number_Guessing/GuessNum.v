module Guess_Num (clk,keyin,keyout,segs_out,scan);
	input clk;
	
	input [3:0] keyin;
	output reg [3:0] keyout=4'b1110;
	
	output reg [7:0] scan=8'b1111_1110;
	output reg [7:0] segs_out;
	
	parameter Delay_Time=130;
	
	reg [13:0] DivClk_Cnt=14'd0;		
	reg Dclk;
	reg [16:0] Det_Cnt=17'd0;
	
	reg [5:0] Css=0; //Choosing states
	reg [15:0] Delay=8'd0; //register for debounce counter
	
	reg [3:0] Bcdz;
	
	reg [3:0] Segs_Disp;
	reg [15:0] Segs_R=16'h0,Segs_L=16'h0A0b;
	
	reg [15:0] Prime_Save_R,Disp_Save_R;//Prime_Save_L,Disp_Save_L;
	reg [15:0] Segs_R_Cmp;
	reg [15:0] Rnd_Cnt=16'd0,Rnd_Save,Rnd_Temp;
	
	reg [7:0] Cmp_Sum,Cmp_Save;
	
	reg [3:0] Total_A,Total_B;
	reg A0,A1,A2,A3,B0,B1,B2,B3;
	
always@(posedge clk)
begin
	begin
		if(DivClk_Cnt==10_000)	//Main Clock frequency divider 50Mhz -> 5kHz
			begin
				DivClk_Cnt<=14'd0;
				Dclk<=~Dclk;
			end
		else
			begin
				DivClk_Cnt<=DivClk_Cnt+14'd1;
			end
	end
	
	begin
		if(Det_Cnt==100_000)		//Scanning Clock frequency divider 500Hz
			begin
				Det_Cnt<=17'd0;
				scan<={scan[6:0],scan[7]};
				keyout<={keyout[2:0],keyout[3]};
			end
		else
			begin
				Det_Cnt<=Det_Cnt+17'd1;
			end
	end
	
end

always@(posedge clk)
begin
	begin
		Rnd_Cnt<=Rnd_Cnt+16'd1;		//Random number generating counter
		if(Rnd_Cnt==16'd9999)
			begin
				Rnd_Cnt<=16'd0;
			end
	end	
end


always@(*)
begin

	begin
		case(scan)  //MUX for selecting 7seg data to Deco
			8'b1111_1110:Segs_Disp=Segs_R[3:0];
			8'b1111_1101:Segs_Disp=Segs_R[7:4];
			8'b1111_1011:Segs_Disp=Segs_R[11:8];
			8'b1111_0111:Segs_Disp=Segs_R[15:12];
			8'b1110_1111:Segs_Disp=Segs_L[3:0];
			8'b1101_1111:Segs_Disp=Segs_L[7:4];
			8'b1011_1111:Segs_Disp=Segs_L[11:8];
			8'b0111_1111:Segs_Disp=Segs_L[15:12];
			default:Segs_Disp={Segs_R==16'h0,Segs_L==16'h0A0b};
		endcase
	end
	
	begin
		case(Segs_Disp)	//7Segs Decoder
			4'd0	:	segs_out =  8'hC0;
			4'd1	:	segs_out =  8'hF9;
			4'd2	:	segs_out =  8'hA4;
			4'd3	:	segs_out =  8'hB0;
			4'd4	:	segs_out =  8'h99;
			4'd5	:	segs_out =  8'h92;
			4'd6	:	segs_out =  8'h82;
			4'd7	:	segs_out =  8'hF8;
			4'd8	:	segs_out =  8'h80;
			4'd9	:	segs_out =  8'h98;
			4'd10 :	segs_out =  8'h88;
			4'd11	:	segs_out =  8'h83;
			4'd12	:	segs_out =  8'hC6;
			4'd13	:	segs_out =  8'hA1;
			4'd14	:	segs_out = 	8'h86;
			4'd15 :	segs_out = 	8'h8E;
		default  :	segs_out = 	8'hFF;
		endcase
	end
	
	
end

always@(posedge Dclk) //divided frequency 'Dclk' always block
begin
	case(Css)
		0:	begin											//Random numbers generator
				Segs_L<=16'h0A0b;
				Rnd_Temp[15:12]<=(Rnd_Cnt/1000);
				Rnd_Temp[11:8]<=(Rnd_Cnt/100)%10;
				Rnd_Temp[7:4]<=(Rnd_Cnt/10)%10;
				Rnd_Temp[3:0]<=(Rnd_Cnt/1)%10;
				Css<=1;
			end
		1:	begin											//Compare if the generated number duplicate digit
				if(Rnd_Temp[15:12]==Rnd_Temp[11:8])
					begin
						Css<=0;
					end
				else if(Rnd_Temp[15:12]==Rnd_Temp[7:4])
					begin
						Css<=0;
					end
				else if(Rnd_Temp[15:12]==Rnd_Temp[3:0])
					begin
						Css<=0;
					end
				else if(Rnd_Temp[11:8]==Rnd_Temp[7:4])
					begin
						Css<=0;
					end
				else if(Rnd_Temp[11:8]==Rnd_Temp[3:0])
					begin
						Css<=0;
					end
				else if(Rnd_Temp[7:4]==Rnd_Temp[3:0])
					begin
						Css<=0;
					end
				else
					begin
						Rnd_Save<=Rnd_Temp;
						Css<=4;
					end
			end
		2:	begin										//Compare the exactness of saved random number and the input number
				begin
					if(Segs_R[3:0]==Rnd_Save[3:0])
						begin
							A0<=1'd1;
							B0<=1'd0;
							Css<=11;
						end
					else
						begin
							A0<=1'd0;
							Css<=11;
							begin
								if(Segs_R[3:0]==Rnd_Save[7:4] || Segs_R[3:0]==Rnd_Save[11:8] || Segs_R[3:0]==Rnd_Save[15:12])
									begin
										B0<=1'd1;
										Css<=11;
									end
								else
									begin
										B0<=1'd0;
										Css<=11;
									end
							end
						end	
				end
				
			begin
				if(Segs_R[7:4]==Rnd_Save[7:4])
						begin
							A1<=1'd1;
							B1<=1'd0;
							Css<=11;
						end
					else
						begin
							A1<=1'd0;
							Css<=11;
							begin
								if(Segs_R[7:4]==Rnd_Save[3:0] || Segs_R[7:4]==Rnd_Save[11:8] || Segs_R[7:4]==Rnd_Save[15:12])
									begin
										B1<=1'd1;
										Css<=11;
									end
								else
									begin
										B1<=1'd0;
										Css<=11;
									end
							end
						end	
				end
				
			begin
				if(Segs_R[11:8]==Rnd_Save[11:8])
						begin
							A2<=1'd1;
							B2<=1'd0;
							Css<=11;
						end
					else
						begin
							A2<=1'd0;
							Css<=11;
							begin
								if(Segs_R[11:8]==Rnd_Save[3:0] || Segs_R[11:8]==Rnd_Save[7:4] || Segs_R[11:8]==Rnd_Save[15:12])
									begin
										B2<=1'd1;
										Css<=11;
									end
								else
									begin
										B2<=1'd0;
										Css<=11;
									end
							end
						end	
				end
				
			begin
				if(Segs_R[15:12]==Rnd_Save[15:12])
						begin
							A3<=1'd1;
							B3<=1'd0;
							Css<=11;
						end
					else
						begin
							A3<=1'd0;
							Css<=11;
							begin
								if(Segs_R[15:12]==Rnd_Save[3:0] || Segs_R[15:12]==Rnd_Save[7:4] || Segs_R[15:12]==Rnd_Save[11:8])
									begin
										B3<=1'd1;
										Css<=11;
									end
								else
									begin
										B3<=1'd0;
										Css<=11;
									end
							end
						end	
				end
				
			end
		
		3:	begin
				Segs_L[15:12]<=Total_A;			//output the compared digit result
				Segs_L[7:4]<=Total_B;
				Css<=10;
				//Disp_Save_L<=Segs_L;
			end
			
		4:	begin
				case({keyout,keyin})  //Keypad scan value
					8'b1110_0111:	begin
											Bcdz<=4'b1100; //C
											begin
												if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
													begin
														Css<=5;
													end
												else
													begin
														Css<=5;
													end
											end
										end	
					8'b1110_1011:	begin
											Bcdz<=4'b1101; //D
											begin
												if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
													begin
														Css<=4;
													end
												else
													begin
														Css<=6;
													end
											end
										end
					8'b1110_1101:	begin
											Bcdz<=4'b1110; //E
											begin
												if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
													begin
														Css<=4;
													end
												else
													begin
														Css<=6;
													end
											end
										end	
					8'b1110_1110:	begin
											Bcdz<=4'b1111; //F
											begin
												if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
													begin
														Css<=4;
													end
												else
													begin
														Css<=6;
													end
											end
										end	
					8'b1101_0111:	begin
											Bcdz<=4'b1000; //8
											begin
												if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
													begin
														Css<=4;
													end
												else
													begin
														Css<=5;
													end
											end
										end
					8'b1101_1011:	begin
											Bcdz<=4'b1001; //9
											begin
												if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
													begin
														Css<=4;
													end
												else
													begin
														Css<=5;
													end
											end
										end
					8'b1101_1101:	begin
											Bcdz<=4'b1010; //A
											begin
												if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
													begin
														Css<=4;
													end
												else
													begin
														if(Segs_R[15:12]==Segs_R[11:8])
															begin
																Css<=4;
															end
														else if(Segs_R[15:12]==Segs_R[7:4])
															begin
																Css<=4;
															end
														else if(Segs_R[15:12]==Segs_R[3:0])
															begin
																Css<=4;
															end
														else if(Segs_R[11:8]==Segs_R[7:4])
															begin
																Css<=4;
															end
														else if(Segs_R[11:8]==Segs_R[3:0])
															begin
																Css<=4;
															end
														else if(Segs_R[7:4]==Segs_R[3:0])
															begin
																Css<=4;
															end
														else
															begin
																Css<=5;
															end
													end
											end
										
										end
					8'b1101_1110:	begin
											Bcdz<=4'b1011; //B
											begin
												if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
													begin
														Css<=4;
													end
												else
													begin
														Css<=6;
													end
											end
										end
					8'b1011_0111:	begin
											Bcdz<=4'b0100; //4
											begin
												if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
													begin
														Css<=4;
													end
												else
													begin
														Css<=5;
													end
											end
										end
					8'b1011_1011:	begin
											Bcdz<=4'b0101; //5
											begin
												if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
													begin
														Css<=4;
													end
												else
													begin
														Css<=5;
													end
											end
										end
					8'b1011_1101:	begin
											Bcdz<=4'b0110; //6
											begin
												if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
													begin
														Css<=4;
													end
												else
													begin
														Css<=5;
													end
											end
										end
					8'b1011_1110:	begin
											Bcdz<=4'b0111; //7
											begin
												if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
													begin
														Css<=4;
													end
												else
													begin
														Css<=5;
													end
											end
										end
					8'b0111_0111:	begin
											Bcdz<=4'b0000; //0
											begin
												if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
													begin
														Css<=4;
													end
												else
													begin
														Css<=5;
													end
											end
										end
					8'b0111_1011:	begin
											Bcdz<=4'b0001; //1
											begin
												if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
													begin
														Css<=4;
													end
												else
													begin
														Css<=5;
													end
											end
										end
					8'b0111_1101:	begin
											Bcdz<=4'b0010; //2
											begin
												if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
													begin
														Css<=4;
													end
												else
													begin
														Css<=5;
													end
											end
										end
					8'b0111_1110:	begin
											Bcdz<=4'b0011; //3
											begin
												if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
													begin
														Css<=4;
													end
												else
													begin
														Css<=5;
													end
											end
										end
						  default:	begin
											Css<=4;
										end
				endcase
			end
		5:	begin
				
				if(keyin==4'b1111)
					begin
						if(Delay==Delay_Time)
							begin
								Delay<=8'd0;
								Css<=6;
							end
						else
							begin
								Delay<=Delay+8'd1;
								Css<=Css;
							end
					end
				else
					begin
						Delay<=8'd0;
						Css<=5;
					end
					
				/*case(keyin)
					4'b1111:	begin
									if(Delay==Delay_Time)
										begin
											Delay<=16'd0;
											Css<=6;
										end
									else
										begin
											Delay<=Delay+16'd1;
											Css<=Css;
										end
								end
					default:	begin
									Delay<=16'd0;
									Css<=5;
								end
				endcase*/
			end
		
		6:	begin
				case(Bcdz)
					4'b1010: begin									//A
									Css<=2;
									Cmp_Sum<=Cmp_Sum+8'd1;
								end
					4'b1011:	begin									//B	//Completed function
									Segs_R<=16'h0;
									Css<=4;
								end
					4'b1100:	begin									//C 	//Completed function
									Segs_R<=16'h0;
									Segs_L<=16'h0A0b;
									Cmp_Sum<=0;
									Cmp_Save<=0;
									Css<=0;
								end
					4'b1101:	begin									//D	//If 'A' key could debounced correctly,then this function should be able to complete
									Segs_R<=Cmp_Save;
									Prime_Save_R<=Segs_R;
									Css<=8;
								end
					4'b1110:	begin									//E	//Half completed,Compared result on the left is able to be saved and displayed,but input still unable to
									Segs_R<=Disp_Save_R;
									Prime_Save_R<=Segs_R;
									//Segs_L<=Disp_Save_L;
									//Prime_Save_L<=Segs_L;
									//Segs_R<=16'h0;
									Css<=9;
								end
					4'b1111:	begin									//F 	//Completed function
									Segs_R<=Rnd_Save;
									Prime_Save_R<=Segs_R;
									Css<=8;
								end
					default: begin
									Css<=7;
								end
					
				endcase
			end
		7:	begin
				Segs_R<={Segs_R[11:0],Bcdz};
				Css<=4;
			end
		8:	begin
				case(keyin)
					4'b1111:	begin
									if(Delay==Delay_Time)
										begin
											Segs_R<=Prime_Save_R;
											Delay<=8'd0;
											Css<=4;
										end
									else
										begin
											Delay<=Delay+8'd1;
											Css<=Css;
										end
								end
					default:	begin
									Delay<=8'd0;
									Css<=8;
								end
				endcase
			end
		
		9:	begin
				case(keyin)
					4'b1111:	begin
									if(Delay==Delay_Time)
										begin
											Segs_R<=Prime_Save_R;
											//Segs_L<=Prime_Save_L;
											Delay<=8'd0;
											Css<=4;
										end
									else
										begin
											Delay<=Delay+8'd1;
											Css<=Css;
										end
								end
					default:	begin
									Delay<=8'd0;
									Css<=9;
								end
				endcase
			end
		
		10:begin
				Cmp_Save<=Cmp_Sum;
				Css<=12;
			end
		
		11:begin
				Total_A<=A0+A1+A2+A3;		//add up compared digit result
				Total_B<=B0+B1+B2+B3;
				Css<=3;
			end
			
		12:begin
				if(Segs_R==Rnd_Save && Segs_L[15:12]==4'h4)
					begin
						Segs_L[15:12]<=4'h4;
						Segs_L[7:0]<=Cmp_Save;
						Css<=4;
					end
				else
					begin
						Disp_Save_R<=Segs_R;
						Segs_R<=16'h0;
						Css<=4;
					end
			end
			
	endcase
end
endmodule
