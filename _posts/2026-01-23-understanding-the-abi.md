---
title: 'Understanding the ABI by Observation'
date: 2026-01-23
permalink: /posts/2026-01-23-understanding-the-abi/
tags:
  - discuss
  - learning
  - architecture
  - beginners
---

### 📌Table of Contents

- [What Exactly Is an ABI?](#what-exactly-is-an-abi)
- [The ABI Contract: What It Defines](#the-abi-contract-what-it-defines)
   - [A. Calling Convention](#a-calling-convention)
   - [B. Data Layout & Alignment](#b-data-layout-and-alignment)
   - [C. Stack Frame](#c-stack-frame)
   - [D. Name Mangling (C++)](#d-name-mangling-c)

- [Target Context: ARM Cortex-M (AAPCS)](#target-context-arm-cortexm-aapcs)
- [Practical Exploration: ABI in Action with C Functions](#practical-exploration-abi-in-action-with-c-functions)
   - [Function with 2 Arguments (`add2`)](#function-with-2-arguments-raw-add2-endraw-)
   - [Function with 4 Arguments (`add4`)](#function-with-4-arguments-raw-add4-endraw-)
   - [Function with 5 Arguments (`add5`)](#function-with-5-arguments-raw-add5-endraw-)
- [Verification: Which Way Does the Stack Grow?](#verification-which-way-does-the-stack-grow)
- [Data Layout & Alignment: The Offset Proof](#data-layout-amp-alignment-the-offset-proof)
- [ELF Symbols and Function Size (`nm -S`)](#elf-symbols-and-function-size-raw-nm-s-endraw-)
- [Name Mangling: C vs C++](#name-mangling-c-vs-c)
- [Key Takeaways](#key-takeaways)

## What Exactly Is an ABI?

An **Application Binary Interface (ABI)** is a low-level contract that defines how *compiled binaries* interact.

It ensures that when **Function A** calls **Function B**, both sides agree on:

- where arguments are located
- where return values appear
- how control returns to the caller

This remains true even if:

- the code was compiled with different compilers
- parts are written in different languages (C, C++, Assembly)
- libraries are precompiled

Without an ABI, `Module_A.o` might pass an argument in a register while `Module_B.o` expects it on the stack. The result is not a compiler error  it is silent runtime failure.

## The ABI Contract: What It Defines

An ABI specifies rules that compiled code must obey so that independently compiled binaries can interoperate correctly at runtime.

### A. Calling Convention

The calling convention defines:

- **Argument Passing**
Which arguments go in registers, which go on the stack, and in what order.
- **Return Values**
Which register holds the result (e.g., `r0` on ARM).
- **Register Preservation**
    - **Caller-saved (volatile)**: the caller must save them if needed.
    - **Callee-saved (non-volatile)**: the callee must preserve and restore them.
- Under AAPCS, registers `r0–r3` and `r12` are caller-saved, while `r4–r11` are callee-saved.

### B. Data Layout and Alignment

The ABI defines:

- **Type Size**
For example, `int` is 32-bit on ARM EABI.
- **Alignment Rules**
32-bit data must be aligned to 4-byte boundaries.
- **Structure Padding**
Compilers insert padding bytes to preserve alignment.

This is why `sizeof(struct)` is often larger than the sum of its members.

### C. Stack Frame

The ABI governs stack behavior:

- Stack growth direction
- Where the return address lives
- How local variables are addressed

The ABI specifies stack alignment and what must be preserved at function boundaries, while the compiler decides how to implement the prologue and epilogue.

### D. Name Mangling (C++)

C++ supports function overloading, so function names must encode type information.

The ABI standardizes this encoding so binaries can link correctly across compilers.

## Target Context: ARM Cortex-M (AAPCS)

On STM32 and other Cortex-M systems, the ABI is **AAPCS**.

Key rules:

- First 4 integer arguments → `r0–r3`
- 5th and rest arguments → stack
- Return value → `r0`
- Return address → `lr`

Everything below is verified against this ABI.

## Practical Exploration: ABI in Action with C Functions

We examine unoptimized (`-O0`) and optimized (`-O2`) output to separate:

- **ABI rules** from **compiler implementation details**

### Function with 2 Arguments (`add2`)

```c
int add2(int a, int b) {
    return a + b;
}
```

**At optimization `-O0`**

![add 2 with optimization disabled](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/le96kpecvrwwt7npgi7y.png)

At `-O0`, the assembly contains stack setup, spills, and reloads.

This noise exists for debugging — not because the ABI requires it.

**At optimization `-O2`**


![add 2 with optimization -O2](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/arhexh0kgfkmrs7c54uf.png)

At `-O2`, only the ABI-mandated behavior remains:

- Arguments arrive in `r0`, `r1`
- Result placed in `r0`
- Return via `bx lr`

**Key insight:**

Everything except argument location, return value, and return mechanism is compiler detail.

### Function with 4 Arguments (`add4`)

```c
int add4(int a,int b,int c,int d) {
return a + b + c + d;
}
```

**with optimization `-O0`**


![add 4 with optimization disabled](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/59uv23i2kc8l78y1gh38.png)

**with optimization `-O2`**


![add 4 with optimization -O2](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/eshqe1knjlega02q7i4d.png)

### ABI Guarantees on Entry

- `r0` → `a`
- `r1` → `b`
- `r2` → `c`
- `r3` → `d`

This function uses **all available argument registers**.

No stack access is required to receive arguments.

> For up to four arguments, the ARM ABI passes all parameters in registers.


### Function with 5 Arguments (`add5`)

```c
int add5(int a,int b,int c,int d,int e) {
return a + b + c + d + e;
}
```

This function crosses an **ABI boundary**.

### The ABI Rule

- `r0–r3` → first four arguments
- **5th argument → stack**

This is the first time the stack becomes mandatory.

**with optimization `-O0`**


![add 5 with optimization disabled](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/kvhxsodw41o90nazw04w.png)

**with optimization `-O2`**


![add 5 with optimization -O2](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/dzwz3sa91j28pyq26v35.png)

At `-O2`, the instruction:

```nasm
ldr ip, [sp]
```

proves that the fifth argument must be fetched from memory.

This behavior is **ABI law**, not optimization or compiler behavior.

## Verification: Which Way Does the Stack Grow?

Rather than assuming, we verify it directly from assembly.

### Observation

```nasm
str fp, [sp, #-4]!
sub sp, sp, #20
```

Both instructions **subtract from `sp`** to allocate space.

### Conclusion

If allocating space requires decrementing the stack pointer, the stack grows **toward lower memory addresses**.

> Verified: The stack grows downward.

## Data Layout & Alignment: The Offset Proof

### Claim

A 32-bit `int` must be 4-byte aligned.

A `char` followed by an `int` requires padding.

### Experiment

```c
struct MyPackedStruct {
char c;
int  i;
};

int get_i(struct MyPackedStruct *s) {
return s->i;
}
```

### Optimized Assembly (`O2`)


![type size optimized -O2](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ocaay5jom43obx3uixl5.png)

### Optimization disabled (`O0`)


![type size optimization disabled](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ukzmkq9224p8lip210nm.png)

### Observation

The field `i` is accessed at offset `#4`.

If there were no padding, the offset would be `#1`.

### Conclusion

- `int` is 4 bytes wide
- The compiler inserted 3 bytes of padding
- This layout is **ABI-mandated**
- Optimization does not change it

## ELF Symbols and Function Size (`nm -S`)

```c
int aman;
intget_i(struct MyPackedStruct *s) {
return s->i;
}
```

### Command

```bash
arm-none-eabi-nm -S main.o
```

### Output

```
0000000000000004 B aman
0000000000000028 T get_i

```

### Interpretation

`aman` is 4 bytes → confirms `int` size.

- **`B` (BSS)**: uninitialized global data

`get_i` occupies 0x28 bytes (40 bytes).

- **`T` (Text)**: executable code

At `-O0`, this corresponds to 10 ARM instructions:

```c
10 × 4 bytes = 40 bytes = 0x28
```

At `-O2`, the function shrinks to 2 instructions (8 bytes).

> Function size is a compiler artifact; ABI rules are not.
> 

## Name Mangling: C vs C++

### C

```c
int add(int a,int b) {
	return a + b;
}
// C file
```

run this command and you’ll get this symbol add

```

arm-none-eabi-nm.exe add.o
00000000 T add

```

### C++

```cpp
int add(int a,int b) {
	return a + b;
}
// C++ file
```

run this command and you’ll get this symbol _Z3addii

```
arm-none-eabi-nm.exe add.o
00000000 T _Z3addii
```

This encodes function name and parameter types.

Using:

```cpp
extern"C" int add(int,int);

int add(int a,int b) {
	return a + b;
}

```

disables mangling and restores the C symbol name.

## Key Takeaways

> The ABI governs how functions are called, how data is laid out, how the stack behaves, and how symbols are named — all of which can be verified directly from generated binaries.
> 

Once you learn to **observe** the ABI instead of memorizing it, low-level code stops being mysterious and starts being predictable.