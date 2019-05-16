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

import textwrap
import binascii

def calc_mu(X, len):
    T1 = X
    for i in range(len-2):
        T1 = (T1*T1) & (2**len-1)
        T1 = (T1*X)  & (2**len-1)
        
    T1 = 2**len-T1
    return T1
    

def modsq(Av, Mv, M2v, M3v, M4v, CMv, CBv, num_words):

 
    Resv = num_words*2*[0]
    Retv = num_words*[0]

    Mult1L = [[0 for x in range(num_words//2)] for y in range(num_words//2)] 
    Mult1H = [[0 for x in range(num_words//2)] for y in range(num_words//2)] 
    
    Mult1M1 = [[0 for x in range(num_words//2)] for y in range(num_words//2)] 
    Mult1M2 = [[0 for x in range(num_words//2)] for y in range(num_words//2)] 
    
    
    
    MultCM1 = [[0 for x in range(num_words//2)] for y in range(num_words//2)]
    MultCM2 = [[0 for x in range(num_words//2)] for y in range(num_words//2)]
    MultCM = num_words*2*[0]   
    
    MultM1 = [[0 for x in range(num_words//2)] for y in range(num_words//2)]
    MultM2 = [[0 for x in range(num_words//2)] for y in range(num_words//2)]
    MultM3 = [[0 for x in range(num_words//2)] for y in range(num_words//2)]
    MultM4 = [[0 for x in range(num_words//2)] for y in range(num_words//2)]

    
    MultCB1 = [[0 for x in range(num_words//2)] for y in range(num_words//2)]
    MultCB2 = [[0 for x in range(num_words//2)] for y in range(num_words//2)]
    MultCB = num_words*2*[0]
        
    MultB1 = [[0 for x in range(num_words//2)] for y in range(num_words//2)]
    MultB2 = [[0 for x in range(num_words//2)] for y in range(num_words//2)]
    MultB3 = [[0 for x in range(num_words//2)] for y in range(num_words//2)]
    MultB4 = [[0 for x in range(num_words//2)] for y in range(num_words//2)]


    # Multiply all words
    # This generates all of the products needed
    # Each product term is used once in the accumulation phase below,
    # so these are single use temporary variables.
        
    # High and low portions
    # These are the irregular starting and ending parts of the multiply
    for i in range (num_words//2):
        for j in range (i,num_words//2,1):
            Mult1L[i][j] = Av[i] * Av[j]
            Mult1H[i][j] = Av[i + (num_words//2)] * Av[j + (num_words//2)]
        
    # Middle portion
    # This is the steady state middle portion
    for i in range (num_words//2):
        for j in range (num_words//4):    
            Mult1M1[i][j] = Av[i+ (num_words//2)] * Av[j]
            Mult1M2[i][j] = Av[i+ (num_words//2)] * Av[j+ (num_words//4)]


            

    # Accumulate C
    # This accumulates the products to produce C, the result before reduction

    # Accum L
    for i in range (num_words//2):
        for j in range (num_words//2-i):
            if (i==0):
                Resv[i+2*j] += Mult1L[j][j+i]
            else:
                Resv[i+2*j] += Mult1L[j][j+i] * 2
                
    # Accum H
    for i in range (num_words//2):
        for j in range (num_words//2-i):
            if (i==0):
                Resv[i+2*j + num_words] += Mult1H[j][j+i]
            else:
                Resv[i+2*j + num_words] += Mult1H[j][j+i] * 2


    # Accum M1
    for i in range (num_words//4):
        for j in range (num_words//2):
            Resv[num_words//2 + j + i] += Mult1M1[j][i] * 2

    # Accum M2
    for i in range (num_words//4):
        for j in range (num_words//2):
            Resv[num_words//4 + num_words//2 + j + i] += Mult1M2[j][i] * 2


    # How often do we really have to carry? Need to understand how it will work since this seems like
    # a long chain.
    for i in range (num_words*2-1):
        Resv[i+1] += Resv[i]>>16
        Resv[i]    = Resv[i]&(2**16-1)
    



    # Montgomery reduction
    # C*MC
    for i in range (num_words//2):
        for j in range (num_words//4):
            MultCM1[i][j] = Resv[i]*CMv[j]
            MultCM2[i][j] = Resv[i]*CMv[j+ (num_words//4)]

    # Accumulate in MultCM
    for i in range (num_words//4):
        for j in range (num_words//2):
            MultCM[j + i] += MultCM1[j][i]

    for i in range (num_words//4):
        for j in range (num_words//2):
            MultCM[num_words//4 + j + i] += MultCM2[j][i]

    # Carry MultCM
    for i in range (num_words):
        MultCM[i+1] = MultCM[i+1] + (MultCM[i]>>16)
        MultCM[i] = MultCM[i]&(2**16-1)
    
    
    
    
    # Generate T1L*M products
    for i in range (num_words//2):
        for j in range (num_words//4):    
            MultM1[i][j] = MultCM[i]*Mv[j]
            MultM2[i][j] = MultCM[i]*Mv[j+ (num_words//4)]
            MultM3[i][j] = MultCM[i]*Mv[j+ (2*(num_words//4))]
            MultM4[i][j] = MultCM[i]*Mv[j+ (3*(num_words//4))]

            
            

    # Accumulate T1L*M
    for i in range (num_words//4):
        for j in range (num_words//2):
            Resv[j + i] += MultM1[j][i]
    
    for i in range (num_words//4):
        for j in range (num_words//2):
            Resv[1*(num_words//4) + j + i] += MultM2[j][i]

    for i in range (num_words//4):
        for j in range (num_words//2):
            Resv[2*(num_words//4) + j + i] += MultM3[j][i]
            
    for i in range (num_words//4):
        for j in range (num_words//2):
            Resv[3*(num_words//4) + j + i] += MultM4[j][i]
            
            
            
            
    # Barrett part
    # C*BC
    for i in range (num_words//2):
        for j in range (num_words//4):    
            MultCB1[i][j] = Resv[i + 3*(num_words//2)]*CBv[j]
            MultCB2[i][j] = Resv[i + 3*(num_words//2)]*CBv[j+ (num_words//4)]

    # Accumulate in MultCB
    for i in range (num_words//4):
        for j in range (num_words//2):
            MultCB[j + i] += MultCB1[j][i]
            

    for i in range (num_words//4):
        for j in range (num_words//2):
            MultCB[num_words//4 + j + i] += MultCB2[j][i]

    # Carry MultCB
    for i in range (num_words-1):
        MultCB[i+1] = MultCB[i+1] + (MultCB[i]>>16)
        MultCB[i] = MultCB[i]&(2**16-1)



    # Generate T2H*M products
    for i in range (num_words//2):
        for j in range (num_words//4):    
            MultB1[i][j] = MultCB[i+(num_words//2)]*Mv[j]
            MultB2[i][j] = MultCB[i+(num_words//2)]*Mv[j+ (num_words//4)]
            MultB3[i][j] = MultCB[i+(num_words//2)]*Mv[j+ (2*(num_words//4))]
            MultB4[i][j] = MultCB[i+(num_words//2)]*Mv[j+ (3*(num_words//4))]





    # Accumulate T2H*M
    for i in range (num_words//4):
        for j in range (num_words//2):
            Resv[(num_words//2) + j + i] -= MultB1[j][i]
    
    for i in range (num_words//4):
        for j in range (num_words//2):
            Resv[(num_words//2) + 1*(num_words//4) + j + i] -= MultB2[j][i]

    for i in range (num_words//4):
        for j in range (num_words//2):
            Resv[(num_words//2) + 2*(num_words//4) + j + i] -= MultB3[j][i]
            
    for i in range (num_words//4):
        for j in range (num_words//2):
            Resv[(num_words//2) + 3*(num_words//4) + j + i] -= MultB4[j][i]
            
            

        
            
    # Partial reduction
    for i in range (2*num_words-1):
        Resv[i+1] = Resv[i+1] + (Resv[i]>>16)
        Resv[i] = Resv[i]&(2**16-1)


        
    # Extract the result from the middle of Resv
    for i in range (num_words):
        Retv[i] = Resv[i+(num_words//2)]

    # Save any redundant bits
    Retv[num_words-1] += Resv[num_words+(num_words//2)]<<16
        
        
    # Final reduction based on most signifant word overflow
    if ((Retv[num_words-1]>>16) == 1):  
        for i in range (num_words):
            Retv[i] -= Mv[i]

    elif ((Retv[num_words-1]>>16) == 2):  
        for i in range (num_words):
            Retv[i] -= M2v[i]  

    elif ((Retv[num_words-1]>>16) == 3):  
        for i in range (num_words):
            Retv[i] -= M3v[i]   
    else:
        if ((Retv[num_words-1]>>16) != 0):  
            print("take care of this also", (Retv[num_words-1]>>16))
    
    
    # Partial reduction
    for i in range (num_words-1):
        Retv[i+1] = Retv[i+1] + (Retv[i]>>16)
        Retv[i] = Retv[i]&(2**16-1)
        

        
    del Mult1L
    del Mult1H
    del Mult1M1
    del Mult1M2
    del MultCM1
    del MultCM2
    del MultCM
    del MultM1   
    del MultM2   
    del MultM3   
    del MultM4 
    
    del MultCB1
    del MultCB2
    del MultCB
    del MultB1   
    del MultB2   
    del MultB3   
    del MultB4 
    del Resv
    

    return Retv


# Convert from polynomial to integer and out of montgomery space
def poltoint (Polv, num_coeff, M, mu):

    Res = 0
    for i in range (num_coeff):
        Res = Res + ( Polv[i] << (16*i) )
        
    T1 = Res & (2**((num_coeff*16)//2)-1)
    T2 = (T1*mu) & (2**((num_coeff*16)//2)-1)
    T3 = T2*M
    Res = (Res + T3) 
    Res = Res >> ((num_coeff*16)//2)
    Res = Res % M
    return Res
    
    

# Solve a small timelock puzzle
size = 2048
num_words = size//16
X = 2
numtest = 1000
M = int(''.join(textwrap.dedent("""
    105166528022527798431705271305083153271905167309082936062237
    875135108916430921973837383917203706347775182028534615355223
    417356941952078088378512191864458014795760160399651688747292
    417054895625148685196270565622239606996305273360453763244589
    678900932252222464531674533422500855492661601895626223029595
    208807882791839550326277150183060433150214975293234171115461
    501970809133171220204730435554841778490178338995725390364164
    357656089835284535323531864081697993560557519746530724613154
    323040692026418463571934152623560405791105826098599526772821
    897662925573095464419934572972734862220466979588165351746682
    81266248259210339""").split("\n")))
Z = int(''.join(textwrap.dedent("""
    869460014143745198343907872022121547045298102699963289256818
    682055608801137914744590737042198785541601713993261790859955
    320045877588883312835732424347874921457602436314132375009085
    907515462780106719552091250724077358808064334915246188158233
    737872686183361703308411462503453416437767648592671459107151
    424168479099704410312878298220701487856414239255033133157039
    609423112868781436959889352211844164170132148475698871344018
    257140452777126769499170418189455300534090263878123508822268
    851503285278757685070743598918447811892907403238851522593464
    637179741947173190032478938281192690043542660537523450003484
    6541046351535602""").split("\n")))

    

M2 = 2*M
M3 = 3*M
M4 = 4*M

CB = (2**(size + (size//2) ) ) // M
CM = calc_mu(M, (size//2))

X = (X<<(size//2)) % M


Xiv = num_words*[0]
Mv = num_words*[0]
M2v = num_words*[0]
M3v = num_words*[0]
M4v = num_words*[0]
CMv = num_words*[0]
CBv = num_words*[0]

for i in range (num_words):
    Xiv[i] = (X>>(16*i))&(2**16-1)
    Mv[i] = (M>>(16*i))&(2**16-1)
    M2v[i] = (M2>>(16*i))&(2**16-1)
    M3v[i] = (M3>>(16*i))&(2**16-1)
    M4v[i] = (M4>>(16*i))&(2**16-1)


    
M2v[num_words-1] = (M2>>(16*(num_words-1)))
M3v[num_words-1] = (M3>>(16*(num_words-1)))
M4v[num_words-1] = (M4>>(16*(num_words-1)))
    
for i in range (num_words//2):
    CMv[i] = (CM>>(16*i))&(2**16-1)
    CBv[i] = (CB>>(16*i))&(2**16-1)
    
CBv[num_words//2-1] = (CB>>(16*(num_words//2-1)))


Res1 = poltoint(Xiv, num_words, M, CM)
Res1 = (Res1*Res1) % M 



for i in range (numtest):
    # Xiv is the only thing that changes
    Xiv = modsq(Xiv, Mv, M2v, M3v, M4v, CMv, CBv, num_words)

    # convert intermediate result to integer (in software)
    Res2 = poltoint(Xiv, num_words, M, CM)

    if (Res1 != Res2):
         print(i, " Wrong")
         break
        
    Res1 = (Res2*Res2) % M 

if (i == numtest-1):
    print ("Concept Design Validated!")
else:
    print ("Concept Design Wrong!")

print (Res2)

print (binascii.unhexlify(hex(Res2 ^ Z)[2:]))
