

# 1 - Two’s Complement Arithmetic

## 1.4 - Multiplication and Overflow

### 1.4.1
```
a = 10110 (=22)
b = 00110 (=6)
00110 : Is the last bit of b equal to 1? No
00110 >> 1 = 00011 : Is the last bit of b equal to 1? Yes →  c = a << 1 = 101100
00011 >> 1 = 00001 : Is the last bit of b equal to 1? Yes →  c = c + a << 2 = 101100 + 1011000 = 10000100
00001 >> 1 = 00000 : Is the last bit of b equal to 1? No. Is b equal to 0? Yes → Finished c = 10000100 (=132)
```
### 1.4.2
Nous traitons ici l'overflow sur des nombres codés sur 5 bits.  
__Idée 1__  
On peut regarder la position du bit de poids fort non nul de chaque nombre  
(sans prendre en compte le bit de signe).
Si la somme des positions des bits de poids fort est strictement supérieure à 5, alors il y a overflow.  
Malheureusement, la réciproque n'est pas vrai.  

__Ex:__  
a = 01000  
b = 00010  
Position du bit de poids fort de a : 4  
Position du bit de poids fort de b : 2  
Somme des positions : 6  
Donc c = a*b = 10000 -> overflow  

__Contre-exemple :__  
a = 00111  
b = 00011  
Position du bit de poids fort de a : 3  
Position du bit de poids fort de b : 2  
Somme des positions : 5  
Or, c = a*b = 10101 -> overflow  

__Idée 2__  
Si les bits de poids fort non nul ne sont pas précédés d'un 1, alors il n'y pas de retenue qui provoque l'overflow  

__Ex1 :__  
a = 00101  
b = 00010  
c = 01010 -> pas d'overflow  

__Ex2 :__  
a = 00110  
b = 00011  
c = 11010 -> overflow  

__Conclusion__  
Si la somme des positions des bits de poids fort non nul est strictement supérieure à 5 -> overflow  
Si la somme est égale à 5 et qu'ils sont précédés d'un 1 -> overflow  
Sinon -> pas d'overflow  
Nous n'avons pas pu prouver mathématiquement cette règle mais en raisonnant, celle-ci semble valable.

### 1.4.3
a = 00111 (=7)  
b = 00101 (=5)  
00101 : last bit of b is equal to 1? Yes  

# 2 - Processor Design
### 2.1.1 - Instruction Set Architecture

These are the instructions of our processor.  

__Arithmetics__
```
  operator  addr0  addr1  addr2
	00xx x??  ---    ---    ---

  addr0 : return address
  addr1,  addr2 : operand
  operator :  xxx
    add       000
    mult      001
    sub       010
    and       011
    or        100
    xor       101
```
__Write__
```
  wr addr0 val
  11 ---  --- ---- ----

  addr0 : writing address
  val : immediate signed value
```
__Load & Store__
```
  action        addr0 addr1
  01x? ???? ??  ---   ---

  addr0 : destination's address
  addr1 : source's address
  action :  x
    load    0
    store   1
```
__Condition__
```
  cond imm        addr1 addr2
  10   ---- ----  ---   ---

  imm : offset from PC
  addr1, addr2 : comparison element
```
### 2.1.2

Here are the three groups of instructions:  

Arithmetics is I format (IIII IXXX XXXX XXXX, IIIII = instruction)  
Write, Condition are J format (IIXX XXXX XXXX XXXX, II = instruction)  
Load & Store is R format (IIIX XXXX XXXX XXXX, III = instruction)  
```
0010 1001 0111 0011   I format (xor addr0=101 addr1=110 addr2=011)
1110 0010 1101 1010   J format (wr addr=100 val=01011011010 -730-)
0110 1001 0111 0011   R format (store addr0=110 addr=011)
```

### 2.1.3

This sequence of instruction enable to load 2097152 into a register  
```
wr   addr0 128  
mult addr1 addr0 addr0  
mult addr1 addr0 addr1  
```
2097152 is stored at addr1  

### 2.1.4

```c
int *a = 0x200;
int s = 0;
for(int i = 0; i != 10; i++)
{
	s = s + *a;
	a++;
}
```

This is the translation of the previous c code:  

