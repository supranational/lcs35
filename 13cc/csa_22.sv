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

module csa_22(
              output [21:0] C,
              output [21:0] S,
              input [21:0]  X,
              input [21:0]  Y,
              input [21:0]  Z
              );
   
   genvar                   i;
   generate
      for (i=0 ; i<22 ; i=i+1)
        begin
           FA myadder(C[i], S[i], X[i], Y[i], Z[i]);
        end
   endgenerate
endmodule
