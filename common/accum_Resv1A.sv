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





module accum_Resv1A(
                    output [130-1:0][18:0] C,
                    output [130-1:0][18:0] S,
                    input [130-1:0][22:0]  Adder1_C,
                    input [130-1:0][22:0]  Adder1_S
                    );
   
   genvar                                  m;
   
   wire [130-1:0][3:0][18:0]               Accum_Resv1A;
   wire [130-1:0][18:0]                    Accum_Resv1A_C;
   wire [130-1:0][18:0]                    Accum_Resv1A_S;

   for(m=0; m<130; m=m+1) begin
      assign C[m] = Accum_Resv1A_C[m];
      assign S[m] = Accum_Resv1A_S[m];
   end
   
   assign Accum_Resv1A[0][0] = {3'h0, Adder1_S[0][7:0], 8'h0};
   assign Accum_Resv1A[0][1] = {3'h0, Adder1_C[0][7:0], 8'h0};
   assign Accum_Resv1A[0][2] = 19'h0;
   assign Accum_Resv1A[0][3] = 19'h0;
   for(m=1; m<130; m=m+1) begin
      assign Accum_Resv1A[m][0] = {3'h0, Adder1_S[m][7:0], 8'h0};
      assign Accum_Resv1A[m][1] = {3'h0, Adder1_C[m][7:0], 8'h0};
      assign Accum_Resv1A[m][2] = {4'h0, Adder1_S[m-1][22:8]}; 
      assign Accum_Resv1A[m][3] = {4'h0, Adder1_C[m-1][22:8]}; 
   end

   
   
   for (m=0 ; m<130 ; m=m+1)             
     add_16_4 accumResv1A(Accum_Resv1A[m], Accum_Resv1A_C[m], Accum_Resv1A_S[m]);
   
endmodule
