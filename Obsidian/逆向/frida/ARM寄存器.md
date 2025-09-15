## 通用寄存器

### X0~X30

ARM64 有`31`个通用寄存器

- 使用`X0~X30`的时候表示64位，
- 使用`W0~W30`时表示32位，取低32位 高32位填充0

指令编码中使用 `0b11111（31）` 用来表示`ZR`（0 寄存器），**仅表示0，不表示ZR是个物理寄存器**

### 常用寄存器

- `X0~X7` 用来传递函数的参数，如果有更多的参数需要入栈，也可以使用X0存放函数返回值
    
- `SP`(Stack Pointer) 栈指针寄存器。指向栈的顶部，可以通道WSP寄存器访问栈指针最低有效的32位。
    
- `FP` (Frame Pointer)即：X29 帧指针寄存器。指向栈底部
    
- `LR`(Link Register)即：X30 链接寄存器，存储函数调用完成时的返回地址。用来做函数调用栈追踪，程序崩溃时，就是借用LR来实现调用路径打印。
    
- `PC`(Program Counter)：保存将要执行的下一条指令内存地址。通常在调试时看到的PC值就是断点的地方。
    

## 浮点寄存器

由于浮点计算的特殊性，CPU专门提供了用于浮点计算的寄存器。

ARM64 提供了32个浮点寄存器`V0~V31` 每个寄存器的大小是128位。可以通过`Bn(Byte)`、`Hn(Half Word)`、`Sn(Single Word )`、`Dn(Double Word)`、`Qn(Quad Word)`来访问不同的位数。

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/561ce6d3-22a3-48f2-993e-da23a81bb76f/88c59976-d804-4fbc-b207-8d2afc6b31d4/Untitled.png)

## 状态寄存器

状态寄存器用来保存指令运行结果的一些信息，比如相加的结果是否溢出，是否为0，是否为负数。**CPU 的某些指令会根据运行的结果来设置状态寄存器的标志位，而某些指令则是根据这些状态寄存器的值来进行处理**。ARM64 提供了一个32位的**`CPSR`**(Current Program Status Register)寄存器来作为状态寄存器。

低8位（包括M[0~4]、T、F、I）：控制位，程序无法修改。

28-31位（V、C、Z、N）：条件代码标志位，他们的内容可以被算术或逻辑运算修改。

状态寄存器的内容由CPU内部进行置位，在程序中不能将某个数值赋值给它。

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/561ce6d3-22a3-48f2-993e-da23a81bb76f/c8954468-5d48-4bc7-8650-a056ca766e3d/Untitled.png)

- `N（Negative）` :当两个有符号整数进行运算时，N=1 表示结果为负数，N=0 表示运行结果为正数或零。
- `Z（Zero）`：Z=1 表示运算结果为零；Z=0 表示运算结果为非0。
- `C（Carry）`：当加法运算结果产生进位时（无符号数溢出），C=1，否则C=0；当减法运算结果产生借位（无符号数溢出）时，C=0，否则 C=1。
- `V（Overflow）`：在加/减法运算中，当操作数和运算结果为二进制补码表示的带符号数时，V=1 表示符号位溢出。

## 指令集格式

指令集的格式如下：`＜opcode>｛＜cond>}｛S｝ <Rd>，<Rn> ｛，<shift_op2>}` 其中`<>`是必须的`{}`是可选的。

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/561ce6d3-22a3-48f2-993e-da23a81bb76f/d8e50295-dd6d-4538-af8b-a9fa3472dba7/Untitled.png)

### 常用算术指令

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/561ce6d3-22a3-48f2-993e-da23a81bb76f/1e405fa9-4715-4289-a9c8-32ca05892880/Untitled.png)

### 条件跳转指令

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/561ce6d3-22a3-48f2-993e-da23a81bb76f/dc331f10-019e-4eac-92d4-e91006f45ca6/Untitled.png)

### 无条件跳转指令

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/561ce6d3-22a3-48f2-993e-da23a81bb76f/fe54fa16-f8e1-46ae-b9b4-1d03f1e99d6d/Untitled.png)