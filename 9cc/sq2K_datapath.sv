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
   
   reg [33*33-1:0][24:0]                    mulA2;
   reg [33*33-1:0][17:0]                    mulB2;   
   wire [33*33-1:0][42:0]                   mulP2;   
   
   
   
   
   wire [33-1:0][24:0]                      currmulA1;  
   wire [33-1:0][17:0]                      currmulB1;  
   
   wire [33-1:0][24:0]                      currmulA2;  
   wire [33-1:0][17:0]                      currmulB2;      


   reg [66-1:0][66-1:0][24:0]               Adder1_A;
   wire [66-1:0][24:0]                      Adder1_C;
   wire [66-1:0][24:0]                      Adder1_S;
   
   reg [66-1:0][66-1:0][24:0]               Adder2_A;
   wire [66-1:0][24:0]                      Adder2_C;
   wire [66-1:0][24:0]                      Adder2_S;


   wire [66-1:0][16:0]                      RES1; 


   wire [130-1:0][16:0]                     RES2; 


   wire [99-1:0][16:0]                      P2;
   wire [67-1:0][16:0]                      P4; 
   wire [99-1:0][16:0]                      P6; 
   wire [67-1:0][16:0]                      P8; 
   wire [130-1:0][16:0]                     P10; 


   wire [65:0][16:0]                        Pacc1;
   wire [65:0][16:0]                        Pacc2;
   
   reg                                      Pacc1_extra;
   reg                                      Pacc2_extra; 
   
   reg [65:0][8:0]                          membox_in;
   wire [65:0][2047:0]                      membox_out;
   

   reg [130-1:0][66-1:0][22:0]              Accum2_A;
   wire [130-1:0][22:0]                     Accum2_C;
   wire [130-1:0][22:0]                     Accum2_S;
   
   reg [130-1:0][16:0]                      Resv1;
   wire [130-1:0][18:0]                     Resv1A_C;
   wire [130-1:0][18:0]                     Resv1A_S;
   wire [130-1:0][19:0]                     Resv1A;  
   wire [130-1:0][16:0]                     Resv2A; 
   reg [130-1:0][16:0]                      Resv2A_1d; 
   
   wire [130-1:0][18:0]                     Resv1B_C;
   wire [130-1:0][18:0]                     Resv1B_S;
   wire [130-1:0][19:0]                     Resv1B;  
   wire [130-1:0][16:0]                     Resv2B; 
   reg [130-1:0][16:0]                      Resv2B_1d;     
   wire [130-1:0][16:0]                     Resv2B_1d_sel;  
   
   wire [130-1:0][18:0]                     Resv1C_C;
   wire [130-1:0][18:0]                     Resv1C_S;
   wire [130-1:0][19:0]                     Resv1C;  
   wire [130-1:0][16:0]                     Resv2C; 
   reg [130-1:0][16:0]                      Resv2C_1d;     




   reg [130-1:0][16:0]                      Resv3;
   wire [130-1:0][18:0]                     Resv3A_C;
   wire [130-1:0][18:0]                     Resv3A_S;
   wire [130-1:0][19:0]                     Resv3A;  
   wire [130-1:0][16:0]                     Resv4A; 
   reg [130-1:0][16:0]                      Resv4A_1d; 
   
   wire [130-1:0][18:0]                     Resv3B_C;
   wire [130-1:0][18:0]                     Resv3B_S;
   wire [130-1:0][19:0]                     Resv3B;  
   wire [130-1:0][16:0]                     Resv4B; 
   reg [130-1:0][16:0]                      Resv4B_1d; 
   wire [130-1:0][16:0]                     Resv4B_1d_sel;  
   
   wire [130-1:0][18:0]                     Resv3C_C;
   wire [130-1:0][18:0]                     Resv3C_S;
   wire [130-1:0][19:0]                     Resv3C;  
   wire [130-1:0][16:0]                     Resv4C; 
   
   
   
   integer                                  j,k;
   
   genvar                                   i,m,n;

   /*
    Begin here
    */

   
   
   curr_mul mycurr_mul(SQ_STATE, currmulA1, currmulB1, currmulA2, currmulB2, curr_op);
   
   
   
   always@(*)
     begin
        for(j=0; j<33; j=j+1)
          begin
             for(k=0; k<33; k=k+1)
               begin 
                  mulA1[j*33+k] = currmulA1[k];
                  mulB1[j*33+k] = currmulB1[j];    
                  
                  mulA2[j*33+k] = currmulA2[k];
                  mulB2[j*33+k] = currmulB2[j]; 
               end
          end    
     end
   
   

   for (i=0 ; i<33*33 ; i=i+1)    
     mul_17x17_asic mymul1(mulA1[i], mulB1[i], clk_sq, mulP1[i]);
   
   for (i=0 ; i<33*33 ; i=i+1)    
     mul_17x17_asic mymul2(mulA2[i], mulB2[i], clk_sq, mulP2[i]);
   
   
   for(m=0; m<33; m=m+1)
     begin
        for(n=0; n<33; n=n+1) 
          begin
             assign Adder1_A[m+n][(2*m)]     = {8'b0, mulP1[m*33+n][15:0]};
             assign Adder1_A[m+n+1][(2*m+1)] = {6'b0, mulP1[m*33+n][33:16]};           
             
             assign Adder2_A[m+n][(2*m)]     = {8'b0, mulP2[m*33+n][15:0]};
             assign Adder2_A[m+n+1][(2*m+1)] = {6'b0, mulP2[m*33+n][33:16]};
          end
     end   
   
   
   
   for(m=0; m<33; m=m+1)
     begin
        for(n=2*m+1; n<66; n=n+1) 
          begin
             assign Adder1_A[m][n] = 24'h0;    
             assign Adder2_A[m][n] = 24'h0;             
          end
     end 
   for(m=33; m<66; m=m+1)
     begin
        for(n=0; n<=(m-33)*2; n=n+1) 
          begin
             assign Adder1_A[m][n] = 24'h0;    
             assign Adder2_A[m][n] = 24'h0;                    
          end
     end     
   
   
   
   for (i=0 ; i<66 ; i=i+1)             
     add_16_66 accum1(Adder1_A[i], Adder1_C[i], Adder1_S[i], clk_sq, reset_sq);

   for (i=0 ; i<66 ; i=i+1)             
     add_16_66 accum2(Adder2_A[i], Adder2_C[i], Adder2_S[i], clk_sq, reset_sq);
   
   


   
   Preg myPreg(
               .clk_sq(clk_sq),
               .reset_sq(reset_sq),
               .SQ_STATE(SQ_STATE),
               .SQ_STATE_2d(SQ_STATE_2d),
               .RED_STATE_2d(RED_STATE_2d),
               .P2(P2),
               .P4(P4), 
               .P6(P6),
               .P8(P8),
               .P10(P10),
               .Adder1_C(Adder1_C),
               .Adder1_S(Adder1_S),
               .Adder2_C(Adder2_C),    
               .Adder2_S(Adder2_S)    
               );
   
   
   

   for (m=0 ; m<66 ; m=m+1)
     assign Pacc1[m] =  P2[m+32]; 

   
   for (m=0 ; m<66 ; m=m+1)
     assign Pacc2[m] =  P6[m+32]; 

   
   

   always @(posedge clk_sq)
     begin
        Pacc1_extra <=     Pacc1[0][16]|Pacc1[1][16]|Pacc1[2][16]|Pacc1[3][16]|Pacc1[4][16]|
                           Pacc1[5][16]|Pacc1[6][16]|Pacc1[7][16]|Pacc1[8][16]|Pacc1[9][16]|
                           Pacc1[10][16]|Pacc1[11][16]|Pacc1[12][16]|Pacc1[13][16]|Pacc1[14][16]|
                           Pacc1[15][16]|Pacc1[16][16]|Pacc1[17][16]|Pacc1[18][16]|Pacc1[19][16]|
                           Pacc1[20][16]|Pacc1[21][16]|Pacc1[22][16]|Pacc1[23][16]|Pacc1[24][16]|
                           Pacc1[25][16]|Pacc1[26][16]|Pacc1[27][16]|Pacc1[28][16]|Pacc1[29][16]|      
                           Pacc1[30][16]|Pacc1[31][16]|Pacc1[32][16]|Pacc1[33][16]|Pacc1[34][16]|
                           Pacc1[35][16]|Pacc1[36][16]|Pacc1[37][16]|Pacc1[38][16]|Pacc1[39][16]|
                           Pacc1[40][16]|Pacc1[41][16]|Pacc1[42][16]|Pacc1[43][16]|Pacc1[44][16]|
                           Pacc1[45][16]|Pacc1[46][16]|Pacc1[47][16]|Pacc1[48][16]|Pacc1[49][16]|      
                           Pacc1[50][16]|Pacc1[51][16]|Pacc1[52][16]|Pacc1[53][16]|Pacc1[54][16]|
                           Pacc1[55][16]|Pacc1[56][16]|Pacc1[57][16]|Pacc1[58][16]|Pacc1[59][16]|      
                           Pacc1[60][16]|Pacc1[61][16]|Pacc1[62][16]|Pacc1[63][16]|Pacc1[64][16]|
                           Pacc1[65][16];  
     end

   
   always @(posedge clk_sq)
     begin
        Pacc2_extra <=   Pacc2[0][16]|Pacc2[1][16]|Pacc2[2][16]|Pacc2[3][16]|Pacc2[4][16]|
                         Pacc2[5][16]|Pacc2[6][16]|Pacc2[7][16]|Pacc2[8][16]|Pacc2[9][16]|
                         Pacc2[10][16]|Pacc2[11][16]|Pacc2[12][16]|Pacc2[13][16]|Pacc2[14][16]|
                         Pacc2[15][16]|Pacc2[16][16]|Pacc2[17][16]|Pacc2[18][16]|Pacc2[19][16]|
                         Pacc2[20][16]|Pacc2[21][16]|Pacc2[22][16]|Pacc2[23][16]|Pacc2[24][16]|
                         Pacc2[25][16]|Pacc2[26][16]|Pacc2[27][16]|Pacc2[28][16]|Pacc2[29][16]|      
                         Pacc2[30][16]|Pacc2[31][16]|Pacc2[32][16]|Pacc2[33][16]|Pacc2[34][16]|
                         Pacc2[35][16]|Pacc2[36][16]|Pacc2[37][16]|Pacc2[38][16]|Pacc2[39][16]|
                         Pacc2[40][16]|Pacc2[41][16]|Pacc2[42][16]|Pacc2[43][16]|Pacc2[44][16]|
                         Pacc2[45][16]|Pacc2[46][16]|Pacc2[47][16]|Pacc2[48][16]|Pacc2[49][16]|      
                         Pacc2[50][16]|Pacc2[51][16]|Pacc2[52][16]|Pacc2[53][16]|Pacc2[54][16]|        
                         Pacc2[55][16]|Pacc2[56][16]|Pacc2[57][16]|Pacc2[58][16]|Pacc2[59][16]|      
                         Pacc2[60][16]|Pacc2[61][16]|Pacc2[62][16]|Pacc2[63][16]|Pacc2[64][16]|
                         Pacc2[65][16];   
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
               for(j=0; j<66; j=j+1)
                 begin
                    membox_in[j] = {1'b0, Pacc1[j][15:8]};   
                 end                           
            end            
          5'd2:
            begin
               for(j=0; j<66; j=j+1)
                 begin
                    membox_in[j] = {1'b0, Pacc1[j][7:0]};   
                 end                           
            end   
          5'd3:
            begin
               for(j=0; j<66; j=j+1)
                 begin
                    membox_in[j] = {1'b0, 7'b0, Pacc1[j][16]};   
                 end                           
            end 
          5'd4:
            begin
               for(j=0; j<66; j=j+1)
                 begin
                    membox_in[j] = {1'b1, Pacc2[j][15:8]};   
                 end                           
            end            
          5'd5:
            begin
               for(j=0; j<66; j=j+1)
                 begin
                    membox_in[j] = {1'b1, Pacc2[j][7:0]};   
                 end                           
            end   
          5'd6:
            begin
               for(j=0; j<66; j=j+1)
                 begin
                    membox_in[j] = {1'b1, 7'b0, Pacc2[j][16]};   
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
        for(n=0; n<66; n=n+1) 
          begin
             assign Accum2_A[m][n] = {6'b0, membox_out[n][m*16+:16]};
          end
     end   

   for(n=0; n<66; n=n+1) 
     begin
        assign Accum2_A[128][n] = 23'h0;      
        assign Accum2_A[129][n] = 23'h0;                                      
     end


   
   for (i=0 ; i<130 ; i=i+1)             
     add_16_66_B accum3(Accum2_A[i], Accum2_C[i], Accum2_S[i], clk_sq, reset_sq);
   

   
   accum_Resv1A accum4(Resv1A_C, Resv1A_S, Accum2_C, Accum2_S);

   for(m=0; m<130; m=m+1)
     assign Resv1A[m] = Resv1A_C[m] + Resv1A_S[m];
   
   assign Resv2A[0] = Resv1A[0][15:0];
   for(m=1; m<130; m=m+1)
     assign Resv2A[m] = Resv1A[m][15:0] + Resv1A[m-1][19:16];


   always @(posedge clk_sq)
     begin
        if (RED_STATE_2d == 5'd1)
          Resv2A_1d <= Resv2A;
        else
          Resv2A_1d <= Resv2A_1d;
     end






   
   


   accum_Resv1B accum5(Resv1B_C, Resv1B_S, Accum2_C, Accum2_S, Resv2A_1d);

   for(m=0; m<130; m=m+1)
     assign Resv1B[m] = Resv1B_C[m] + Resv1B_S[m];
   
   assign Resv2B[0] = Resv1B[0][15:0];
   for(m=1; m<130; m=m+1)
     assign Resv2B[m] = Resv1B[m][15:0] + Resv1B[m-1][19:16];


   always @(posedge clk_sq)
     begin
        if (RED_STATE_2d == 5'd2)
          Resv2B_1d <= Resv2B;
        else
          Resv2B_1d <= Resv2B_1d;
     end





   for(m=0; m<129; m=m+1)
     assign Resv2B_1d_sel[m] = Resv2B_1d[m+1];
   assign Resv2B_1d_sel[129] = '0;


   accum_Resv1B accum6(Resv1C_C, Resv1C_S, Accum2_C, Accum2_S, Resv2B_1d_sel);

   for(m=0; m<130; m=m+1)
     assign Resv1C[m] = Resv1C_C[m] + Resv1C_S[m];
   
   assign Resv2C[0] = Resv1C[0][15:0];
   for(m=1; m<130; m=m+1)
     assign Resv2C[m] = Resv1C[m][15:0] + Resv1C[m-1][19:16];


   always @(posedge clk_sq)
     begin
        if (RED_STATE_2d == 5'd3)
          Resv2C_1d <= Resv2C;
        else
          Resv2C_1d <= Resv2C_1d;
     end
   
   
   always @(posedge clk_sq)
     begin
        if (RED_STATE_2d == 5'd4)
          begin
             if (Pacc1_extra == 1'b0)
               Resv1 <= Resv2B_1d;
             else
               begin
                  Resv1[0] <= Resv2B_1d[0];               
                  for(j=1; j<130; j=j+1)
                    Resv1[j] <= Resv2C_1d[j-1];          
               end
          end
        else
          Resv1 <= Resv1;
     end      
   
   









   accum_Resv3A accum7(Resv3A_C, Resv3A_S, Accum2_C, Accum2_S, P10);

   for(m=0; m<130; m=m+1)
     assign Resv3A[m] = Resv3A_C[m] + Resv3A_S[m];
   
   assign Resv4A[0] = Resv3A[0][15:0];
   for(m=1; m<130; m=m+1)
     assign Resv4A[m] = Resv3A[m][15:0] + Resv3A[m-1][19:16];


   always @(posedge clk_sq)
     begin
        if (RED_STATE_2d == 5'd4)
          Resv4A_1d <= Resv4A;
        else
          Resv4A_1d <= Resv4A_1d;
     end


   accum_Resv3B accum8(Resv3B_C, Resv3B_S, Accum2_C, Accum2_S, Resv1, Resv4A_1d);

   for(m=0; m<130; m=m+1)
     assign Resv3B[m] = Resv3B_C[m] + Resv3B_S[m];
   
   assign Resv4B[0] = Resv3B[0][15:0];
   for(m=1; m<130; m=m+1)
     assign Resv4B[m] = Resv3B[m][15:0] + Resv3B[m-1][19:16];


   always @(posedge clk_sq)
     begin
        if (RED_STATE_2d == 5'd5)
          Resv4B_1d <= Resv4B;
        else
          Resv4B_1d <= Resv4B_1d;
     end






   for(m=0; m<129; m=m+1)
     assign Resv4B_1d_sel[m] = Resv4B_1d[m+1];
   assign Resv4B_1d_sel[129] = '0;




   accum_Resv3C accum9(Resv3C_C, Resv3C_S, Accum2_C, Accum2_S, Resv4B_1d_sel);

   for(m=0; m<130; m=m+1)
     assign Resv3C[m] = Resv3C_C[m] + Resv3C_S[m];
   
   assign Resv4C[0] = Resv3C[0][15:0];
   for(m=1; m<130; m=m+1)
     assign Resv4C[m] = Resv3C[m][15:0] + Resv3C[m-1][19:16];



















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
        
        else if (RED_STATE_2d == 5'd5)
          curr_op <= Resv4B; 
        else if (RED_STATE_2d == 5'd6)
          begin
             curr_op[0] <= Resv4B_1d[0];
             for(j=1; j<129; j=j+1)
               curr_op[j] <= Resv4C[j-1];   
          end
        else
          curr_op <= curr_op;
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
               if (Pacc2_extra)
                 begin
                    if (RED_STATE_2d == 5'd6)
                      begin
                         sq_finished = 1'b1;
                         NEXT_SQ_STATE = 5'd1;
                      end
                    else
                      begin
                         sq_finished = 1'b0;
                         NEXT_SQ_STATE = 5'd6;
                      end
                 end
               else
                 begin
                    if (RED_STATE_2d == 5'd5)
                      begin
                         sq_finished = 1'b1;
                         NEXT_SQ_STATE = 5'd1;
                      end
                    else
                      begin
                         sq_finished = 1'b0;
                         NEXT_SQ_STATE = 5'd6;
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
                 NEXT_RED_STATE = 5'd0;
            end 
          5'd6:
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

