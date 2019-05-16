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


    
# convert polynomial respresentation to integer (modulo M)    
def poltoint (Polv, M, pol_degree):
    Res = 0
    for i in range (pol_degree+1):
        Res = Res + ( Polv[i] << (16*i) )       
    Res = Res % M
    return Res


# multiply two degree-32 polynomials
# not all inputs are actually degree-32, some of them are degree-31.
# Alen and Blen determines the actual input length
# Algorithm multiplies two degree-32 polynomials nevertheless
# these polynomials represent ~512-bit segments of the 2048-bit number (33*16 = 512+16
# Xv: pointer of 2048-bit number
def mul512(Xv, Aoffset, Alen, Boffset, Blen):

    OpA = 33*[0]
    OpB = 33*[0]
    
    # if Alen is less than 33, remaining coefficients are left as 0.
    for i in range (Alen): 
        OpA[i] = Xv[i+Aoffset]
      
    # if Blen is less than 33, remaining coefficients are left as 0.
    for i in range (Blen): 
        OpB[i] = Xv[i+Boffset]
        
    Retv = 66*[0]
    C = 33*33*[0]
    
    # do all the inner multiplications.
    # 33*33 = 1089 multipliers are required.
    for i in range (33):
        for j in range(33):
            C[i*33+j] = OpA[i]*OpB[j]

    '''    
    accumulate the results. 
                                                                    A[0]*B[0]
                                                            A[1]*B[0] 
                                                    A[2]*B[0] 
                                                ...
                                A[31]*B[0]                         
                        A[32]*B[0] 
                                        
                                        
                                                            A[0]*B[1]
                                                    A[1]*B[1] 
                                            A[2]*B[1] 
                                        ...
                        A[31]*B[1]                     
                A[32]*B[1]    
                        
                                                    A[0]*B[2]
                                            A[1]*B[2] 
                                    A[2]*B[2] 
                                ...
                A[31]*B[2]             
        A[32]*B[2]                
        ...
        
    '''          
    for i in range (33):
        for j in range(33):
            Retv[i+j] = Retv[i+j] + ( C[i*33+j] & (2**16-1) )
            Retv[i+j+1] = Retv[i+j+1] + ( C[i*33+j] >>16 )

    # each coefficient is 25 bits
    # each coefficient should be at most 17 bits.
    #  High 9 bits of each coefficient are accumulated to its immediate neighbor.   
    for i in range (65,0,-1):
        Retv[i] = Retv[i] + (Retv[i-1]>>16)
        Retv[i-1] = Retv[i-1] & (2**16-1)

 
    del C
    del OpA
    del OpB
    return Retv


# calculate A*A mod M
# Xv is polynomial representation of X


