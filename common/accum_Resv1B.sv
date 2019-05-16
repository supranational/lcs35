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





module accum_Resv1B(
                    output [130-1:0][18:0] C,
                    output [130-1:0][18:0] S,
                    input [130-1:0][22:0]  Adder1_C,
                    input [130-1:0][22:0]  Adder1_S,
                    input [130-1:0][16:0]  Adder2
                    );
   
   genvar                                  m;
   
   wire [130-1:0][4:0][18:0]               Accum_Resv1B;
   wire [130-1:0][18:0]                    Accum_Resv1B_C;
   wire [130-1:0][18:0]                    Accum_Resv1B_S;

   for(m=0; m<130; m=m+1) begin
      assign C[m] = Accum_Resv1B_C[m];
      assign S[m] = Accum_Resv1B_S[m];
   end
   
   assign Accum_Resv1B[0][0] = {3'h0, Adder1_S[0][15:0]};
   assign Accum_Resv1B[0][1] = {3'h0, Adder1_C[0][15:0]};
   assign Accum_Resv1B[0][2] = 19'h0;
   assign Accum_Resv1B[0][3] = 19'h0;
   assign Accum_Resv1B[0][4] = {2'h0, Adder2[0]};
   for(m=1; m<130; m=m+1) begin
      assign Accum_Resv1B[m][0] = {3'h0, Adder1_S[m][15:0]};
      assign Accum_Resv1B[m][1] = {3'h0, Adder1_C[m][15:0]};
      assign Accum_Resv1B[m][2] = {12'h0, Adder1_S[m-1][22:16]}; 
      assign Accum_Resv1B[m][3] = {12'h0, Adder1_C[m-1][22:16]};
      assign Accum_Resv1B[m][4] = {2'h0, Adder2[m]};
   end

   
   
   for (m=0 ; m<130 ; m=m+1)             
     add_16_5 accumResv1B(Accum_Resv1B[m], Accum_Resv1B_C[m], Accum_Resv1B_S[m]);
   
endmodule
