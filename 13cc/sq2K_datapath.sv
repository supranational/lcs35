/*
Copyright 2018-2019 Erdinc Ozturk, SABANCI UNIVERSITY

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/

`timescale 1ns / 1ps

module sq2K_datapath(
                     input                  clk_sq,
                     input                  reset_sq,
                     input [129-1:0][16:0]  sq_in,
                     output [129-1:0][16:0] sq_out,
                     input                  start_sq,
                     output reg             sq_finished_1d 
                     );
   reg                                      sq_finished;
   
   reg [129-1:0][16:0]                      curr_op;
   
   
   reg [4:0]                                SQ_STATE;
   reg [4:0]                                SQ_STATE_1d;
   reg [4:0]                                SQ_STATE_2d;
   reg [4:0]                                SQ_STATE_3d;    
   reg [4:0]                                NEXT_SQ_STATE;
   
   
   reg [4:0]                                RED_STATE;
   reg [4:0]                                RED_STATE_1d;
   reg [4:0]                                RED_STATE_2d;
   reg [4:0]                                RED_STATE_3d;    
   reg [4:0]                                NEXT_RED_STATE;    
   

   
   
   
   reg [33*33-1:0][24:0]                    mulA1;
   reg [33*33-1:0][17:0]                    mulB1;   
   wire [33*33-1:0][42:0]                   mulP1;     
   
   wire [33-1:0][24:0]                      currmulA1;  
   wire [33-1:0][17:0]                      currmulB1;  

   reg [66-1:0][66-1:0][24:0]               Adder1_A;
   wire [66-1:0][25:0]                      Adder1_S;
   wire [66-1:0][25:0]                      Adder1_S2x;
   wire [66-1:0][25:0]                      Adder1_S3x;
   
   wire [66-1:0][24:0]                      Adder1_B;
   
   


   wire [66-1:0][16:0]                      RES1; 
   wire [66-1:0][16:0]                      RES12x; 
   wire [66-1:0][16:0]                      RES13x;     
   wire [66-1:0][16:0]                      RES14x;  
   
   wire [130-1:0][16:0]                     RES2; 

   wire [66-1:0][16:0]                      P1; 
   wire [66-1:0][16:0]                      P2; 
   wire [66-1:0][16:0]                      P3; 
   wire [66-1:0][16:0]                      P4; 
   wire [66-1:0][16:0]                      P5; 
   wire [66-1:0][16:0]                      P6; 
   wire [66-1:0][16:0]                      P7; 
   wire [66-1:0][16:0]                      P8; 
   wire [66-1:0][16:0]                      P9; 
   wire [66-1:0][16:0]                      P10; 


   reg [33:0][16:0]                         Pacc1;
   reg [33:0][16:0]                         Pacc2;
   reg [33:0][16:0]                         Pacc3;
   reg [33:0][16:0]                         Pacc4;
   
   reg                                      Pacc1_extra;
   reg                                      Pacc2_extra;
   reg                                      Pacc3_extra;
   reg                                      Pacc4_extra;    
   
   reg [33:0][8:0]                          membox_in;
   wire [33:0][2047:0]                      membox_out;
   
   reg [130-1:0][34-1:0][21:0]              Adder2_A;
   wire [130-1:0][22:0]                     Adder2_S;
   
   wire [130-1:0][21:0]                     Adder2_B;
   wire [130-1:0][21:0]                     Adder2_C;
   wire [130-1:0][21:0]                     Adder2_D;
   wire [130-1:0][21:0]                     Adder2_E;
   
   wire [130-1:0][16:0]                     Resv1;
   wire [130-1:0][16:0]                     Resv3;
   wire [130-1:0][16:0]                     Resv5;
   wire [130-1:0][16:0]                     Resv7;
   
   
   
   wire [130-1:0][16:0]                     Resv7_pre;
   
   
   
   integer                                  j,k;
   
   genvar                                   i,m,n;

   /*
    Begin here
    */

   
   
   curr_mul mycurr_mul(SQ_STATE, currmulA1, currmulB1, curr_op);
   
   
   
   always@(*)
     begin
        for(j=0; j<33; j=j+1)
          begin
             for(k=0; k<33; k=k+1)
               begin 
                  mulA1[j*33+k] = currmulA1[k];
                  mulB1[j*33+k] = currmulB1[j];
               end
          end    
     end
   
   

   for (i=0 ; i<33*33 ; i=i+1)    
     mul_17x17_asic mymul1(mulA1[i], mulB1[i], clk_sq, mulP1[i]);
   
   
   for(m=0; m<33; m=m+1)
     begin
        for(n=0; n<33; n=n+1) 
          begin
             assign Adder1_A[m+n][(2*m)]     = {8'b0, mulP1[m*33+n][15:0]};
             assign Adder1_A[m+n+1][(2*m+1)] = {6'b0, mulP1[m*33+n][33:16]};
          end
     end   
   
   
   
   for(m=0; m<33; m=m+1)
     begin
        for(n=2*m+1; n<66; n=n+1) 
          begin
             assign Adder1_A[m][n] = 24'h0;                
          end
     end 
   for(m=33; m<66; m=m+1)
     begin
        for(n=0; n<=(m-33)*2; n=n+1) 
          begin
             assign Adder1_A[m][n] = 24'h0;                    
          end
     end     
   
   
   
   for (i=0 ; i<66 ; i=i+1)             
     add_16_66 accum1(Adder1_A[i], Adder1_B[i], Adder1_S[i], Adder1_S2x[i], Adder1_S3x[i], clk_sq, reset_sq);

   
   assign RES1[0] = Adder1_S[0][15:0];
   for(i=1; i<66; i=i+1)
     assign RES1[i] = Adder1_S[i][15:0]+ Adder1_S[i-1][25:16];



   assign RES12x[0] = Adder1_S2x[0][15:0];
   for(i=1; i<66; i=i+1)
     assign RES12x[i] = Adder1_S2x[i][15:0]+ Adder1_S2x[i-1][25:16];
   
   
   assign RES13x[0] = Adder1_S3x[0][15:0];
   for(i=1; i<66; i=i+1)
     assign RES13x[i] = Adder1_S3x[i][15:0]+ Adder1_S3x[i-1][25:16];
   

   assign RES14x[0] = {Adder1_S[0][14:0], 1'b0};
   for(i=1; i<66; i=i+1)
     assign RES14x[i] = {Adder1_S[i][14:0], 1'b0} + Adder1_S[i-1][25:15];
   
   
   
   Preg myPreg (clk_sq, reset_sq, SQ_STATE, SQ_STATE_2d, RED_STATE_2d, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, Resv1, Resv3, Resv5, Resv7, Resv7_pre, RES1, RES12x, RES13x, RES14x, Adder1_B, Adder2_B, Adder2_C, Adder2_D, Adder2_E, RES2);
   
   
   for (i=0 ; i<34 ; i=i+1)
     assign Pacc1[i] =  P1[i+32]; 
   
   for (i=0 ; i<34 ; i=i+1)
     assign Pacc2[i] =  P2[i+32]; 
   
   for (i=0 ; i<34 ; i=i+1)
     assign Pacc3[i] =  Resv1[i+96];     
   
   for (i=0 ; i<34 ; i=i+1)
     assign Pacc4[i] =  Resv3[i+96];             


   always @(posedge clk_sq)
     begin
        Pacc1_extra <=  Pacc1[0][16]|Pacc1[1][16]|Pacc1[2][16]|Pacc1[3][16]|Pacc1[4][16]|
                        Pacc1[5][16]|Pacc1[6][16]|Pacc1[7][16]|Pacc1[8][16]|Pacc1[9][16]|
                        Pacc1[10][16]|Pacc1[11][16]|Pacc1[12][16]|Pacc1[13][16]|Pacc1[14][16]|
                        Pacc1[15][16]|Pacc1[16][16]|Pacc1[17][16]|Pacc1[18][16]|Pacc1[19][16]|
                        Pacc1[20][16]|Pacc1[21][16]|Pacc1[22][16]|Pacc1[23][16]|Pacc1[24][16]|
                        Pacc1[25][16]|Pacc1[26][16]|Pacc1[27][16]|Pacc1[28][16]|Pacc1[29][16]|      
                        Pacc1[30][16]|Pacc1[31][16]|Pacc1[32][16]|Pacc1[33][16];
     end
   
   
   always @(posedge clk_sq)
     begin
        Pacc2_extra <=  Pacc2[0][16]|Pacc2[1][16]|Pacc2[2][16]|Pacc2[3][16]|Pacc2[4][16]|
                        Pacc2[5][16]|Pacc2[6][16]|Pacc2[7][16]|Pacc2[8][16]|Pacc2[9][16]|
                        Pacc2[10][16]|Pacc2[11][16]|Pacc2[12][16]|Pacc2[13][16]|Pacc2[14][16]|
                        Pacc2[15][16]|Pacc2[16][16]|Pacc2[17][16]|Pacc2[18][16]|Pacc2[19][16]|
                        Pacc2[20][16]|Pacc2[21][16]|Pacc2[22][16]|Pacc2[23][16]|Pacc2[24][16]|
                        Pacc2[25][16]|Pacc2[26][16]|Pacc2[27][16]|Pacc2[28][16]|Pacc2[29][16]|      
                        Pacc2[30][16]|Pacc2[31][16]|Pacc2[32][16]|Pacc2[33][16];
     end
   

   always @(posedge clk_sq)
     begin
        Pacc3_extra <=  Pacc3[0][16]|Pacc3[1][16]|Pacc3[2][16]|Pacc3[3][16]|Pacc3[4][16]|
                        Pacc3[5][16]|Pacc3[6][16]|Pacc3[7][16]|Pacc3[8][16]|Pacc3[9][16]|
                        Pacc3[10][16]|Pacc3[11][16]|Pacc3[12][16]|Pacc3[13][16]|Pacc3[14][16]|
                        Pacc3[15][16]|Pacc3[16][16]|Pacc3[17][16]|Pacc3[18][16]|Pacc3[19][16]|
                        Pacc3[20][16]|Pacc3[21][16]|Pacc3[22][16]|Pacc3[23][16]|Pacc3[24][16]|
                        Pacc3[25][16]|Pacc3[26][16]|Pacc3[27][16]|Pacc3[28][16]|Pacc3[29][16]|      
                        Pacc3[30][16]|Pacc3[31][16]|Pacc3[32][16]|Pacc3[33][16];
     end
   
   always @(posedge clk_sq)
     begin
        Pacc4_extra <=  Pacc4[0][16]|Pacc4[1][16]|Pacc4[2][16]|Pacc4[3][16]|Pacc4[4][16]|
                        Pacc4[5][16]|Pacc4[6][16]|Pacc4[7][16]|Pacc4[8][16]|Pacc4[9][16]|
                        Pacc4[10][16]|Pacc4[11][16]|Pacc4[12][16]|Pacc4[13][16]|Pacc4[14][16]|
                        Pacc4[15][16]|Pacc4[16][16]|Pacc4[17][16]|Pacc4[18][16]|Pacc4[19][16]|
                        Pacc4[20][16]|Pacc4[21][16]|Pacc4[22][16]|Pacc4[23][16]|Pacc4[24][16]|
                        Pacc4[25][16]|Pacc4[26][16]|Pacc4[27][16]|Pacc4[28][16]|Pacc4[29][16]|      
                        Pacc4[30][16]|Pacc4[31][16]|Pacc4[32][16]|Pacc4[33][16];
     end
   
   
   always @(*)
     begin
        case (RED_STATE)
          5'd0:
            begin
               membox_in = 'X;               
            end
          5'd1:
            begin
               for(j=0; j<34; j=j+1)
                 begin
                    membox_in[j] = {1'b0, Pacc1[j][15:8]};   
                 end                           
            end            
          5'd2:
            begin
               for(j=0; j<34; j=j+1)
                 begin
                    membox_in[j] = {1'b0, Pacc1[j][7:0]};   
                 end                           
            end   
          5'd3:
            begin
               for(j=0; j<34; j=j+1)
                 begin
                    membox_in[j] = {1'b0, 7'b0, Pacc1[j][16]};   
                 end                           
            end 
          5'd4:
            begin
               for(j=0; j<34; j=j+1)
                 begin
                    membox_in[j] = {1'b0, Pacc2[j][15:8]};   
                 end                           
            end            
          5'd5:
            begin
               for(j=0; j<34; j=j+1)
                 begin
                    membox_in[j] = {1'b0, Pacc2[j][7:0]};   
                 end                           
            end   
          5'd6:
            begin
               for(j=0; j<34; j=j+1)
                 begin
                    membox_in[j] = {1'b0, 7'b0, Pacc2[j][16]};   
                 end                           
            end
          5'd7:
            begin
               for(j=0; j<34; j=j+1)
                 begin
                    membox_in[j] = {1'b0, Pacc3[j][15:8]};   
                 end                           
            end            
          5'd8:
            begin
               for(j=0; j<34; j=j+1)
                 begin
                    membox_in[j] = {1'b0, Pacc3[j][7:0]};   
                 end                           
            end   
          5'd9:
            begin
               for(j=0; j<34; j=j+1)
                 begin
                    membox_in[j] = {1'b0, 7'b0, Pacc3[j][16]};   
                 end                           
            end   
          5'd10:
            begin
               for(j=0; j<34; j=j+1)
                 begin
                    membox_in[j] = {1'b1, Pacc4[j][15:8]};   
                 end                           
            end            
          5'd11:
            begin
               for(j=0; j<34; j=j+1)
                 begin
                    membox_in[j] = {1'b1, Pacc4[j][7:0]};   
                 end                           
            end   
          5'd12:
            begin
               for(j=0; j<34; j=j+1)
                 begin
                    membox_in[j] = {1'b1, 7'b0, Pacc4[j][16]};   
                 end
            end
          default:
            begin
               membox_in = 'X;                           
            end
        endcase
     end

   membox mymem(membox_in, membox_out, clk_sq);
   
   
   


   for(m=0; m<128; m=m+1)
     begin
        for(n=0; n<34; n=n+1) 
          begin
             assign Adder2_A[m][n] = {6'b0, membox_out[n][m*16+:16]};                                      
          end
     end   

   for(n=0; n<34; n=n+1) 
     begin
        assign Adder2_A[128][n] = 22'h0;      
        assign Adder2_A[129][n] = 22'h0;                                      
     end
   
   
   for (i=0 ; i<130 ; i=i+1)             
     add_16_38 accum2(Adder2_A[i], Adder2_B[i], Adder2_C[i], Adder2_D[i], Adder2_E[i], Adder2_S[i], clk_sq, reset_sq);
   
   
   assign RES2[0] = Adder2_S[0][15:0];
   for(i=1; i<130; i=i+1)
     assign RES2[i] = Adder2_S[i][15:0]+ Adder2_S[i-1][22:16];



   always @(posedge clk_sq)
     begin
        if (SQ_STATE == 5'd0)
          begin
             if (start_sq == 1'b1)
               for(j=0; j<129; j=j+1)
                 curr_op[j] <= sq_in[j];  
             else
               curr_op <= curr_op;
          end
        
        else if (RED_STATE_2d == 5'd11)
          begin
             for(j=0; j<129; j=j+1)
               curr_op[j] <= Resv7_pre[j];  
          end
        else if (RED_STATE_2d == 5'd12)
          begin
             for(j=0; j<129; j=j+1)
               curr_op[j] <= Resv7_pre[j];  
          end            
        else
          begin
             curr_op <= curr_op;
          end
     end  


   








   always @(*)
     begin
        case (SQ_STATE)
          5'd0:
            begin
               sq_finished = 1'b0;
               if (start_sq == 1'b1)
                 NEXT_SQ_STATE = 5'd1;
               else
                 NEXT_SQ_STATE = 5'd0;
            end
          5'd1:
            begin
               sq_finished = 1'b0;
               NEXT_SQ_STATE = 5'd2;
            end  
          5'd2:
            begin
               sq_finished = 1'b0;
               NEXT_SQ_STATE = 5'd3;
            end      
          5'd3:
            begin
               sq_finished = 1'b0;
               NEXT_SQ_STATE = 5'd4;
            end     
          5'd4:
            begin
               sq_finished = 1'b0;
               NEXT_SQ_STATE = 5'd5;
            end     
          5'd5:
            begin
               sq_finished = 1'b0;
               NEXT_SQ_STATE = 5'd6;
            end       
          5'd6:
            begin
               sq_finished = 1'b0;
               NEXT_SQ_STATE = 5'd7;
            end   
          5'd7:
            begin
               sq_finished = 1'b0;
               NEXT_SQ_STATE = 5'd8;
            end   
          5'd8:
            begin
               sq_finished = 1'b0;
               NEXT_SQ_STATE = 5'd9;
            end   
          5'd9:
            begin
               sq_finished = 1'b0;
               NEXT_SQ_STATE = 5'd10;
            end   
          5'd10:
            begin
               sq_finished = 1'b0;
               NEXT_SQ_STATE = 5'd11;
            end                                                          
          5'd11:
            begin
               if (Pacc4_extra)
                 begin
                    if (RED_STATE_2d == 5'd12)
                      begin
                         sq_finished = 1'b1;
                         NEXT_SQ_STATE = 5'd1;
                      end
                    else
                      begin
                         sq_finished = 1'b0;
                         NEXT_SQ_STATE = 5'd11;
                      end
                 end
               else
                 begin
                    if (RED_STATE_2d == 5'd11)
                      begin
                         sq_finished = 1'b1;
                         NEXT_SQ_STATE = 5'd1;
                      end
                    else
                      begin
                         sq_finished = 1'b0;
                         NEXT_SQ_STATE = 5'd11;
                      end
                 end              
            end     
          
          default:
            begin
               sq_finished = 1'b0;
               NEXT_SQ_STATE = 5'd0;
            end
        endcase
     end       




   
   
   
   always @(posedge clk_sq)
     begin
        sq_finished_1d <= sq_finished;
     end
   
   assign sq_out = curr_op;
   
   always @(posedge clk_sq)
     begin
        if (reset_sq)
          begin
             SQ_STATE <= 5'd0;
             SQ_STATE_1d <= 5'd0;
             SQ_STATE_2d <= 5'd0;
             SQ_STATE_3d <= 5'd0;
          end
        else
          begin
             SQ_STATE <= NEXT_SQ_STATE;
             SQ_STATE_1d <= SQ_STATE;
             SQ_STATE_2d <= SQ_STATE_1d;
             SQ_STATE_3d <= SQ_STATE_2d;
          end
     end   
   
   
   
   
   always @(posedge clk_sq)
     begin
        if (reset_sq)
          begin
             RED_STATE <= 5'd0;
             RED_STATE_1d <= 5'd0;
             RED_STATE_2d <= 5'd0;
             RED_STATE_3d <= 5'd0;
          end
        else
          begin
             RED_STATE <= NEXT_RED_STATE;
             RED_STATE_1d <= RED_STATE;
             RED_STATE_2d <= RED_STATE_1d;
             RED_STATE_3d <= RED_STATE_2d;
          end
     end   
   
   always @(*)
     begin
        case (RED_STATE)
          5'd0:
            begin
               if (SQ_STATE == 5'd3)
                 NEXT_RED_STATE = 5'd1;
               else
                 NEXT_RED_STATE = 5'd0;
            end
          5'd1:
            begin
               NEXT_RED_STATE = 5'd2;
            end  
          5'd2:
            begin
               if (Pacc1_extra)
                 NEXT_RED_STATE = 5'd3;
               else
                 NEXT_RED_STATE = 5'd4;
            end      
          5'd3:
            begin
               NEXT_RED_STATE = 5'd4;
            end     
          5'd4:
            begin
               NEXT_RED_STATE = 5'd5;
            end     
          5'd5:
            begin
               if (Pacc2_extra)
                 NEXT_RED_STATE = 5'd6;
               else
                 NEXT_RED_STATE = 5'd7;
            end    
          5'd6:
            begin
               NEXT_RED_STATE = 5'd7;
            end   
          5'd7:
            begin
               NEXT_RED_STATE = 5'd8;
            end   
          5'd8:
            begin
               if (Pacc3_extra)
                 NEXT_RED_STATE = 5'd9;
               else
                 NEXT_RED_STATE = 5'd10;
            end      
          5'd9:
            begin
               NEXT_RED_STATE = 5'd10;
            end   
          5'd10:
            begin
               NEXT_RED_STATE = 5'd11;
            end                                       
          
          5'd11:
            begin
               if (Pacc4_extra)
                 NEXT_RED_STATE = 5'd12;
               else
                 NEXT_RED_STATE = 5'd0;
            end 
          5'd12:
            begin
               NEXT_RED_STATE = 5'd0;
            end   
          
          default:
            begin
               NEXT_RED_STATE = 5'd0;
            end
        endcase
     end                            
endmodule

