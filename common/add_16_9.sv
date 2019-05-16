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



module add_16_9(
                input [8:0][19:0] Adder_A,
                output reg [19:0] C,
                output reg [19:0] S
                );
   

   
   wire [2:0] [19:0]              L2C;
   wire [2:0] [19:0]              L2S;    

   wire [1:0] [19:0]              L3C;
   wire [1:0] [19:0]              L3S; 
   
   wire [19:0]                    L4C;
   wire [19:0]                    L4S; 
   
   wire [19:0]                    L5C;
   wire [19:0]                    L5S; 

   

   
   
   csa_20 levelA2(L2C[0],L2S[0], Adder_A[0], Adder_A[1], Adder_A[2]);   
   csa_20 levelB2(L2C[1],L2S[1], Adder_A[3], Adder_A[4], Adder_A[5]); 
   csa_20 levelC2(L2C[2],L2S[2], Adder_A[6], Adder_A[7], Adder_A[8]); 
   
   
   
   
   
   csa_20 levelA3(L3C[0], L3S[0], L2S[0], L2S[1], L2S[2]);
   csa_20 levelB3(L3C[1], L3S[1], {L2C[0][18:0], 1'b0}, {L2C[1][18:0], 1'b0}, {L2C[2][18:0], 1'b0});



   
   csa_20 level5A2(L4C, L4S, L3S[0], {L3C[0][18:0], 1'b0}, {L3C[1][18:0], 1'b0});
   
   
   csa_20 level6A2(L5C, L5S,  L4S, {L4C[18:0], 1'b0}, L3S[1]); 
   
   
   assign C = {L5C[18:0], 1'b0};
   assign S = L5S;

   
endmodule
