

#1 - Two’s Complement Arithmetic

##1.4 - Multiplication and Overflow

###1.4.1
a = 10110 (= 22)
b = 00110 (=6)
00110 : Is the last bit of b equal to 1? No
00110 >> 1 = 00011 : Is the last bit of b equal to 1? Yes →  c = a << 1 = 101100
00011 >> 1 = 00001 : Is the last bit of b equal to 1? Yes →  c = c + a << 2 = 101100 + 1011000 = 10000100
00001 >> 1 = 00000 : Is the last bit of b equal to 1? No. Is b equal to 0? Yes → Finished c = 10000100 (=132)

###1.4.2


##1.4.3
a = 00111 (= 7)
b = 00101 (=5)
00101 :  last bit of b is equal to 1? Yes


#2 - Processor Design
###2.1.1 - Instruction Set Architecture

Arithmetics
  operator  addr0  addr1  addr2
	00xx x??  ---    ---    ---

  addr0 : return address
  addr1,  addr2 : operand
  operator :  xxx
    add       000
    mult      001
    sub       010
    and       011
    or        100
    xor       101

Write
  wr addr0 val
  11 ---  --- ---- ----

  addr0 : writing address
  val : immediate signed value

Load & Store
  action        addr0 addr1
  01x? ???? ??  ---   ---

  addr0 : destination's address
  addr1 : source's address
  action :  x
    load    0
    store   1

Condition
  cond imm        addr1 addr2
  10   ---- ----  ---   ---

  imm : offset from PC
  addr1, addr2 : comparison element

###2.1.2
```
Arithmetics is I format (IIII IXXX XXXX XXXX, IIIII = instruction)
Write, Condition are J format (IIXX XXXX XXXX XXXX, II = instruction)
Load & Store is R format (IIIX XXXX XXXX XXXX, III = instruction)
```
```
0010 1001 0111 0011   I format (xor addr0=101 addr1=110 addr2=011)
1110 0010 1101 1010   J format (wr addr=100 val=01011011010 -730-)
0110 1001 0111 0011   R format (store addr0=110 addr=011)
```

###2.1.3

wr addr0 128
mult addr1 addr0 addr0
mult addr1 addr0 addr1

2097152 is stored at addr1

###2.1.4

```c
wr reg1 0x200           //int *a = 0x200;
wr reg2 0               //int s = 0;
wr reg3 0               //int i = 0;
wr reg4 10              //int equal10 = 10;
wr reg6 4               //int equalSizeOfInt = 4;
wr reg7 1               //int inc = 1;
load reg5 reg1          //*a
add reg2 reg2 reg5      //s = s + *a;
add reg1 reg1 reg6      //a++;
add reg3 reg3 reg7      //i++;
cond -10 reg3 reg4       //if(i != 10) (PC = PC + 2 - 10, PC est systématiquement incrémenté de 2 et nous aimerions revenir de 4 instructions en arrière (8 octets))
```

##2.2

al  lza
