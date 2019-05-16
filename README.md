# Cryptophage LCS35 Solver

This repository contains designs developed by the www.cryptophage.com collaboration that were used to solve the MIT LCS35 timelock puzzle. 

These are prototype designs developed specifically to solve the puzzle and are released AS-IS. 

Enjoy!

## Designs

Three different designs are represented here:

**13cc**

This is a lookup-table based reduction design with a 13 clock cycle latency based on the architecture presented by Erdinc Ozturk at MIT VDF Day 2019 (https://dci.mit.edu/vdfday).

**9cc**

This is a lookup-table based reduction design with a 9 clock cycle latency based on the architecture presented by Erdinc Ozturk at MIT VDF Day 2019 (https://dci.mit.edu/vdfday).

scripts/sq2k_lut.py is a python implementation of the same. 

**Barrett/Montgomery**

scripts/sq2k_barrett_mont.py is a python implementation of the Barrett+Montgomery reduction approach presented by Erdinc Ozturk at Stanford VDF Day 2019. 

## Files

**13cc**

Files applicable to the 13cc design are:
```
13cc/add_16_38.sv
13cc/add_16_66.sv
13cc/csa_22.sv
13cc/curr_mul.sv
13cc/Preg.sv
13cc/sq2K_datapath.sv
common/csa_25.sv
common/FA.sv
common/mul_17x17_asic.sv
```

In addition, the lookup tables must be generated as follows:
```
cd 13cc/mem
./sq2K_newred_util.py
```

**9cc** 

Files applicable to the 13cc design are:
```
9cc/sq2K_datapath.sv
9cc/curr_mul.sv
common/Preg.sv
common/add_16_8.sv
common/accum_PP10.sv
common/add_16_9.sv
common/add_16_66_B.sv
common/FA.sv
common/csa_23.sv
common/csa_20.sv
common/csa_25.sv
common/mul_17x17_asic.sv
common/accum_PP4.sv
common/accum_PP6.sv
common/accum_Resv3C.sv
common/add_16_6.sv
common/accum_Resv3B.sv
common/add_16_5.sv
common/add_16_66.sv
common/accum_PP2.sv
common/add_16_4.sv
common/accum_Resv1A.sv
common/csa_19.sv
common/accum_Resv1B.sv
common/accum_Resv3A.sv
```

In addition, the lookup tables must be generated as follows:
```
cd 9cc/mem
./sq2K_newred_util.py
```


