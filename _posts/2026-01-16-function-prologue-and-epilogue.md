---
title: 'Function Prologue and Epilogue in ARM: What Really Happens When a Function Enters and Exits'
date: 2026-01-16
permalink: /posts/2026-01-16-function-prologue-and-epilogue/
tags:
  - discuss
  - learning
  - architecture
  - beginners
---
Function prologue and epilogue are the instructions executed at the beginning and end of a function to preserve required CPU state and manage the stack. Although they are not visible in C code, the compiler automatically inserts these sequences to ensure correct function execution. In this article, we examine how ARM compilers use prologue and epilogue to safely handle function calls at the assembly level.

## Table of Contents

- [Why Function Prologue and Epilogue Exist](#why-function-prologue-and-epilogue-exist)
- [The Rulebook: AAPCS](#the-rulebook-aapcs)
- [What Happens at Function Entry: The Prologue](#what-happens-at-function-entry-the-prologue)
- [What Happens at Function Exit: The Epilogue](#what-happens-at-function-exit-the-epilogue)
- [From C Code to Assembly: A Practical Example](#from-c-code-to-assembly-a-practical-example)
  - [Understanding the Assembly Output](#understanding-the-assembly-output)
  - [Prologue — Setting Up the Stack Frame](#prologue-setting-up-the-stack-frame)
  - [Function Body — Execution of C Logic](#function-body-execution-of-c-logic)
  - [Epilogue — Cleaning Up and Returning](#epilogue-cleaning-up-and-returning)
- [Leaf vs Non-Leaf Functions](#leaf-vs-nonleaf-functions)
- [Prologue and Epilogue in Interrupts and Context Switching](#prologue-and-epilogue-in-interrupts-and-context-switching)
- [Naked Functions: Skipping Prologue and Epilogue (When and Why)](#naked-functions-skipping-prologue-and-epilogue-when-and-why)
- [Conclusion](#conclusion)


## Why Function Prologue and Epilogue Exist
On ARM, function calls reuse the same CPU registers and stack memory. Without a defined mechanism to save and restore this state, operations performed inside a function corrupt the caller’s execution context without a defined calling convention, operations performed inside a function would corrupt the caller’s execution context.. To prevent this, the compiler automatically inserts a function prologue and epilogue that preserve required registers and restore the stack state, ensuring correct program execution.

---

## The Rulebook: AAPCS
Before we look at the assembly, we need to understand why the code is generated this way.

In the ARM ecosystem, all toolchains follow a strict set of rules called the **AAPCS** (Procedure Call Standard for the ARM Architecture). This standard defines:
- Which registers a function can overwrite freely (Caller-Saved: `R0-R3`, `R12`).
- Which registers a function must preserve and restore (Callee-Saved: `R4-R11`).
- How the stack is managed (Full Descending Stack, 8-byte alignment).
- The AAPCS also defines how function arguments are passed and how return values are delivered.

The Prologue and Epilogue are simply the compiler's way of enforcing these rules consistently across all functions.

---

## What Happens at Function Entry: The Prologue
When a function is called on ARM Cortex-M, the compiler executes a short sequence of instructions at the function entry known as the prologue. These instructions run before any user-defined C code in function and prepare the stack and registers according to the AAPCS. A typical Cortex-M prologue looks like this (details will be examined in the example below)

---

## What Happens at Function Exit: The Epilogue
At function return, the compiler inserts a short sequence of instructions known as the epilogue. Its role is to undo the changes made by the prologue and restore the CPU state so execution can safely resume in the caller.

The exact instructions used depend on the function, but the epilogue typically releases the stack frame, restores saved registers, and returns control to the caller. These steps are shown in the assembly example below.

---

## From C Code to Assembly: A Practical Example
To make this concrete, the following example was compiled for an STM32F407 (ARM Cortex-M4) with optimizations disabled (`-O0`). The generated assembly uses the `Thumb-2` instruction set, as is standard on Cortex-M cores. We focus on the assembly generated for `compute_sum()`, a non-leaf function that calls another function.

```C
int add(int a, int b){
    return a + b;
}

int compute_sum(int x, int y){
    int temp1 = x * 2;
    int temp2 = y * 3;

    int result = add(temp1, temp2);

    return result;
}

int main(void){
    int value;
    value = compute_sum(10, 20);
    while (1);
}

```
Assembly generated for `compute_sum` function
```asm
080002f8 <compute_sum>:
 80002f8:	b580      	push	{r7, lr}
 80002fa:	b086      	sub	sp, #24
 80002fc:	af00      	add	r7, sp, #0
 80002fe:	6078      	str	r0, [r7, #4]
 8000300:	6039      	str	r1, [r7, #0]
 8000302:	687b      	ldr	r3, [r7, #4]
 8000304:	005b      	lsls	r3, r3, #1
 8000306:	617b      	str	r3, [r7, #20]
 8000308:	683a      	ldr	r2, [r7, #0]
 800030a:	4613      	mov	r3, r2
 800030c:	005b      	lsls	r3, r3, #1
 800030e:	4413      	add	r3, r2
 8000310:	613b      	str	r3, [r7, #16]
 8000312:	6939      	ldr	r1, [r7, #16]
 8000314:	6978      	ldr	r0, [r7, #20]
 8000316:	f7ff ffe1 	bl	80002dc <add>
 800031a:	60f8      	str	r0, [r7, #12]
 800031c:	68fb      	ldr	r3, [r7, #12]
 800031e:	4618      	mov	r0, r3
 8000320:	3718      	adds	r7, #24
 8000322:	46bd      	mov	sp, r7
 8000324:	bd80      	pop	{r7, pc}
```

This function allocates local variables and calls another function, which makes it a non-leaf function.

![assembly code for the compute_sum function](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/6klt34nkyt9jg4yvywnf.png)

## Understanding the Assembly Output
The image above shows the disassembly of the `compute_sum()` function. The instructions are visually divided into three regions: Prologue, Function Body, and Epilogue. Each region serves a distinct purpose in the execution of the function.

### Prologue — setting up the stack frame
The prologue appears at the top of the function:
```asm
push {r7, lr}
sub  sp, #24
add  r7, sp, #0
```
This sequence is the function prologue and it is inserted automatically by the compiler.
At function entry, the compiler:
- Saves `r7` and `lr` so the caller’s frame pointer and return address are not lost.
- Reserves 24 bytes on the stack for local variables and compiler-generated temporaries
- Even though the function defines only three `int` variables (12 bytes), extra space is allocated to maintain alignment and to give the compiler room for temporary values, which is common when optimizations are disabled (`-O0`)
- Sets up `r7` as a frame pointer, allowing all local variables to be accessed using fixed offsets regardless of changes to `sp`

Together, these steps create a private stack frame for the function, ensuring it can execute and return without disturbing the caller’s state.

### Function Body — execution of C logic
The middle section of the image corresponds to the actual work performed by `compute_sum()`.
- The input parameters (`x` and `y`) are first stored on the stack so they can be reused
- `temp1` is calculated as `x * 2` using a left-shift operation
- `temp2` is calculated as `y * 3` using a shift followed by an add
- The computed values are loaded into registers and passed to `add()`

The instruction `bl <add>` performs a function call and overwrites the Link Register (`lr`). Because of this, `lr` must be saved earlier in the prologue. This is what makes `compute_sum()` a non-leaf function.

### Epilogue — cleaning up and returning
This sequence forms the function epilogue and restores the caller’s state.

```asm
adds r7, #24
mov  sp, r7
pop  {r7, pc}
```
- The stack space allocated for the function is released
- The original frame pointer (r7) is restored
- The return address is loaded into the program counter (pc), returning execution to the caller

The epilogue exactly mirrors the prologue, ensuring the function exits with the CPU state unchanged.

--- 

## Leaf vs Non-Leaf Functions
Not all functions require the same prologue and epilogue.

**A leaf function** is a function that does not call any other function. Since it never executes a BL instruction, the Link Register (LR) is not overwritten. As a result, the compiler may omit saving LR and, in some cases, avoid creating a full stack frame altogether.

**A non-leaf function**, on the other hand, calls one or more functions. Because a BL instruction overwrites LR, the function must save LR in its prologue and restore it in the epilogue. Non-leaf functions almost always require a stack frame to preserve state and manage local variables.

Whether a function is leaf or non-leaf directly influences how much code the compiler inserts at function entry and exit.

---

## Prologue and Epilogue in Interrupts and Context Switching
On ARM Cortex-M, a similar mechanism appears in interrupt handling. When an interrupt occurs, the hardware automatically pushes an architecturally defined subset of the CPU state onto the stack and restores it on return. RTOS context switching extends this idea in software. While the mechanisms differ, the goal is the same: preserving execution context.

---

## Naked Functions: Skipping Prologue and Epilogue (When and Why)
By default, the compiler generates a prologue and epilogue to manage the stack and preserve registers according to the AAPCS. Using `__attribute__((naked))`, this behavior can be disabled entirely.

A naked function is compiled without any automatically generated prologue or epilogue. The compiler does not save or restore registers, allocate stack space, enforce stack alignment, or generate a return sequence. All responsibility for preserving CPU state and managing the stack falls entirely on the programmer.

This is only appropriate in very low-level code, such as task context switching, interrupt entry routines, or early boot initialization. Because naked functions bypass the ABI completely, the compiler does not protect register or stack state. Even small mistakes can therefore cause stack corruption or hard faults.

For this reason, naked functions should not be used in normal application code. They are intended only for situations where compiler-generated prologue and epilogue code must be avoided and the programmer is prepared to manage the CPU state manually.

---

## Conclusion
Function prologue and epilogue are fundamental to how ARM compilers implement safe and predictable function calls. By following the AAPCS, the compiler ensures registers, stack state, and return flow are preserved across function boundaries. Understanding how these mechanisms work especially at the assembly level makes it easier to analyze stack usage, debug low-level issues, and write reliable embedded software.
