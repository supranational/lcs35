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

This module is accumulating polynomials together.
P1(X)-P10(x) are a degree-65 polynomial with 25-bit coefficients in C-S form

Each coefficient of P2(X), P6(X), P9(X), P4(X), P7(X), P5(X) are multiplied by 2.

  ________________________________________________________________
  |   P1(X)       |   P3(X)       |   P8(X)       |   P10(X)       |
  |_______________|_______________|_______________|_______________|
           ________________________________________________
          |   P2(X)       |   P6(X)       |   P9(X)       |
          |_______________|_______________|_______________|
                   ________________________________
                  |   P4(X)       |   P7(X)       |
                  |_______________|_______________|     
                           _______________
                          |   P5(X)      |
+                         |______________|
______________________________________________________________________


*/    

module Preg(
            input                      clk_sq,
            input                      reset_sq,
            input [4:0]                SQ_STATE,
            input [4:0]                SQ_STATE_2d,
            input [4:0]                RED_STATE_2d,
            output reg [99-1:0][16:0]  P2,
            output reg [67-1:0][16:0]  P4, 
            output reg [99-1:0][16:0]  P6,
            output reg [67-1:0][16:0]  P8,
            output reg [130-1:0][16:0] P10,
            input [66-1:0][24:0]       Adder1_C,
            input [66-1:0][24:0]       Adder1_S,
            input [66-1:0][24:0]       Adder2_C, 
            input [66-1:0][24:0]       Adder2_S
            );
   integer                             i, j;
   
   genvar                              m,n;
   

   reg [99-1:0][19:0]                  Accum1_C;
   reg [99-1:0][19:0]                  Accum1_S;
   wire [99-1:0][20:0]                 Accum1A;
   wire [99-1:0][16:0]                 Accum1B;
   


   reg [67-1:0][19:0]                  Accum2_C;
   reg [67-1:0][19:0]                  Accum2_S;
   wire [67-1:0][20:0]                 Accum2A;
   wire [67-1:0][16:0]                 Accum2B;
   
   reg [99-1:0][19:0]                  Accum3_C;
   reg [99-1:0][19:0]                  Accum3_S;
   wire [99-1:0][20:0]                 Accum3A;
   wire [99-1:0][16:0]                 Accum3B;    



   reg [130-1:0][19:0]                 Accum5_C;
   reg [130-1:0][19:0]                 Accum5_S;
   wire [130-1:0][20:0]                Accum5A;
   wire [130-1:0][16:0]                Accum5B;
   
   
   
   reg [32-1:0][16:0]                  Adder3;
   
   wire [67-1:0][16:0]                 Adder3PP6; 



   accum_PP2 PP2(
                 .C(Accum1_C),
                 .S(Accum1_S),
                 .Adder1_C(Adder1_C),
                 .Adder1_S(Adder1_S),
                 .Adder2_C(Adder2_C),
                 .Adder2_S(Adder2_S)  );
   
   for(m=0; m<99; m=m+1)
     assign Accum1A[m] = Accum1_C[m] + Accum1_S[m];
   
   assign Accum1B[0] = Accum1A[0][15:0];
   for(m=1; m<99; m=m+1)
     assign Accum1B[m] = Accum1A[m][15:0] + Accum1A[m-1][20:16];
   
   always @(posedge clk_sq)
     begin
        if (SQ_STATE_2d == 5'd1)
          P2 <= Accum1B;
        else
          P2 <= P2;
     end
   
   
   
   
   accum_PP4 PP4(
                 .C(Accum2_C),
                 .S(Accum2_S),
                 .Adder1_C(Adder1_C),
                 .Adder1_S(Adder1_S),
                 .Adder2_C(Adder2_C),
                 .Adder2_S(Adder2_S),
                 .Adder3(Adder3)
                 );      
   
   for(m=0; m<67; m=m+1)
     assign Accum2A[m] = Accum2_C[m] + Accum2_S[m];
   
   assign Accum2B[0] = Accum2A[0][15:0];
   for(m=1; m<67; m=m+1)
     assign Accum2B[m] = Accum2A[m][15:0] + Accum2A[m-1][20:16];
   
   always @(posedge clk_sq)
     begin
        if (SQ_STATE_2d == 5'd2)
          P4 <= Accum2B;
        else
          P4 <= P4;
     end
   
   
   always @(*)
     begin
        if (SQ_STATE_2d == 5'd2)
          begin
             for (i=0;i<32;i=i+1)
               Adder3[i] = P2[i];
          end
        else if (SQ_STATE_2d == 5'd4)
          begin
             for (i=0;i<32;i=i+1)
               Adder3[i] = P6[i];
          end             
        else
          begin
             Adder3 = '0;
          end
     end     
   


   for (m=0;m<67;m=m+1)
     assign Adder3PP6[m] = P4[m];    
   
   accum_PP6 PP6(
                 .C(Accum3_C),
                 .S(Accum3_S),
                 .Adder1_C(Adder1_C),
                 .Adder1_S(Adder1_S),
                 .Adder2_C(Adder2_C),
                 .Adder2_S(Adder2_S),
                 .Adder3(Adder3PP6)
                 );      
   
   for(m=0; m<99; m=m+1)
     assign Accum3A[m] = Accum3_C[m] + Accum3_S[m];
   
   assign Accum3B[0] = Accum3A[0][15:0];
   for(m=1; m<99; m=m+1)
     assign Accum3B[m] = Accum3A[m][15:0] + Accum3A[m-1][20:16];
   
   always @(posedge clk_sq)
     begin
        if (SQ_STATE_2d == 5'd3)
          P6 <= Accum3B;
        else
          P6 <= P6;
     end
   
   
   

   
   
   



   always @(posedge clk_sq)
     begin
        if (SQ_STATE_2d == 5'd4)
          P8 <= Accum2B;
        else
          P8 <= P8;
     end
   



   accum_PP10 PP10(
                   .C(Accum5_C),
                   .S(Accum5_S),
                   .Adder1_C(Adder1_C),
                   .Adder1_S(Adder1_S),
                   .Adder2_C(Adder2_C),
                   .Adder2_S(Adder2_S),
                   .Adder3(P8)
                   );
   
   for(m=0; m<130; m=m+1)
     assign Accum5A[m] = Accum5_C[m] + Accum5_S[m];
   
   assign Accum5B[0] = Accum5A[0][15:0];
   for(m=1; m<130; m=m+1)
     assign Accum5B[m] = Accum5A[m][15:0] + Accum5A[m-1][20:16];
   
   always @(posedge clk_sq)
     begin
        if (SQ_STATE_2d == 5'd5)
          P10 <= Accum5B;
        else
          P10 <= P10;
     end
   
   
   
endmodule