```c
wr   reg1  0x200      //int *a = 0x200;
wr   reg2  0          //int s = 0;
wr   reg3  0          //int i = 0;
wr   reg4  10         //int equal10 = 10;
wr   reg6  4          //int equalSizeOfInt = 4;
wr   reg7  1          //int inc = 1;
load reg5  reg1       //*a
add  reg2  reg2 reg5  //s = s + *a;
add  reg1  reg1 reg6  //a++;
add  reg3  reg3 reg7  //i++;
cond -10   reg3 reg4  //if(i != 10) (PC = PC + 2 - 10, PC est systématiquement incrémenté de 2 et nous aimerions revenir de 4 instructions en arrière (8 octets))
```

## 2.2  
### 2.2.1  
__Data hazard__ :  
When does it occur?  
If we want to change the value of a register and the next step needs this new value which is not available in the register, the data hazard occurs.  
*Arithmetic/write/load* then *arithmetic/store/condition*  --> Data hazard  
__Example__ : *Arithmetic* operation then *store* the result --> Data hazard  
How to resolve? We should stall during one clock period. The stall unit gets the values of Addr0, Addr1, Addr2, RegWrEn in order to know if we should disable the PC and the IF/ID register.  

__Control hazard__ :  
When a condition branch is taken the value of the PC is false during two clock periods.  
How to resolve? We should flush two instructions. The flush unit gets the value of the &-comparator in order to set RegWrEn and MemWrEn to zero when it's needed.  
It is needed when Branch = 1 (meaning the instruction is a comparaison) and the value of the conparaison = 1 (output of the ALU), in one word when the branch is taken.

__Structural hazard__ :  
When does it occur?  
It can happen when an arithmetical instruction or a conditional instruction need to access the two same addresses.  
How to resolve?  
The compilator must handle this issue by using temporary registers.  

### 2.2.2  
Our processors do not need the forwarding because the stalling already take care of data hazards.  
The processor would have been faster with the forwarding, winning one clock period everytime a data hazard occurs.  

### 2.2.3  

| address | assembly_code_____ |    |    |    |     |    |     |     |     |    |     |    |    |     |    |     |     |     |    |     | hazard_counter |
|---------|--------------------|----|----|----|-----|----|-----|-----|-----|----|-----|----|----|-----|----|-----|-----|-----|----|-----|---|
| 0x100   | load reg5 reg1     | IF | ID | EX | MEM |    |     |     |     |    |     |    |    |     |    |     |     |     |    |     |   |
| 0x102   | add reg2 reg2 reg5 |    | IF | ID | ID  | EX | MEM |     |     |    |     |    |    |     |    |     |     |     |    |     | +1 (stalling) |
| 0x104   | add reg1 reg1 reg6 |    |    | IF | IF  | ID | EX  | MEM |     |    |     |    |    |     |    |     |     |     |    |     |   |
| 0x106   | add reg3 reg3 reg7 |    |    |    |     | IF | ID  | EX  | MEM |    |     |    |    |     |    |     |     |     |    |     |   |
| 0x108   | cond -10 reg3 reg4 |    |    |    |     |    | IF  | ID  | ID  | EX | MEM |    |    |     |    |     |     |     |    |     | +1 (stalling) |
| 0x10A   |                    |    |    |    |     |    |     | IF  | IF  | ID | xx  | xx |    |     |    |     |     |     |    |     | +1 (flushing) |
| 0x10C   |                    |    |    |    |     |    |     |     |     | IF | xx  | xx | xx |     |    |     |     |     |    |     | +1 (flushing) |
| 0x100   | load reg5 reg1     |    |    |    |     |    |     |     |     |    | IF  | ID | EX | MEM |    |     |     |     |    |     |   |
| 0x102   | add reg2 reg2 reg5 |    |    |    |     |    |     |     |     |    |     | IF | ID | ID  | EX | MEM |     |     |    |     | +1 (stalling) |
| 0x104   | add reg1 reg1 reg6 |    |    |    |     |    |     |     |     |    |     |    | IF | IF  | ID | EX  | MEM |     |    |     |   |
| 0x106   | add reg3 reg3 reg7 |    |    |    |     |    |     |     |     |    |     |    |    |     | IF | ID  | EX  | MEM |    |     |   |
| 0x108   | cond -10 reg3 reg4 |    |    |    |     |    |     |     |     |    |     |    |    |     |    | IF  | ID  | ID  | EX | MEM | +1 (stalling) |
