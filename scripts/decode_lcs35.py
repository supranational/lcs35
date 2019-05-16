#!/usr/bin/python3

'''
Copyright 2019 Erdinc Ozturk, SABANCI UNIVERSITY
Copyright 2019 Supranational LLC

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
import binascii
import textwrap

# Compute A^E mod n
def modexp(A,E,n):
    expolen = E.bit_length()
    C = 1
    for i in range (expolen):
        C = (C*C)%n
        current_e_bit = ((E>>(expolen-1-i))%2)
        if (current_e_bit==1):
            C = (C*A)%n
        
    return C

n = int(''.join(textwrap.dedent("""
    631446608307288889379935712613129233236329881833084137558899077270
    195712892488554730844605575320651361834662884894808866350036848039
    658817136198766052189726781016228055747539383830826175971321892666
    861177695452639157012069093997368008972127446466642331918780683055
    206795125307008202024124623398241073775370512734449416950118097524
    189066796385875485631980550727370990439711973361466670154390536015
    254337398252457931357531765364633198906465140213398526580034199190
    398219284471021246488745938885358207031808428902320971090703239693
    491996277899532332018406452247646396635593736700936921275809208629
    3198727008292431243681""").split("\n")))

z = int(''.join(textwrap.dedent("""
    427338526681239414707099486152541907807623930474842759553127699575
    212802021361367225451651600353733949495680760238284875258690199022
    379638588291839885522498545851997481849074579523880422628363751913
    235562086585480775061024927773968205036369669785002263076319003533
    000450157772067087172252728016627835400463807389033342175518988780
    339070669313124967596962087173533318107116757443584187074039849389
    081123568362582652760250029401090870231288509578454981440888629750
    522601069337564316940360631375375394366442662022050529545706707758
    321979377282989361374561414204719371297211725179287931039547753581
    0302267611143659071382""").split("\n")))
    
t = 79685186856218
seed = 712238904468723561162000937465778229877598711342253664788091132335

p = modexp(5,seed,(2**1024))
while (1):
    T1 = n%p    
    if (T1==0):
        break
    p = p + 1
    
q = n//p

phi_n = (p-1)*(q-1)
u = modexp(2,t,phi_n)
w = modexp(2,u,n)

Res = w^z

print(binascii.unhexlify(hex(Res)[2:]))
