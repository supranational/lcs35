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



module add_16_38(
                 input [33:0][21:0] Adder_A,
                 input [21:0]       Adder_B,
                 input [21:0]       Adder_C,
                 input [21:0]       Adder_D,
                 input [21:0]       Adder_E,
                 output [22:0]      S,
                 input              clk_sq,
                 input              reset_sq
                 );
   

   wire [10:0] [21:0]               L1C;
   wire [10:0] [21:0]               L1S;
   
   wire [6:0] [21:0]                L2C;
   wire [6:0] [21:0]                L2S;    

   wire [4:0] [21:0]                L3C;
   wire [4:0] [21:0]                L3S; 
   
   wire [2:0] [21:0]                L4C;
   wire [2:0] [21:0]                L4S; 
   
   wire [1:0] [21:0]                L5C;
   wire [1:0] [21:0]                L5S; 
   
   wire [1:0] [21:0]                L6S;
   wire [1:0] [21:0]                L6C;
   
   reg [1:0] [21:0]                 L6S_1d;
   reg [1:0] [21:0]                 L6C_1d;    
   
   wire [1:0] [21:0]                L7C;
   wire [1:0] [21:0]                L7S;

   wire [1:0] [21:0]                L8C;
   wire [1:0] [21:0]                L8S;

   wire [21:0]                      L9C;
   wire [21:0]                      L9S;
   
   wire [21:0]                      L10C;
   wire [21:0]                      L10S;
   
   genvar                           i,j;
   

   for (i=0;i<11;i=i+1)
     begin
        csa_22 level1A(L1C[i], L1S[i], Adder_A[3*i], Adder_A[3*i+1], Adder_A[3*i+2]);
     end

   for (i=0;i<3;i=i+1)
     begin
        csa_22 level2A(L2C[i], L2S[i], L1S[3*i], L1S[3*i+1], L1S[3*i+2]);
        csa_22 level2B(L2C[i+3], L2S[i+3], {L1C[3*i][20:0], 1'b0}, {L1C[3*i+1][20:0], 1'b0}, {L1C[3*i+2][20:0], 1'b0} );
     end
   csa_22 level2C(L2C[6], L2S[6], L1S[9], L1S[10], {L1C[9][20:0], 1'b0});
   
   
   
   
   
   
   
   for (i=0;i<2;i=i+1)
     begin
        csa_22 level3A(L3C[i], L3S[i], L2S[3*i], L2S[3*i+1], L2S[3*i+2]);
        csa_22 level3B(L3C[i+2], L3S[i+2], {L2C[3*i][20:0], 1'b0}, {L2C[3*i+1][20:0], 1'b0}, {L2C[3*i+2][20:0], 1'b0} );
     end    
   csa_22 level3C(L3C[4], L3S[4], {L2C[6][20:0], 1'b0}, {L1C[10][20:0], 1'b0}, L2S[6] );
   
   
   csa_22 level4A(L4C[0], L4S[0], L3S[0], L3S[1], L3S[2]);
   csa_22 level4B(L4C[1], L4S[1], L3S[3], L3S[4], {L3C[0][20:0], 1'b0});
   csa_22 level4C(L4C[2], L4S[2], {L3C[1][20:0], 1'b0}, {L3C[2][20:0], 1'b0}, {L3C[3][20:0], 1'b0});


   csa_22 level5A(L5C[0], L5S[0], L4S[0], L4S[1], L4S[2]);
   csa_22 level5B(L5C[1], L5S[1], {L4C[0][20:0], 1'b0}, {L4C[1][20:0], 1'b0}, {L4C[2][20:0], 1'b0} );


   csa_22 level6A(L6C[0], L6S[0], L5S[0], L5S[1], {L5C[0][20:0], 1'b0});
   csa_22 level6B(L6C[1], L6S[1], {L5C[1][20:0], 1'b0}, Adder_A[33], {L3C[4][20:0], 1'b0});
   
   

   always @(posedge clk_sq)
     begin
        L6C_1d <= L6C; 
        L6S_1d <= L6S; 
     end
   
   csa_22 level7A(L7C[0], L7S[0], L6S_1d[0], {L6C_1d[1][20:0], 1'b0}, {L6C_1d[0][20:0], 1'b0});
   csa_22 level7B(L7C[1], L7S[1], Adder_B, Adder_C, L6S_1d[1]);
   
   
   csa_22 level8A(L8C[0], L8S[0], L7S[0], {L7C[0][20:0], 1'b0}, {L7C[1][20:0], 1'b0});
   csa_22 level8B(L8C[1], L8S[1], L7S[1], Adder_D, Adder_E);    

   csa_22 level9A(L9C, L9S, L8S[0], {L8C[0][20:0], 1'b0}, {L8C[1][20:0], 1'b0});   
   
   csa_22 level10A(L10C, L10S, L9S, {L9C[20:0], 1'b0}, L8S[1]);   
   
   
   assign S = {L10C[20:0], 1'b0} + L10S; 
   
endmodule
