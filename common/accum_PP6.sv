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





module accum_PP6(
                 output [99-1:0][19:0] C,
                 output [99-1:0][19:0] S,
                 input [66-1:0][24:0]  Adder1_C,
                 input [66-1:0][24:0]  Adder1_S,
                 input [66-1:0][24:0]  Adder2_C, 
                 input [66-1:0][24:0]  Adder2_S,
                 input [67-1:0][16:0]  Adder3
                 );
   
   genvar                              m;
   
   wire [98:0][8:0][19:0]              Accum_PP6;
   wire [98:0][19:0]                   Accum_PP6_C;
   wire [98:0][19:0]                   Accum_PP6_S;

   for(m=0; m<99; m=m+1) begin
      assign C[m] = Accum_PP6_C[m];
      assign S[m] = Accum_PP6_S[m];
   end
   
   assign Accum_PP6[0][0] = {4'h0, Adder2_S[0][14:0], 1'b0};
   assign Accum_PP6[0][1] = {4'h0, Adder2_C[0][14:0], 1'b0};
   assign Accum_PP6[0][2] = 20'h0;
   assign Accum_PP6[0][3] = 20'h0;
   assign Accum_PP6[0][4] = {4'h0, Adder1_S[0][14:0], 1'b0};
   assign Accum_PP6[0][5] = {4'h0, Adder1_C[0][14:0], 1'b0};
   assign Accum_PP6[0][6] = 20'h0;
   assign Accum_PP6[0][7] = 20'h0;
   assign Accum_PP6[0][8] = 20'h0;
   
   for(m=1; m<32; m=m+1) begin
      assign Accum_PP6[m][0] = { 4'h0, Adder2_S[m][14:0], 1'b0};
      assign Accum_PP6[m][1] = { 4'h0, Adder2_C[m][14:0], 1'b0};
      assign Accum_PP6[m][2] = {10'h0, Adder2_S[m-1][24:15]};   
      assign Accum_PP6[m][3] = {10'h0, Adder2_C[m-1][24:15]};    
      assign Accum_PP6[m][4] = { 4'h0, Adder1_S[m][14:0], 1'b0};
      assign Accum_PP6[m][5] = { 4'h0, Adder1_C[m][14:0], 1'b0}; 
      assign Accum_PP6[m][6] = {10'h0, Adder1_S[m-1][24:15]};   
      assign Accum_PP6[m][7] = {10'h0, Adder1_C[m-1][24:15]};    
      assign Accum_PP6[m][8] = 20'h0;
   end
   
   for(m=32; m<66; m=m+1) begin
      assign Accum_PP6[m][0] = { 4'h0, Adder2_S[m][14:0], 1'b0};
      assign Accum_PP6[m][1] = { 4'h0, Adder2_C[m][14:0], 1'b0};
      assign Accum_PP6[m][2] = {10'h0, Adder2_S[m-1][24:15]};   
      assign Accum_PP6[m][3] = {10'h0, Adder2_C[m-1][24:15]};   
      assign Accum_PP6[m][4] = { 4'h0, Adder1_S[m][14:0], 1'b0};    
      assign Accum_PP6[m][5] = { 4'h0, Adder1_C[m][14:0], 1'b0};   
      assign Accum_PP6[m][6] = {10'h0, Adder1_S[m-1][24:15]};   
      assign Accum_PP6[m][7] = {10'h0, Adder1_C[m-1][24:15]};   
      assign Accum_PP6[m][8] = { 3'h0, Adder3[m-32]};
   end  
   assign Accum_PP6[66][0] = 20'h0; 
   assign Accum_PP6[66][1] = 20'h0; 
   assign Accum_PP6[66][2] = {10'h0, Adder2_S[66-1][24:15]}; 
   assign Accum_PP6[66][3] = {10'h0, Adder2_C[66-1][24:15]}; 
   assign Accum_PP6[66][4] = 20'h0; 
   assign Accum_PP6[66][5] = 20'h0; 
   assign Accum_PP6[66][6] = {10'h0, Adder1_S[66-1][24:15]};
   assign Accum_PP6[66][7] = {10'h0, Adder1_C[66-1][24:15]};
   assign Accum_PP6[66][8] = { 3'h0, Adder3[66-32]}; 

   for(m=67; m<99; m=m+1) begin
      assign Accum_PP6[m][0] = 20'h0; 
      assign Accum_PP6[m][1] = 20'h0; 
      assign Accum_PP6[m][2] = 20'h0;   
      assign Accum_PP6[m][3] = 20'h0;   
      assign Accum_PP6[m][4] = 20'h0;    
      assign Accum_PP6[m][5] = 20'h0;   
      assign Accum_PP6[m][6] = 20'h0;    
      assign Accum_PP6[m][7] = 20'h0;   
      assign Accum_PP6[m][8] = { 3'h0, Adder3[m-32]};
   end
   
   

   for (m=0 ; m<99 ; m=m+1)             
     add_16_9 accumPP6(Accum_PP6[m], Accum_PP6_C[m], Accum_PP6_S[m]);
   
endmodule
