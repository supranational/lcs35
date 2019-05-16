#!/usr/bin/python3

'''
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
'''


import math
import random    
import sys


gen_membox_sv = True
if len(sys.argv) == 2:
    if sys.argv[1] == "-no_membox_sv":
        gen_membox_sv = False
        


M = 6314466083072888893799357126131292332363298818330841375588990772701957128924885547308446055753206513618346628848948088663500368480396588171361987660521897267810162280557475393838308261759713218926668611776954526391570120690939973680089721274464666423319187806830552067951253070082020241246233982410737753705127344494169501180975241890667963858754856319805507273709904397119733614666701543905360152543373982524579313575317653646331989064651402133985265800341991903982192844710212464887459388853582070318084289023209710907032396934919962778995323320184064522476463966355937367009369212758092086293198727008292431243681

if gen_membox_sv:
    f = open("membox.sv", 'w')

    f.write("/* \n");
    f.write("Copyright 2018-2019 Erdinc Ozturk, SABANCI UNIVERSITY\n");
    f.write("\n");
    f.write("Licensed under the Apache License, Version 2.0 (the \"License\");\n");
    f.write("you may not use this file except in compliance with the License.\n");
    f.write("You may obtain a copy of the License at\n");
    f.write("\n");
    f.write("   http://www.apache.org/licenses/LICENSE-2.0\n");
    f.write("Unless required by applicable law or agreed to in writing, software\n");
    f.write("distributed under the License is distributed on an \"AS IS\" BASIS,\n");
    f.write("WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n");
    f.write("See the License for the specific language governing permissions and\n");
    f.write("limitations under the License.\n");
    f.write("*/ \n\n\n");


    f.write("`timescale 1ns / 1ps\n");
    f.write("module membox (\n");
    f.write("    input [65:0][8:0] mbox8_in,\n");
    f.write("    output reg [65:0][2047:0] mbox8_out,\n");
    f.write("    input clk\n");
    f.write(");\n");
    f.write("\n");
    f.write("          \n");


    for i in range (66):
        D0 = i%10
        D1 = (i//10)%10
        D2 = (i//100)%10
        f.write("(* rom_style = \"block\" *) reg [2047:0] mem8");
        f.write(str(D2));
        f.write(str(D1));
        f.write(str(D0));
        f.write("[0:511] ;  \n");





    f.write(" \n");
    f.write("always @(posedge clk)\n");
    f.write("begin\n");


    for i in range (66):
        D0 = i%10
        D1 = (i//10)%10
        D2 = (i//100)%10

        f.write("    mbox8_out[");
        f.write(str(i));
        f.write("] <= mem8");
        f.write(str(D2));
        f.write(str(D1));
        f.write(str(D0));    
        f.write("[mbox8_in[");
        f.write(str(i));
        f.write("]];\n");




    f.write("end \n");
    f.write("\n");
    f.write("initial begin\n");
    Filename = list("ROM8iii.list")
    for i in range (66):
        D0 = i%10
        D1 = (i//10)%10
        D2 = (i//100)%10

        f.write("    $readmemb(\"ROM8");
        f.write(str(D2));
        f.write(str(D1));
        f.write(str(D0));
        f.write(".dat\", mem8");
        f.write(str(D2));
        f.write(str(D1));
        f.write(str(D0));
        f.write(");\n");



    f.write("end\n");
    f.write("\n");
    f.write("endmodule\n");
    f.close()



# Generate the ROM contents

for i in range (66):
    Filename = list("ROM8%03d.dat" % i)
    f = open("".join(Filename), 'w')

     
    
    T1 = (2**(2048 + ((i+64)*16) ))%M
    
    for j in range (256):
        T2 = (T1*j)%M
        f.write(bin(T2)[2:].zfill(2048))
        f.write('\n')
        
    T1 = (2**(2048 + (i*16) ))%M
    
    for j in range (256):
        T2 = (T1*j)%M
        f.write(bin(T2)[2:].zfill(2048))
        f.write('\n')        
        
    f.close()



