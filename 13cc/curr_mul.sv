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



module curr_mul(input [4:0]               SQ_STATE,
                output reg [33-1:0][24:0] currmulA1,
                output reg [33-1:0][17:0] currmulB1, 
                input [129-1:0][16:0]     curr_op
                );

   integer                                j;



   //multiplier done
   always @(*)
     begin
        case (SQ_STATE)
          5'd0:
            begin
               currmulA1 = 'X;
               currmulB1 = 'X;                
            end
          5'd1:
            begin
               for(j=0; j<33; j=j+1)
                 begin
                    currmulA1[j] = {8'h0, curr_op[j+32*3]};
                    currmulB1[j] = {1'h0, curr_op[j+32*3]};                
                 end                           
            end
          5'd2:
            begin
               for(j=0; j<33; j=j+1)
                 begin
                    currmulA1[j] = {8'h0, curr_op[j+32*3]};               
                 end
               for(j=0; j<32; j=j+1)
                 begin
                    currmulB1[j] = {1'h0, curr_op[j+32*2]};                
                 end     
               currmulB1[32] = '0;                                   
            end
          5'd3:
            begin
               for(j=0; j<33; j=j+1)
                 begin
                    currmulA1[j] = {8'h0, curr_op[j+32*3]};               
                 end
               for(j=0; j<32; j=j+1)
                 begin
                    currmulB1[j] = {1'h0, curr_op[j+32*1]};                
                 end     
               currmulB1[32] = '0;                                   
            end 
          5'd4:
            begin
               for(j=0; j<32; j=j+1)
                 begin
                    currmulA1[j] = {8'h0, curr_op[j+32*2]};
                    currmulB1[j] = {1'h0, curr_op[j+32*2]};                
                 end   
               currmulA1[32] = '0; 
               currmulB1[32] = '0;                         
            end 
          5'd5:
            begin
               for(j=0; j<33; j=j+1)
                 begin
                    currmulA1[j] = {8'h0, curr_op[j+32*3]};               
                 end
               for(j=0; j<32; j=j+1)
                 begin
                    currmulB1[j] = {1'h0, curr_op[j+32*0]};                
                 end     
               currmulB1[32] = '0;                                   
            end    
          5'd6:
            begin
               for(j=0; j<32; j=j+1)
                 begin
                    currmulA1[j] = {8'h0, curr_op[j+32*2]};
                    currmulB1[j] = {1'h0, curr_op[j+32*1]};                
                 end   
               currmulA1[32] = '0; 
               currmulB1[32] = '0;                         
            end   
          5'd7:
            begin
               for(j=0; j<32; j=j+1)
                 begin
                    currmulA1[j] = {8'h0, curr_op[j+32*2]};
                    currmulB1[j] = {1'h0, curr_op[j+32*0]};                
                 end   
               currmulA1[32] = '0; 
               currmulB1[32] = '0;                         
            end  
          5'd8:
            begin
               for(j=0; j<32; j=j+1)
                 begin
                    currmulA1[j] = {8'h0, curr_op[j+32*1]};
                    currmulB1[j] = {1'h0, curr_op[j+32*1]};                
                 end   
               currmulA1[32] = '0; 
               currmulB1[32] = '0;                         
            end   
          5'd9:
            begin
               for(j=0; j<32; j=j+1)
                 begin
                    currmulA1[j] = {8'h0, curr_op[j+32*1]};
                    currmulB1[j] = {1'h0, curr_op[j+32*0]};                
                 end   
               currmulA1[32] = '0; 
               currmulB1[32] = '0;                         
            end  
          5'd10:
            begin
               for(j=0; j<32; j=j+1)
                 begin
                    currmulA1[j] = {8'h0, curr_op[j+32*0]};
                    currmulB1[j] = {1'h0, curr_op[j+32*0]};                
                 end   
               currmulA1[32] = '0; 
               currmulB1[32] = '0;                         
            end
          default:
            begin
               currmulA1 = 'X;
               currmulB1 = 'X;                            
            end
        endcase
     end
   
   
   
endmodule
