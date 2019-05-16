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



module add_16_66(
                 input [65:0][24:0] Adder_A,
                 input [24:0]       Adder_B,
                 output [25:0]      S, //just itself + previous
                 output [25:0]      S2x, //2*itself + previous
                 output [25:0]      S3x, //itself + 2*previous
                 input              clk_sq,
                 input              reset_sq
                 );
   

   wire [3:0] [4:0] [24:0]          L1C;
   wire [3:0] [4:0] [24:0]          L1S;
   
   wire [3:0] [3:0] [24:0]          L2C;
   wire [3:0] [3:0] [24:0]          L2S;    

   wire [3:0] [1:0] [24:0]          L3C;
   wire [3:0] [1:0] [24:0]          L3S; 
   
   wire [3:0] [1:0] [24:0]          L4C;
   wire [3:0] [1:0] [24:0]          L4S; 
   
   wire [5:0] [24:0]                L5C;
   wire [5:0] [24:0]                L5S; 
   
   wire [3:0] [24:0]                L6C;
   wire [3:0] [24:0]                L6S;     
   
   reg [3:0] [24:0]                 L6C_1d;
   reg [3:0] [24:0]                 L6S_1d; 
   

   
   wire [2:0] [24:0]                L3C2;
   wire [2:0] [24:0]                L3S2; 

   wire [1:0] [24:0]                L4C2;
   wire [1:0] [24:0]                L4S2; 
   
   wire [24:0]                      L5C2;
   wire [24:0]                      L5S2; 
   
   wire [24:0]                      L6S2;
   wire [24:0]                      L6C2;   






   wire [2:0] [24:0]                L3C3;
   wire [2:0] [24:0]                L3S3; 
   
   wire [1:0] [24:0]                L4C3;
   wire [1:0] [24:0]                L4S3; 
   
   wire [24:0]                      L5C3;
   wire [24:0]                      L5S3; 
   
   wire [24:0]                      L6S3;
   wire [24:0]                      L6C3;   


   wire [2:0] [24:0]                L3C4;
   wire [2:0] [24:0]                L3S4; 
   
   wire [1:0] [24:0]                L4C4;
   wire [1:0] [24:0]                L4S4; 
   
   wire [24:0]                      L5C4;
   wire [24:0]                      L5S4; 
   
   wire [24:0]                      L6S4;
   wire [24:0]                      L6C4;   
   
   
   genvar                           i,j;
   
   for (j=0;j<4;j=j+1)
     begin
        for (i=0;i<5;i=i+1)
          begin
             csa_25 level1A0(L1C[j][i],L1S[j][i],Adder_A[3*i+16*j], Adder_A[3*i+1+16*j], Adder_A[3*i+2+16*j]);
          end
        
        
        csa_25 level2A0(L2C[j][0], L2S[j][0], L1S[j][0], L1S[j][1], L1S[j][2]);
        csa_25 level2B0(L2C[j][1], L2S[j][1], {L1C[j][0][23:0], 1'b0}, {L1C[j][1][23:0], 1'b0}, {L1C[j][2][23:0], 1'b0});
        csa_25 level2C0(L2C[j][2], L2S[j][2], {L1C[j][3][23:0], 1'b0}, {L1C[j][4][23:0], 1'b0}, Adder_A[15+16*j] );        
        
        csa_25 level3A0(L3C[j][0], L3S[j][0], L2S[j][0], L2S[j][1], L2S[j][2]);
        csa_25 level3B0(L3C[j][1], L3S[j][1], {L2C[j][0][23:0], 1'b0}, {L2C[j][1][23:0], 1'b0}, {L2C[j][2][23:0], 1'b0});
        
        csa_25 level4A0(L4C[j][0], L4S[j][0], L3S[j][0], L3S[j][1], L1S[j][4]);
        csa_25 level4B0(L4C[j][1], L4S[j][1], {L3C[j][0][23:0], 1'b0}, {L3C[j][1][23:0], 1'b0}, L1S[j][3]);
     end


   csa_25 level5A0(L5C[0],L5S[0], {L4C[0][0][23:0], 1'b0}, {L4C[0][1][23:0], 1'b0}, {L4C[1][0][23:0], 1'b0});
   csa_25 level5B0(L5C[1],L5S[1], {L4C[1][1][23:0], 1'b0}, {L4C[2][0][23:0], 1'b0}, {L4C[2][1][23:0], 1'b0});
   csa_25 level5C0(L5C[2],L5S[2], {L4C[3][0][23:0], 1'b0}, {L4C[3][1][23:0], 1'b0}, L4S[0][0]);
   csa_25 level5D0(L5C[3],L5S[3], L4S[0][1], L4S[1][0], L4S[1][1]);
   csa_25 level5E0(L5C[4],L5S[4], L4S[2][0], L4S[2][1], L4S[3][0]);    
   csa_25 level5F0(L5C[5],L5S[5], L4S[3][1], Adder_A[64], Adder_A[65]);  
   
   csa_25 level6A0(L6C[0],L6S[0], {L5C[0][23:0], 1'b0}, {L5C[1][23:0], 1'b0}, {L5C[2][23:0], 1'b0});    
   csa_25 level6B0(L6C[1],L6S[1], {L5C[3][23:0], 1'b0}, {L5C[4][23:0], 1'b0}, {L5C[5][23:0], 1'b0});    
   csa_25 level6C0(L6C[2],L6S[2], L5S[0], L5S[1], L5S[2]);  
   csa_25 level6D0(L6C[3],L6S[3], L5S[3], L5S[4], L5S[5]);   
   
   always @(posedge clk_sq)
     begin
        L6C_1d <= L6C; 
        L6S_1d <= L6S;
     end
   
   
   csa_25 level3A1(L3C2[0], L3S2[0], {L6S_1d[0][23:0], 1'b0}, {L6S_1d[1][23:0], 1'b0}, {L6S_1d[2][23:0], 1'b0});
   csa_25 level3B1(L3C2[1], L3S2[1], {L6C_1d[0][22:0], 2'b0}, {L6C_1d[1][22:0], 2'b0}, {L6C_1d[2][22:0], 2'b0});
   csa_25 level3C1(L3C2[2], L3S2[2], Adder_B, {L6S_1d[3][23:0], 1'b0}, {L6C_1d[3][22:0], 2'b0});
   

   csa_25 level4A1(L4C2[0], L4S2[0],  L3S2[0], L3S2[1], L3S2[2]);
   csa_25 level4B1(L4C2[1], L4S2[1], {L3C2[0][23:0], 1'b0}, {L3C2[1][23:0], 1'b0}, {L3C2[2][23:0], 1'b0});

   
   csa_25 level5A1(L5C2, L5S2,  L4S2[0], L4S2[1], {L4C2[0][23:0], 1'b0});
   
   
   csa_25 level6A1(L6C2, L6S2,  L5S2, {L5C2[23:0], 1'b0}, {L4C2[1][23:0], 1'b0}); 
   
   
   assign S2x = {L6C2[23:0], 1'b0} + L6S2; 
   
   
   
   





   csa_25 level3A2(L3C3[0], L3S3[0], L6S_1d[0], L6S_1d[1], L6S_1d[2]);
   csa_25 level3B2(L3C3[1], L3S3[1], {L6C_1d[0][23:0], 1'b0}, {L6C_1d[1][23:0], 1'b0}, {L6C_1d[2][23:0], 1'b0});
   csa_25 level3C2(L3C3[2], L3S3[2], Adder_B, L6S_1d[3], {L6C_1d[3][23:0], 1'b0});

   csa_25 level4A2(L4C3[0], L4S3[0],  L3S3[0], L3S3[1], L3S3[2]);
   csa_25 level4B2(L4C3[1], L4S3[1], {L3C3[0][23:0], 1'b0}, {L3C3[1][23:0], 1'b0}, {L3C3[2][23:0], 1'b0});


   
   
   csa_25 level5A2(L5C3, L5S3,  L4S3[0], L4S3[1], {L4C3[0][23:0], 1'b0});
   
   
   csa_25 level6A2(L6C3, L6S3,  L5S3, {L5C3[23:0], 1'b0}, {L4C3[1][23:0], 1'b0}); 
   
   
   assign S = {L6C3[23:0], 1'b0} + L6S3; 














   csa_25 level3A3(L3C4[0], L3S4[0], L6S_1d[0], L6S_1d[1], L6S_1d[2]);
   csa_25 level3B3(L3C4[1], L3S4[1], {L6C_1d[0][23:0], 1'b0}, {L6C_1d[1][23:0], 1'b0}, {L6C_1d[2][23:0], 1'b0});
   csa_25 level3C3(L3C4[2], L3S4[2], {Adder_B[23:0], 1'b0}, {L6S_1d[3][23:0], 1'b0}, {L6C_1d[3][23:0], 1'b0});

   csa_25 level4A3(L4C4[0], L4S4[0],  L3S4[0], L3S4[1], L3S4[2]);
   csa_25 level4B3(L4C4[1], L4S4[1], {L3C4[0][23:0], 1'b0}, {L3C4[1][23:0], 1'b0}, {L3C4[2][23:0], 1'b0});


   
   
   csa_25 level5A3(L5C4, L5S4,  L4S4[0], L4S4[1], {L4C4[0][23:0], 1'b0});
   
   
   csa_25 level6A3(L6C4, L6S4,  L5S4, {L5C4[23:0], 1'b0}, {L4C4[1][23:0], 1'b0}); 
   
   
   assign S3x = {L6C4[23:0], 1'b0} + L6S4; 
   
   
endmodule
