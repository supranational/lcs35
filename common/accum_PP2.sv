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

/*
This module is to accumulate two polynomials together.
P1(X) is a degree-65 polynomial with 25-bit coefficients in C-S form (Adder1_C and Adder1_S)
P2(X) is a degree-65 polynomial with 25-bit coefficients in C-S form (Adder2_C and Adder2_S)
Each coefficient of P2(X) is multiplied by 2.
PP2(X) = P1(X)*x^32 + 2*P2(X)
   ________________
  |   P1(X)       |
  |_______________|
           _______________
          |   P2(X)      |
+         |______________|
___________________________
   _______________________
  |        PP2(X)        |
  |______________________|


*/

module accum_PP2(
                 output [99-1:0][19:0] C,
                 output [99-1:0][19:0] S,
                 input [66-1:0][24:0]  Adder1_C,
                 input [66-1:0][24:0]  Adder1_S,
                 input [66-1:0][24:0]  Adder2_C, 
                 input [66-1:0][24:0]  Adder2_S
                 );
   
   genvar                              m;
   
   wire [98:0][7:0][19:0]              Accum_PP2;
   wire [98:0][19:0]                   Accum_PP2_C;
   wire [98:0][19:0]                   Accum_PP2_S;

   for(m=0; m<99; m=m+1) begin
      assign C[m] = Accum_PP2_C[m];
      assign S[m] = Accum_PP2_S[m];
   end
   
   //First, low 32 coefficients of P2(X) will be accumulated. 
   //Each coefficinet of P2(x) is multiplied by 2.
   assign Accum_PP2[0][0] = {4'h0, Adder2_S[0][14:0], 1'b0};
   assign Accum_PP2[0][1] = {4'h0, Adder2_C[0][14:0], 1'b0};
   assign Accum_PP2[0][2] = 20'h0;
   assign Accum_PP2[0][3] = 20'h0;
   assign Accum_PP2[0][4] = 20'h0;
   assign Accum_PP2[0][5] = 20'h0;
   assign Accum_PP2[0][6] = 20'h0;
   assign Accum_PP2[0][7] = 20'h0;
   for(m=1; m<32; m=m+1) begin
      assign Accum_PP2[m][0] = {4'h0, Adder2_S[m][14:0], 1'b0}; //low 16 bits of each coefficient of P2(x)*2
      assign Accum_PP2[m][1] = {4'h0, Adder2_C[m][14:0], 1'b0}; //low 16 bits of each coefficient of P2(x)*2
      assign Accum_PP2[m][2] = {10'h0, Adder2_S[m-1][24:15]};   //Remaining  higher bits of each coefficient of P2(x)*2
      assign Accum_PP2[m][3] = {10'h0, Adder2_C[m-1][24:15]};   //Remaining  higher bits of each coefficient of P2(x)*2
      assign Accum_PP2[m][4] = 20'h0;
      assign Accum_PP2[m][5] = 20'h0;
      assign Accum_PP2[m][6] = 20'h0;
      assign Accum_PP2[m][7] = 20'h0;
   end
   assign Accum_PP2[32][0] = {4'h0, Adder2_S[32][14:0], 1'b0};   //low 16 bits of each coefficient of P2(x)*2
   assign Accum_PP2[32][1] = {4'h0, Adder2_C[32][14:0], 1'b0};   //low 16 bits of each coefficient of P2(x)*2
   assign Accum_PP2[32][2] = {10'h0, Adder2_S[32-1][24:15]};     //Remaining  higher bits of each coefficient of P2(x)*2
   assign Accum_PP2[32][3] = {10'h0, Adder2_C[32-1][24:15]};     //Remaining  higher bits of each coefficient of P2(x)*2
   assign Accum_PP2[32][4] = {4'h0, Adder1_S[0][15:0]};          //low 16 bits of each coefficient of P1(x)
   assign Accum_PP2[32][5] = {4'h0, Adder1_C[0][15:0]};          //low 16 bits of each coefficient of P1(x)
   assign Accum_PP2[32][6] = 20'h0;
   assign Accum_PP2[32][7] = 20'h0;    
   for(m=33; m<66; m=m+1) begin
      assign Accum_PP2[m][0] = {4'h0, Adder2_S[m][14:0], 1'b0}; //low 16 bits of each coefficient of P2(x)*2 
      assign Accum_PP2[m][1] = {4'h0, Adder2_C[m][14:0], 1'b0}; //low 16 bits of each coefficient of P2(x)*2
      assign Accum_PP2[m][2] = {10'h0, Adder2_S[m-1][24:15]};   //Remaining  higher bits of each coefficient of P2(x)*2
      assign Accum_PP2[m][3] = {10'h0, Adder2_C[m-1][24:15]};   //Remaining  higher bits of each coefficient of P2(x)*2
      assign Accum_PP2[m][4] = {4'h0, Adder1_S[m-32][15:0]};    //low 16 bits of each coefficient of P1(x)
      assign Accum_PP2[m][5] = {4'h0, Adder1_C[m-32][15:0]};    //low 16 bits of each coefficient of P1(x)
      assign Accum_PP2[m][6] = {11'h0, Adder1_S[m-33][24:16]};  //Remaining  higher bits of each coefficient of P1(x)
      assign Accum_PP2[m][7] = {11'h0, Adder1_C[m-33][24:16]};  //Remaining  higher bits of each coefficient of P1(x)
   end
   assign Accum_PP2[66][0] = 20'h0;                                
   assign Accum_PP2[66][1] = 20'h0;                                
   assign Accum_PP2[66][2] = {10'h0, Adder2_S[66-1][24:15]};       //Remaining  higher bits of each coefficient of P2(x)*2
   assign Accum_PP2[66][3] = {10'h0, Adder2_C[66-1][24:15]};       //Remaining  higher bits of each coefficient of P2(x)*2
   assign Accum_PP2[66][4] = {4'h0, Adder1_S[66-32][15:0]};        //low 16 bits of each coefficient of P1(x)
   assign Accum_PP2[66][5] = {4'h0, Adder1_C[66-32][15:0]};        //low 16 bits of each coefficient of P1(x)
   assign Accum_PP2[66][6] = {11'h0, Adder1_S[66-33][24:16]};      //Remaining  higher bits of each coefficient of P1(x)
   assign Accum_PP2[66][7] = {11'h0, Adder1_C[66-33][24:16]};      //Remaining  higher bits of each coefficient of P1(x)
   for(m=67; m<98; m=m+1) begin
      assign Accum_PP2[m][0] = 20'h0;
      assign Accum_PP2[m][1] = 20'h0;
      assign Accum_PP2[m][2] = 20'h0;
      assign Accum_PP2[m][3] = 20'h0;
      assign Accum_PP2[m][4] = {4'h0, Adder1_S[m-32][15:0]};      //low 16 bits of each coefficient of P1(x)
      assign Accum_PP2[m][5] = {4'h0, Adder1_C[m-32][15:0]};      //low 16 bits of each coefficient of P1(x)
      assign Accum_PP2[m][6] = {11'h0, Adder1_S[m-33][24:16]};    //Remaining  higher bits of each coefficient of P1(x)
      assign Accum_PP2[m][7] = {11'h0, Adder1_C[m-33][24:16]};    //Remaining  higher bits of each coefficient of P1(x)
   end     
   assign Accum_PP2[98][0] = 20'h0;
   assign Accum_PP2[98][1] = 20'h0;
   assign Accum_PP2[98][2] = 20'h0;
   assign Accum_PP2[98][3] = 20'h0;
   assign Accum_PP2[98][4] = 20'h0;
   assign Accum_PP2[98][5] = 20'h0;
   assign Accum_PP2[98][6] = {11'h0, Adder1_S[98-33][24:16]};      //Remaining  higher bits of each coefficient of P1(x)
   assign Accum_PP2[98][7] = {11'h0, Adder1_C[98-33][24:16]};      //Remaining  higher bits of each coefficient of P1(x)
   
   
   //Accumulate 99 coefficients of the result together. 
   //Result is in C-S form.
   for (m=0 ; m<99 ; m=m+1)             
     add_16_8 accumPP2(Accum_PP2[m], Accum_PP2_C[m], Accum_PP2_S[m]);
   
endmodule
