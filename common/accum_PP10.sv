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



module accum_PP10(
                  output [130-1:0][19:0] C,
                  output [130-1:0][19:0] S,
                  input [66-1:0][24:0]   Adder1_C,
                  input [66-1:0][24:0]   Adder1_S,
                  input [66-1:0][24:0]   Adder2_C, 
                  input [66-1:0][24:0]   Adder2_S,
                  input [67-1:0][16:0]   Adder3
                  );
   
   genvar                                m;
   
   wire [130:0][8:0][19:0]               Accum_PP10;
   wire [130:0][19:0]                    Accum_PP10_C;
   wire [130:0][19:0]                    Accum_PP10_S;

   for(m=0; m<130; m=m+1) begin
      assign C[m] = Accum_PP10_C[m];
      assign S[m] = Accum_PP10_S[m];
   end
   
   assign Accum_PP10[0][0] = {4'h0, Adder2_S[0][15:0]};
   assign Accum_PP10[0][1] = {4'h0, Adder2_C[0][15:0]};
   assign Accum_PP10[0][2] = 20'h0;
   assign Accum_PP10[0][3] = 20'h0;
   assign Accum_PP10[0][4] = 20'h0;
   assign Accum_PP10[0][5] = 20'h0;
   assign Accum_PP10[0][6] = 20'h0;
   assign Accum_PP10[0][7] = 20'h0;
   assign Accum_PP10[0][8] = 20'h0;
   for(m=1; m<32; m=m+1) begin
      assign Accum_PP10[m][0] = {4'h0, Adder2_S[m][15:0]};
      assign Accum_PP10[m][1] = {4'h0, Adder2_C[m][15:0]};
      assign Accum_PP10[m][2] = {11'h0, Adder2_S[m-1][24:16]}; 
      assign Accum_PP10[m][3] = {11'h0, Adder2_C[m-1][24:16]}; 
      assign Accum_PP10[m][4] = 20'h0;
      assign Accum_PP10[m][5] = 20'h0;
      assign Accum_PP10[m][6] = 20'h0;
      assign Accum_PP10[m][7] = 20'h0;
      assign Accum_PP10[m][8] = 20'h0;
   end
   assign Accum_PP10[32][0] = {4'h0, Adder2_S[32][15:0]};
   assign Accum_PP10[32][1] = {4'h0, Adder2_C[32][15:0]};
   assign Accum_PP10[32][2] = {11'h0, Adder2_S[32-1][24:16]}; 
   assign Accum_PP10[32][3] = {11'h0, Adder2_C[32-1][24:16]}; 
   assign Accum_PP10[32][4] = {4'h0, Adder1_S[0][14:0], 1'b0};
   assign Accum_PP10[32][5] = {4'h0, Adder1_C[0][14:0], 1'b0};
   assign Accum_PP10[32][6] = 20'h0;
   assign Accum_PP10[32][7] = 20'h0;  
   assign Accum_PP10[32][8] = 20'h0;   
   for(m=33; m<64; m=m+1) begin
      assign Accum_PP10[m][0] = {4'h0, Adder2_S[m][15:0]};
      assign Accum_PP10[m][1] = {4'h0, Adder2_C[m][15:0]};
      assign Accum_PP10[m][2] = {11'h0, Adder2_S[m-1][24:16]};  
      assign Accum_PP10[m][3] = {11'h0, Adder2_C[m-1][24:16]};  
      assign Accum_PP10[m][4] = {4'h0, Adder1_S[m-32][14:0], 1'b0};
      assign Accum_PP10[m][5] = {4'h0, Adder1_C[m-32][14:0], 1'b0};
      assign Accum_PP10[m][6] = {10'h0, Adder1_S[m-33][24:15]};  
      assign Accum_PP10[m][7] = {10'h0, Adder1_C[m-33][24:15]};  
      assign Accum_PP10[m][8] = 20'h0; 
   end
   for(m=64; m<66; m=m+1) begin
      assign Accum_PP10[m][0] = {4'h0, Adder2_S[m][15:0]};
      assign Accum_PP10[m][1] = {4'h0, Adder2_C[m][15:0]};
      assign Accum_PP10[m][2] = {11'h0, Adder2_S[m-1][24:16]};  
      assign Accum_PP10[m][3] = {11'h0, Adder2_C[m-1][24:16]};  
      assign Accum_PP10[m][4] = {4'h0, Adder1_S[m-32][14:0], 1'b0};
      assign Accum_PP10[m][5] = {4'h0, Adder1_C[m-32][14:0], 1'b0};
      assign Accum_PP10[m][6] = {10'h0, Adder1_S[m-33][24:15]};  
      assign Accum_PP10[m][7] = {10'h0, Adder1_C[m-33][24:15]};  
      assign Accum_PP10[m][8] = { 3'h0, Adder3[m-64]}; 
   end
   
   assign Accum_PP10[66][0] = 20'h0; 
   assign Accum_PP10[66][1] = 20'h0; 
   assign Accum_PP10[66][2] = {11'h0, Adder2_S[66-1][24:16]};  
   assign Accum_PP10[66][3] = {11'h0, Adder2_C[66-1][24:16]};  
   assign Accum_PP10[66][4] = {4'h0, Adder1_S[66-32][14:0], 1'b0};
   assign Accum_PP10[66][5] = {4'h0, Adder1_C[66-32][14:0], 1'b0};
   assign Accum_PP10[66][6] = {10'h0, Adder1_S[66-33][24:15]};  
   assign Accum_PP10[66][7] = {10'h0, Adder1_C[66-33][24:15]};  
   assign Accum_PP10[66][8] = { 3'h0, Adder3[66-64]}; 
   

   for(m=67; m<98; m=m+1) begin
      assign Accum_PP10[m][0] = 20'h0; 
      assign Accum_PP10[m][1] = 20'h0; 
      assign Accum_PP10[m][2] = 20'h0;  
      assign Accum_PP10[m][3] = 20'h0; 
      assign Accum_PP10[m][4] = {4'h0, Adder1_S[m-32][14:0], 1'b0};
      assign Accum_PP10[m][5] = {4'h0, Adder1_C[m-32][14:0], 1'b0};
      assign Accum_PP10[m][6] = {10'h0, Adder1_S[m-33][24:15]};  
      assign Accum_PP10[m][7] = {10'h0, Adder1_C[m-33][24:15]};  
      assign Accum_PP10[m][8] = { 3'h0, Adder3[m-64]}; 
   end

   assign Accum_PP10[98][0] = 20'h0; 
   assign Accum_PP10[98][1] = 20'h0; 
   assign Accum_PP10[98][2] = 20'h0;  
   assign Accum_PP10[98][3] = 20'h0; 
   assign Accum_PP10[98][4] = 20'h0; 
   assign Accum_PP10[98][5] = 20'h0; 
   assign Accum_PP10[98][6] = {10'h0, Adder1_S[98-33][24:15]};  
   assign Accum_PP10[98][7] = {10'h0, Adder1_C[98-33][24:15]};  
   assign Accum_PP10[98][8] = { 3'h0, Adder3[98-64]}; 
   
   
   for(m=99; m<130; m=m+1) begin
      assign Accum_PP10[m][0] = 20'h0; 
      assign Accum_PP10[m][1] = 20'h0; 
      assign Accum_PP10[m][2] = 20'h0;  
      assign Accum_PP10[m][3] = 20'h0; 
      assign Accum_PP10[m][4] = 20'h0; 
      assign Accum_PP10[m][5] = 20'h0; 
      assign Accum_PP10[m][6] = 20'h0; 
      assign Accum_PP10[m][7] = 20'h0; 
      assign Accum_PP10[m][8] = { 3'h0, Adder3[m-64]}; 
   end










   for (m=0 ; m<130 ; m=m+1)             
     add_16_9 accumPP10(Accum_PP10[m], Accum_PP10_C[m], Accum_PP10_S[m]);
   
endmodule