def modsq(Xv, Mbar, numtest):
    '''_______________________________________________________________
      |   P1(X)       |   P3(X)       |   P8(X)       |   P10(X)      |
      |_______________|_______________|_______________|_______________|
               ________________________________________________
              |   P2(X)       |   P6(X)       |   P9(X)       |
              |_______________|_______________|_______________|
                       ________________________________
                      |   P4(X)       |   P7(X)       |
                      |_______________|_______________|     
                               _______________
                              |   P5(X)      |
                              |______________|
    '''    
    P1  = mul512(Xv, 32*3, 33, 32*3, 33)
    P2  = mul512(Xv, 32*3, 33, 32*2, 32)    
    
    P3  = mul512(Xv, 32*3, 33, 32*1, 32)
    P4  = mul512(Xv, 32*2, 32, 32*2, 32)    
    
    P5  = mul512(Xv, 32*3, 33, 32*0, 32)
    P6  = mul512(Xv, 32*2, 32, 32*1, 32)   
     
    P7  = mul512(Xv, 32*2, 32, 32*0, 32)
    P8  = mul512(Xv, 32*1, 32, 32*1, 32)   
     
    P9  = mul512(Xv, 32*1, 32, 32*0, 32)
    P10 = mul512(Xv, 32*0, 32, 32*0, 32)




    #  accumulate P1 and P2 together to get PP2  
    PP2 = [0]*98    
    for i in range (0,32,1):
        PP2[i] = 2*P2[i] 
    for i in range (32,66,1):
        PP2[i] = 2*P2[i] + P1[i-32]
    for i in range (66,98,1):
        PP2[i] = P1[i-32]
        
    # each coefficient is 25 bits
    # each coefficient should be at most 17 bits.
    #  High 9 bits of each coefficient are accumulated to its immediate neighbor.      
    for i in range (97,0,-1):
        PP2[i] = PP2[i] + (PP2[i-1]>>16)
        PP2[i-1] = PP2[i-1] & (2**16-1)            
        



    #  accumulate PP2, P3 and P4 together to get PP4
    PP4 = [0]*66
    
    for i in range (0,32,1):
        PP4[i] = 2*P3[i] + P4[i]    
    for i in range (32,64,1):
        PP4[i] = 2*P3[i] + P4[i] + PP2[i-32]   
    for i in range (64,66,1):
        PP4[i] = 2*P3[i] + P4[i]     
                
    # each coefficient is 25 bits
    # each coefficient should be at most 17 bits.
    #  High 9 bits of each coefficient are accumulated to its immediate neighbor.     
    for i in range (65,0,-1):
        PP4[i] = PP4[i] + (PP4[i-1]>>16)
        PP4[i-1] = PP4[i-1] & (2**16-1)            
        








    #  accumulate PP4, P5 and P6 together to get PP6
    PP6 = [0]*98
    
    for i in range (0,32,1):
        PP6[i] = 2*P5[i] + 2*P6[i]
    for i in range (32,66,1):
        PP6[i] = 2*P5[i] + 2*P6[i] + PP4[i-32]
    for i in range (66,98,1):
        PP6[i] = PP4[i-32]
        
        
                        
    # each coefficient is 25 bits
    # each coefficient should be at most 17 bits.
    #  High 9 bits of each coefficient are accumulated to its immediate neighbor.     
    for i in range (97,0,-1):
        PP6[i] = PP6[i] + (PP6[i-1]>>16)
        PP6[i-1] = PP6[i-1] & (2**16-1)            


    

    #  accumulate PP6, P7 and P8 together to get PP8
    PP8 = [0]*66

    for i in range (0,32,1):
        PP8[i] = P8[i] + 2*P7[i]
    for i in range (32,64,1):
        PP8[i] = P8[i] + 2*P7[i] + PP6[i-32]
    for i in range (64,66,1):
        PP8[i] = P8[i] + 2*P7[i]
        
                                
    # each coefficient is 25 bits
    # each coefficient should be at most 17 bits.
    #  High 9 bits of each coefficient are accumulated to its immediate neighbor.      
    for i in range (65,0,-1):
        PP8[i] = PP8[i] + (PP8[i-1]>>16)
        PP8[i-1] = PP8[i-1] & (2**16-1)            








    #  accumulate PP8, P9 and P10 together to get PP10
    PP10 = [0]*130

    for i in range (0,32,1):
        PP10[i] = P10[i]
    for i in range (32,64,1):
        PP10[i] = P10[i] + 2*P9[i-32]
    for i in range (64,66,1):
        PP10[i] = P10[i] + 2*P9[i-32] + PP8[i-64]    
    for i in range (66,98,1):
        PP10[i] = 2*P9[i-32] + PP8[i-64] 
    for i in range (98,130,1):
        PP10[i] = PP8[i-64]                                 


    # each coefficient is 25 bits
    # each coefficient should be at most 17 bits.
    #  High 9 bits of each coefficient are accumulated to its immediate neighbor.           
    for i in range (129,0,-1):
        PP10[i] = PP10[i] + (PP10[i-1]>>16)
        PP10[i-1] = PP10[i-1] & (2**16-1)            

       
    # Reduction begins here.
    '''_______________________________________________________________
      |   Pacc1(X)    |   Pacc2(X)    |                               |
      |_______________|_______________|_______________________________|

                        |
                        |
                        |
                        |
                        |
                        ---------------------------- 
                                                    |
                                                    |
                                                    |
                                                    v    
                                       ________________________________
                                      |                               |
                                      |_______________________________|

    '''       
        

      
                
    Pacc1 = [0]*66
    
    for i in range (66):
        Pacc1[i] = PP2[i+32]

    # for debugging
    numones = 0
    for i in range (66):
        T1 = (Pacc1[i]>>16)
        numones = numones + T1
        
    if ( numones != 0 ):
        print ("test Pacc1", numones, numtest)
    # end debug code
    
    
    
    Res1bar = [[0 for x in range(128)] for y in range(66)]   
    Res2bar = [[0 for x in range(128)] for y in range(66)]  
    Res1overflowbar = [[0 for x in range(128)] for y in range(66)]   
    
    overflow = 0
    for i in range (66):
        T1 = (Pacc1[i]>>16)
        if (T1!=0):
            overflow = 1
            
        T2 = (Pacc1[i]>>8)&(2**8-1)
        T3 = (Pacc1[i])&(2**8-1)

        for j in range (128):
            Res1overflowbar[i][j] = Mbar[i][T1][j] 
            Res1bar[i][j] = Mbar[i][T2][j]
            Res2bar[i][j] = Mbar[i][T3][j]    
    
    Res1 = 128*[0]
    Res2 = 129*[0]
    Res1overflow = 128*[0]
    Resv1 = 130*[0]
    for i in range (66):
        for j in range (128):
            Res1[j] = Res1[j] + Res1bar[i][j]
            Res2[j] = Res2[j] + Res2bar[i][j]   
            Res1overflow[j] = Res1overflow[j] + Res1overflowbar[i][j]     


   






    for j in range (128):
        Resv1[j] = Resv1[j] + Res2[j]
        
    # each coefficient is 25 bits
    # each coefficient should be at most 17 bits.
    #  High 9 bits of each coefficient are accumulated to its immediate neighbor.    
    for i in range (128,0,-1):
        Resv1[i] = Resv1[i] + (Resv1[i-1]>>16)
        Resv1[i-1] = Resv1[i-1] & (2**16-1)           
        
    for j in range (128):
        Resv1[j] = Resv1[j] + ((Res1[j]<<8)&(2**16-1) )        
        
    for j in range (128):
        Resv1[j+1] = Resv1[j+1] + (Res1[j]>>8)

        
    if (overflow):
        for j in range (128):
            Resv1[j+1] = Resv1[j+1] + Res1overflow[j]
    

    # each coefficient is 25 bits
    # each coefficient should be at most 17 bits.
    #  High 9 bits of each coefficient are accumulated to its immediate neighbor.       
    for i in range (128,0,-1):
        Resv1[i] = Resv1[i] + (Resv1[i-1]>>16)
        Resv1[i-1] = Resv1[i-1] & (2**16-1)      
        


        

                
    Pacc2 = [0]*66

    for i in range (0,66,1):
        Pacc2[i] = PP6[i+32]

    # for debugging
    numones = 0
    for i in range (66):
        T1 = (Pacc2[i]>>16)
        numones = numones + T1
        
    if ( numones != 0 ):
        print ("test Pacc2", numones, numtest)
    # end debug code      



    Res3bar = [[0 for x in range(128)] for y in range(66)]   
    Res4bar = [[0 for x in range(128)] for y in range(66)]  
    Res3overflowbar = [[0 for x in range(128)] for y in range(66)]   
    
    overflow = 0
    
    
        
    for i in range (66):
        T1 = (Pacc2[i]>>16)
        if (T1!=0):
            overflow = 1
            
        T2 = (Pacc2[i]>>8)&(2**8-1)
        T3 = (Pacc2[i])&(2**8-1)

        for j in range (128):
            Res3overflowbar[i][j] = Mbar[i][T1+256][j] 
            Res3bar[i][j] = Mbar[i][T2+256][j]
            Res4bar[i][j] = Mbar[i][T3+256][j]    
    
    Res3 = 128*[0]
    Res4 = 128*[0]
    Res3overflow = 128*[0]
    Resv3 = 130*[0]
    for i in range (66):
        for j in range (128):
            Res3[j] = Res3[j] + Res3bar[i][j]
            Res4[j] = Res4[j] + Res4bar[i][j]    
            Res3overflow[j] = Res3overflow[j] + Res3overflowbar[i][j]   



    for j in range (128):
        Resv3[j] = Resv3[j] + Res4[j]
        
    for j in range (128):
        Resv3[j] = Resv3[j] + ((Res3[j]<<8)&(2**16-1) )        
        
    for j in range (128):
        Resv3[j+1] = Resv3[j+1] + (Res3[j]>>8)


                        
    if (overflow):
        for j in range (128):
            Resv3[j+1] = Resv3[j+1] + Res3overflow[j]
            
    for j in range (0,130,1):
        Resv3[j] = Resv3[j] + Resv1[j]            

        
    for j in range (0,130,1):
        Resv3[j] = Resv3[j] + PP10[j]
        
        
        

    # each coefficient is 25 bits
    # each coefficient should be at most 17 bits.
    #  High 9 bits of each coefficient are accumulated to its immediate neighbor.      
    for i in range (129,0,-1):
        Resv3[i] = Resv3[i] + (Resv3[i-1]>>16)
        Resv3[i-1] = Resv3[i-1] & (2**16-1)  

    del Res1bar, Res2bar, Res3bar, Res4bar


    del P1, P2, P3, P4, P5, P6, P7, P8, P9, P10
    del PP2, PP4, PP6, PP8, PP10
    
    del Res1, Res2, Res1overflow, Resv1
    del Res3, Res4, Res3overflow
    del Pacc1, Pacc2

    return Resv3


