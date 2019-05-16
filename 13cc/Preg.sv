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


module Preg(
            input                      clk_sq,
            input                      reset_sq,
            input [4:0]                SQ_STATE,
            input [4:0]                SQ_STATE_2d,
            input [4:0]                RED_STATE_2d,
            output reg [66-1:0][16:0]  P1,
            output reg [66-1:0][16:0]  P2,
            output reg [66-1:0][16:0]  P3,
            output reg [66-1:0][16:0]  P4, 
            output reg [66-1:0][16:0]  P5,
            output reg [66-1:0][16:0]  P6,
            output reg [66-1:0][16:0]  P7,
            output reg [66-1:0][16:0]  P8,
            output reg [66-1:0][16:0]  P9,
            output reg [66-1:0][16:0]  P10,
            output reg [130-1:0][16:0] Resv1,
            output reg [130-1:0][16:0] Resv3,
            output reg [130-1:0][16:0] Resv5,
            output reg [130-1:0][16:0] Resv7,
            output reg [130-1:0][16:0] Resv7_pre,
            input [66-1:0][16:0]       RES1,
            input [66-1:0][16:0]       RES12x,
            input [66-1:0][16:0]       RES13x, 
            input [66-1:0][16:0]       RES14x, 
            output reg [66-1:0][24:0]  Adder1_B,
            output reg [130-1:0][21:0] Adder2_B,
            output reg [130-1:0][21:0] Adder2_C,
            output reg [130-1:0][21:0] Adder2_D,
            output reg [130-1:0][21:0] Adder2_E,
            input [130-1:0][16:0]      RES2
            );
   integer                             i, j;
   


   
   always @(posedge clk_sq)
     begin
        if (RED_STATE_2d == 5'd0)
          Resv1 <= '0;
        else if (RED_STATE_2d == 5'd1)
          Resv1 <= RES2;
        else if (RED_STATE_2d == 5'd2)
          Resv1 <= RES2;       
        else if (RED_STATE_2d == 5'd3)
          begin
             Resv1[0] <= Resv1[0]; 
             for(i=1; i<130; i=i+1)
               Resv1[i] <= RES2[i-1];      
          end                        
        else
          Resv1 <= Resv1;
     end



   always @(posedge clk_sq)
     begin
        if (RED_STATE_2d == 5'd0)
          Resv3 <= '0;
        else if (RED_STATE_2d == 5'd4)
          Resv3 <= RES2;
        else if (RED_STATE_2d == 5'd5)
          Resv3 <= RES2;       
        else if (RED_STATE_2d == 5'd6)
          begin
             Resv3[0] <= Resv3[0]; 
             for(i=1; i<130; i=i+1)
               Resv3[i] <= RES2[i-1];      
          end                        
        else
          Resv3 <= Resv3;
     end
   


   always @(posedge clk_sq)
     begin
        if (RED_STATE_2d == 5'd0)
          Resv5 <= '0;
        else if (RED_STATE_2d == 5'd7)
          Resv5 <= RES2;
        else if (RED_STATE_2d == 5'd8)
          Resv5 <= RES2;       
        else if (RED_STATE_2d == 5'd9)
          begin
             Resv5[0] <= Resv5[0]; 
             for(i=1; i<130; i=i+1)
               Resv5[i] <= RES2[i-1];      
          end                        
        else
          Resv5 <= Resv5;
     end
   
   always @(*)
     begin

        if (RED_STATE_2d == 5'd0)
          Resv7_pre <= '0;
        else if (RED_STATE_2d == 5'd10)
          Resv7_pre = RES2;
        else if (RED_STATE_2d == 5'd11)
          Resv7_pre = RES2;       
        else if (RED_STATE_2d == 5'd12)
          begin
             Resv7_pre[0] = Resv7[0]; 
             for(i=1; i<130; i=i+1)
               Resv7_pre[i] = RES2[i-1];      
          end                        
        else
          Resv7_pre = Resv7;

     end    
   


   always @(posedge clk_sq)
     begin
        Resv7 <= Resv7_pre;
     end 
   
   
   
   
   always @(posedge clk_sq)
     begin
        if (SQ_STATE_2d == 5'd1)
          P1 <= RES1;
        else
          P1 <= P1;
     end
   
   always @(posedge clk_sq)
     begin
        if (SQ_STATE_2d == 5'd2)
          P2 <= RES12x;
        else
          P2 <= P2;
     end
   
   always @(posedge clk_sq)
     begin
        if (SQ_STATE_2d == 5'd3)
          P3 <= RES12x;
        else
          P3 <= P3;
     end
   
   always @(posedge clk_sq)
     begin
        if (SQ_STATE_2d == 5'd4)
          P4 <= RES1;
        else
          P4 <= P4;
     end        
   
   always @(posedge clk_sq)
     begin
        if (SQ_STATE_2d == 5'd5)
          P5 <= RES12x;
        else
          P5 <= P5;
     end
   
   always @(posedge clk_sq)
     begin
        if (SQ_STATE_2d == 5'd6)
          P6 <= RES12x;
        else
          P6 <= P6;
     end
   
   always @(posedge clk_sq)
     begin
        if (SQ_STATE_2d == 5'd7)
          P7 <= RES12x;
        else
          P7 <= P7;
     end
   
   always @(posedge clk_sq)
     begin
        if (SQ_STATE_2d == 5'd8)
          P8 <= RES1;
        else
          P8 <= P8;
     end       
   always @(posedge clk_sq)
     begin
        if (SQ_STATE_2d == 5'd9)
          P9 <= RES12x;
        else
          P9 <= P9;
     end
   
   always @(posedge clk_sq)
     begin
        if (SQ_STATE_2d == 5'd10)
          P10 <= RES1;
        else
          P10 <= P10;
     end   
   
   

   always @(*)
     begin
        case (RED_STATE_2d)
          5'd1:
            begin
               for(j=0; j<130; j=j+1)
                 begin
                    Adder2_B[j] = 22'h0;  
                    Adder2_C[j] = 22'h0;  
                    Adder2_D[j] = 22'h0;  
                    Adder2_E[j] = 22'h0;               
                 end                                       
            end 
          5'd2:
            begin
               for(j=0; j<130; j=j+1)
                 begin
                    Adder2_B[j] = {6'h0, Resv1[j][7:0], 8'h0};   
                    Adder2_E[j] = 22'h0;
                 end   
               
               
               for(j=0; j<96; j=j+1)
                 begin   
                    Adder2_D[j] = 22'h0;
                 end
               for(j=96; j<130; j=j+1)
                 begin   
                    Adder2_D[j] = P4[j-64];
                 end
               
               
               
               Adder2_C[0] = 22'h0;  
               for(j=1; j<130; j=j+1)
                 begin
                    Adder2_C[j] = {13'h0, Resv1[j-1][16:8]};             
                 end                                                    
            end
          
          
          5'd3:
            begin
               
               for(j=0; j<130; j=j+1)
                 begin
                    Adder2_B[j] = {5'h0, Resv1[j+1]};
                 end
               
               for(j=0; j<130; j=j+1)
                 begin
                    Adder2_C[j] = '0;
                    Adder2_D[j] = '0;
                    Adder2_E[j] = '0;
                 end                                       
            end   
          

          5'd4:
            begin
               for(j=0; j<130; j=j+1)
                 begin 
                    Adder2_D[j] = 22'h0;  
                    Adder2_E[j] = 22'h0;               
                 end 
               
               
               for(j=0; j<32; j=j+1)
                 begin
                    Adder2_B[j] = 22'h0;
                 end    
               for(j=32; j<128; j=j+1)
                 begin
                    Adder2_B[j] = {13'h0, Resv1[j-32][16:8]};                
                 end 
               Adder2_B[128] = 22'h0; 
               Adder2_B[129] = '0;  
               
               for(j=0; j<31; j=j+1)
                 begin
                    Adder2_C[j] = 22'h0;
                 end                                       
               for(j=31; j<127; j=j+1)
                 begin
                    Adder2_C[j] = {6'h0, Resv1[j-31][7:0], 8'h0};                
                 end        
               Adder2_C[127] = 22'h0; 
               Adder2_C[128] = 22'h0;  
               Adder2_C[129] = 22'h0;        
               
            end 

          5'd5:
            begin
               for(j=0; j<130; j=j+1)
                 begin
                    Adder2_B[j] = {6'h0, Resv3[j][7:0], 8'h0};   
                    Adder2_E[j] = 22'h0;
                 end   
               
               
               for(j=0; j<96; j=j+1)
                 begin   
                    Adder2_D[j] = 22'h0;
                 end
               for(j=96; j<130; j=j+1)
                 begin   
                    Adder2_D[j] = P6[j-64];
                 end
               
               
               
               Adder2_C[0] = 22'h0;  
               for(j=1; j<130; j=j+1)
                 begin
                    Adder2_C[j] = {13'h0, Resv3[j-1][16:8]};             
                 end                                                    
            end
          
          
          5'd6:
            begin
               
               for(j=0; j<130; j=j+1)
                 begin
                    Adder2_B[j] = {5'h0, Resv3[j+1]};
                 end    
               
               for(j=0; j<130; j=j+1)
                 begin
                    Adder2_C[j] = '0;
                    Adder2_D[j] = '0;
                    Adder2_E[j] = '0;
                 end                                       
            end 







          5'd7:
            begin
               for(j=0; j<130; j=j+1)
                 begin 
                    Adder2_D[j] = 22'h0;  
                    Adder2_E[j] = 22'h0;               
                 end 
               
               
               for(j=0; j<32; j=j+1)
                 begin
                    Adder2_B[j] = 22'h0;
                 end    
               for(j=32; j<128; j=j+1)
                 begin
                    Adder2_B[j] = {13'h0, Resv3[j-32][16:8]};                
                 end 
               Adder2_B[128] = 22'h0; 
               Adder2_B[129] = 22'h0; 
               
               for(j=0; j<31; j=j+1)
                 begin
                    Adder2_C[j] = 22'h0;
                 end                                       
               for(j=31; j<127; j=j+1)
                 begin
                    Adder2_C[j] = {6'h0, Resv3[j-31][7:0], 8'h0};                
                 end        
               Adder2_C[127] = 22'h0; 
               Adder2_C[128] = 22'h0;         
               Adder2_C[129] = 22'h0;                                    
            end 



          
          5'd8:
            begin
               for(j=0; j<130; j=j+1)
                 begin
                    Adder2_B[j] = {6'h0, Resv5[j][7:0], 8'h0};   
                    Adder2_E[j] = 22'h0;
                    Adder2_D[j] = 22'h0;
                 end   
               
               
               
               
               Adder2_C[0] = 22'h0;  
               for(j=1; j<130; j=j+1)
                 begin
                    Adder2_C[j] = {13'h0, Resv5[j-1][16:8]};             
                 end                                                    
            end
          
          
          5'd9:
            begin
               
               for(j=0; j<130; j=j+1)
                 begin
                    Adder2_B[j] = {5'h0, Resv5[j+1]};
                 end 
               
               for(j=0; j<130; j=j+1)
                 begin
                    Adder2_C[j] = '0;
                    Adder2_D[j] = '0;
                    Adder2_E[j] = '0;
                 end                                       
            end 
          













          5'd10:
            begin
               for(j=0; j<130; j=j+1)
                 begin 
                    Adder2_D[j] = 22'h0;  
                    Adder2_E[j] = 22'h0;               
                 end 
               
               
               
               for(j=0; j<130; j=j+1)
                 begin
                    Adder2_B[j] = {13'h0, Resv5[j][16:8]};                
                 end 
               
               
               for(j=0; j<129; j=j+1)
                 begin
                    Adder2_C[j] = {6'h0, Resv5[j+1][7:0], 8'h0};                
                 end 
               Adder2_C[129] = '0;
               
            end 

          5'd11:
            begin
               for(j=0; j<130; j=j+1)
                 begin
                    Adder2_B[j] = {6'h0, Resv7[j][7:0], 8'h0};   

                 end   
               
               Adder2_C[0] = {14'h0, Resv5[0][7:0]};    
               for(j=1; j<130; j=j+1)
                 begin
                    Adder2_C[j] = {13'h0, Resv7[j-1][16:8]};             
                 end                   


               for(j=0; j<64; j=j+1)
                 begin   
                    Adder2_E[j] = 22'h0;
                 end
               for(j=64; j<98; j=j+1)
                 begin   
                    Adder2_E[j] = P9[j-32];
                 end
               for(j=98; j<130; j=j+1)
                 begin   
                    Adder2_E[j] = 22'h0;
                 end
               




               
               for(j=0; j<66; j=j+1)
                 begin   
                    Adder2_D[j] = P10[j];
                 end
               for(j=66; j<96; j=j+1)
                 begin   
                    Adder2_D[j] = 22'h0;
                 end
               for(j=96; j<130; j=j+1)
                 begin   
                    Adder2_D[j] = P8[j-64];
                 end
               
               
               
               
            end
          
          
          5'd12:
            begin
               
               for(j=0; j<130; j=j+1)
                 begin
                    Adder2_B[j] = {5'h0, Resv7[j+1]};
                 end   
               
               for(j=0; j<130; j=j+1)
                 begin
                    Adder2_C[j] = '0;
                    Adder2_D[j] = '0;
                    Adder2_E[j] = '0;
                 end                                       
            end                                                                          
          default:
            begin
               for(j=0; j<130; j=j+1)
                 begin
                    Adder2_B[j] = 'X;
                    Adder2_C[j] = 'X;
                    Adder2_D[j] = 'X;
                    Adder2_E[j] = 'X;
                 end                                       
            end             
        endcase 
     end    
   
   always @(*)
     begin
        case (SQ_STATE_2d)
          5'd1:
            begin
               for(j=0; j<66; j=j+1)
                 begin
                    Adder1_B[j] = 25'h0;               
                 end                                       
            end            
          5'd2:
            begin
               for(j=0; j<32; j=j+1)
                 begin
                    Adder1_B[j] = 25'h0;               
                 end   
               for(j=32; j<64; j=j+1)
                 begin
                    Adder1_B[j] = {8'h0, P1[j-32]};               
                 end     
               for(j=64; j<66; j=j+1)
                 begin
                    Adder1_B[j] = 25'h0;
                 end                                                     
            end
          5'd3:
            begin
               for(j=0; j<32; j=j+1)
                 begin
                    Adder1_B[j] = 25'h0;               
                 end   
               for(j=32; j<64; j=j+1)
                 begin
                    Adder1_B[j] = {8'h0, P2[j-32]};               
                 end     
               for(j=64; j<66; j=j+1)
                 begin
                    Adder1_B[j] = 25'h0;
                 end                                                     
            end   
          5'd4:
            begin
               for(j=0; j<66; j=j+1)
                 begin
                    Adder1_B[j] = {8'h0, P3[j]};               
                 end                                                          
            end    
          5'd5:
            begin
               for(j=0; j<32; j=j+1)
                 begin
                    Adder1_B[j] = 25'h0;               
                 end   
               for(j=32; j<64; j=j+1)
                 begin
                    Adder1_B[j] = {8'h0, P4[j-32]};               
                 end     
               for(j=64; j<66; j=j+1)
                 begin
                    Adder1_B[j] = 25'h0;
                 end                                                     
            end      
          5'd6:
            begin
               for(j=0; j<66; j=j+1)
                 begin
                    Adder1_B[j] = {8'h0, P5[j]};               
                 end                                                          
            end   
          5'd7:
            begin
               for(j=0; j<32; j=j+1)
                 begin
                    Adder1_B[j] = 25'h0;               
                 end   
               for(j=32; j<64; j=j+1)
                 begin
                    Adder1_B[j] = {8'h0, P6[j-32]};               
                 end     
               for(j=64; j<66; j=j+1)
                 begin
                    Adder1_B[j] = 25'h0;
                 end                                                     
            end  
          5'd8:
            begin
               for(j=0; j<66; j=j+1)
                 begin
                    Adder1_B[j] = {8'h0, P7[j]};               
                 end                                                          
            end   
          5'd9:
            begin
               for(j=0; j<32; j=j+1)
                 begin
                    Adder1_B[j] = 25'h0;               
                 end   
               for(j=32; j<64; j=j+1)
                 begin
                    Adder1_B[j] = {8'h0, P8[j-32]};               
                 end     
               for(j=64; j<66; j=j+1)
                 begin
                    Adder1_B[j] = 25'h0;
                 end                                                     
            end  
          5'd10:
            begin
               for(j=0; j<32; j=j+1)
                 begin
                    Adder1_B[j] = 25'h0;               
                 end   
               for(j=32; j<64; j=j+1)
                 begin
                    Adder1_B[j] = {8'h0, P9[j-32]};               
                 end     
               for(j=64; j<66; j=j+1)
                 begin
                    Adder1_B[j] = 25'h0;
                 end                                                     
            end
          default:
            begin
               Adder1_B = 'X;  
            end
        endcase
     end         
endmodule
