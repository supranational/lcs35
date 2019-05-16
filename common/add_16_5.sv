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



module add_16_5(
                input [4:0][18:0] Adder_A,
                output reg [18:0] C,
                output reg [18:0] S
                );
   
   wire [18:0]                    L3C;
   wire [18:0]                    L3S; 

   wire [18:0]                    L4C;
   wire [18:0]                    L4S; 
   
   wire [18:0]                    L5C;
   wire [18:0]                    L5S; 

   

   
   csa_19 level4A2(L3C, L3S, Adder_A[0], Adder_A[1], Adder_A[2]);
   
   csa_19 level5A2(L4C, L4S, Adder_A[3], Adder_A[4], L3S);
   
   
   csa_19 level6A2(L5C, L5S,  L4S, {L4C[17:0], 1'b0}, {L3C[17:0], 1'b0}); 
   
   
   assign C = {L5C[17:0], 1'b0};
   assign S = L5S;

   
endmodule