random.seed(0)    
size = 2048
num_words = 128

    
X = random.randint(2**(2048-1)+1,2**(2048)-1)

M = 6314466083072888893799357126131292332363298818330841375588990772701957128924885547308446055753206513618346628848948088663500368480396588171361987660521897267810162280557475393838308261759713218926668611776954526391570120690939973680089721274464666423319187806830552067951253070082020241246233982410737753705127344494169501180975241890667963858754856319805507273709904397119733614666701543905360152543373982524579313575317653646331989064651402133985265800341991903982192844710212464887459388853582070318084289023209710907032396934919962778995323320184064522476463966355937367009369212758092086293198727008292431243681


# print_large("M", M, 2048+512, 512)
# print_large("X", X, 2048+512, 512)

# x = 2048/16=128
# y = 512-to-1 mux
# z = 256 different muxes
Mbar = [[[0 for x in range(128)] for y in range(512)] for z in range(66)]

for zz in range (66):
    T1 = (2**(2048 + ((zz+64)*16) ))%M
    for i in range (256):
        T2 = (T1*i)%M
        for j in range (128):
            Mbar[zz][i][j] = T2&(2**16-1)
            T2 = T2 >> 16

    T1 = (2**(2048 + ((zz)*16) ))%M
    for i in range (256):
        T2 = (T1*i)%M
        for j in range (128):
            Mbar[zz][i+256][j] = T2&(2**16-1)
            T2 = T2 >> 16

Xiv = 129*[0]

for i in range (129):
    Xiv[i] = (X>>(16*i))&(2**16-1)

   
Res1 = poltoint(Xiv, M, 128)
Res1 = (Res1*Res1) % M 



# brute test
numtest = 1
correct = 1
for i in range (numtest):
    Xiv = modsq(Xiv, Mbar, i)

    Res2 = poltoint(Xiv, M, 128)
    if (Res1 != Res2):
        print(i, " Wrong")
        correct = 0
        break
        
    Res1 = (Res1*Res1) % M 
    if ((i % 100)== 0):
        print ("Tested: ", i)

if (correct == 1):
    print ("Concept Design Validated!")
else:
    print ("Concept Design Wrong!")
