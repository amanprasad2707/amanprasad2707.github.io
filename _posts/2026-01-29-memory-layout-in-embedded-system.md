---
title: 'Memory Layout in Embedded Systems: How C Code Really Ends Up in FLASH and RAM'
date: 2026-01-29
permalink: /posts/2026-01-29-memory-layout-in-embedded-system/
tags:
  - discuss
  - learning
  - programming
  - beginners
---

The CPU does not understand variables, types, or sections. It only executes raw commands to "read address X" or "write address Y." It only understands **memory addresses.**

When you declare a variable, you are effectively requesting storage. The **Compiler** assigns it to a logical section (like `.data` or `.bss`), and the **Linker** calculates its final physical address based on the rules defined in your **Linker Script**.
If you don't understand this mapping, you are blind to the root causes of memory corruption and performance bottlenecks. In embedded systems, correct logic placed in the wrong memory is still a broken system.

### Table of Contents
- [From C Code to Binary: Who Decides Memory Placement](#from-c-code-to-binary-who-decides-memory-placement)
- [FLASH Memory Layout (Non-Volatile Sections)](#flash-memory-layout-nonvolatile-sections)
- [RAM Memory Layout (Volatile Sections)](#ram-memory-layout-volatile-sections)
- [Startup Code: The Invisible Hand Before main()](#startup-code-the-invisible-hand-before-raw-main-endraw-)
- [The Truth Table: Where Does It Go?](#the-truth-table-where-does-it-go)
- [Verifying Memory Placement](#verifying-memory-placement)
- [Final Rules to Remember](#final-rules-to-remember)
- [Conclusion](#conclusion)


## From C Code to Binary: Who decides memory placement
Your C code doesn't just become a binary. It passes through a four-stage transformation. This transformation happens entirely at build time, long before the binary is flashed or executed on the CPU. Understanding this pipeline reveals that C syntax defines **logic**, while the **Linker Script** defines **location**.

**1. The Preprocessor:** The often-forgotten first step. It handles `#include` files and expands `#define` macros. It doesn't care about memory or logic; it simply performs text manipulation to prepare a pure C file for the compiler.

**2. The Compiler:** The Compiler translates C logic into **Assembly instructions**. At this stage, the tool works with placeholders (logical categories like `.data` or `.bss`). It does not decide physical memory locations. It doesn't know *where* memory is? It only works with placeholders.

**3. The Assembler:** The Assembler converts those assembly instructions into **Machine Code**. It produces **relocatable object files**. These files contain the binary logic, but the addresses are still  **relocatable**. They are not yet tied to a physical spot in your RAM or FLASH.

**4. The Linker:** The Linker is the architect. It takes all the relocatable object files and uses the **Linker Script (.ld)** to assign every symbol a fixed, physical address in **FLASH** or **RAM**.

> The Bottom Line:
You write `int x = 10;` but the linker decides whether if that `10` lives at address `0x20000004` (RAM) or causes a collision. Memory placement is entirely controlled by the linker script.


## FLASH Memory Layout (Non-Volatile Sections)

Flash is the permanent home for everything your program knows but does not need to change. Its contents survive resets and power loss.


![FLASH Memory Layout](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ky8tcewpluhjnksu8s93.png)





 **`.isr_vector`  (The Map)**

Located at the very start of FLASH (typically `0x00000000`).

It contains the initial stack pointer and the addresses of the Reset Handler and all Interrupt Service Routines. On reset, the CPU fetches this table first to know how to start execution.

**`.text`  (The Instructions)**

Contains the compiled machine instructions for the application, libraries, and ISRs. The CPU executes this code directly from FLASH using Execute-In-Place (XIP).

**`.rodata`  (The Constants)**

Stores read-only data such as `const` global variables, lookup tables, and string literals.

**Why `const` Saves RAM:**
If you write `const int table[] = {1, 2, 3};`, the array lives **only** in Flash. If you forget `const`, the linker forces it into RAM (so you can edit it), wasting precious SRAM for data that never changes. **Always use `const` for lookup tables.**

**The String Literal Trap**

- `const char *ptr = "Hello";` → The string "Hello" is stored in FLASH (`.rodata`) but the pointer `ptr` lives in RAM. Safe and RAM-efficient
- `char arr[] = "Hello";` → The string "Hello" is stored in Flash *and* copied to **RAM** at startup. (Costs extra RAM,  allows modification if modification is necessary).

**Warning:** If you remove `const` from the pointer (`char *ptr = "Hello";`), the string *still* lives in Flash (`.rodata`).

- **With `const`:** The compiler gives you an error if you try to write to it.
- **Without `const`:** The compiler allows the write because the type system no longer enforces read-only access, even though the underlying memory is still read-only, but when the CPU tries to write to the Read-Only Flash address, the system triggers a **HARD FAULT** and crashes.

> Rule: Removing const does not move the string to RAM. It only removes protection and makes undefined behavior possible.
> 

### The Hidden Data Sections in FLASH: `.data` and `.bss`

Although `.data` and `.bss` are runtime RAM sections, FLASH plays a critical role in their initialization. It represent the bridge between storage (Flash) and execution (RAM).

**`.data`  Initialized Global variables (LMA vs VMA)**

Global initialized variables (e.g., `int score = 100;`). This variable *must* live in RAM so you can change it. But RAM is wiped at power loss. So where does the `100` come from?

 This section lives a double life.

- **In Flash (LMA - Load Memory Address):** The initial value (`100`) is stored here to survive power loss.
- **In RAM (VMA - Virtual Memory Address):** The startup code reserves space for the variable here.
- **The Mechanism:** Before `main()` runs, the startup code copies the values from Flash (LMA) to RAM (VMA).

**`.bss` — Zero-Initialized Global**

The `.bss` section contains global and static variables that are uninitialized or explicitly set to zero 
(e.g., `int counter;`, `static int flag;`).

No space is reserved for these variables in FLASH; only RAM is allocated.
At startup, the runtime clears the entire `.bss` region to zero before `main()` executes.
This avoids wasting FLASH space storing zeros, so `.bss` consumes **RAM only**.

## RAM Memory Layout (Volatile Sections)

RAM is the system’s **working memory**. It holds all writable runtime state and is rebuilt on every reset.


![RAM Memory Layout](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/b6ubl9acng5qbn9pib6t.png)

**`.data`  (Active Variables)**

Contains initialized global and static variables copied from FLASH during startup. These variables are freely read and modified during execution.

**`.bss`  (Zeroed Variables)**

Holds global and static variables without explicit initial values. This entire region is cleared to zero at startup for predictable behavior.

**Heap  (Dynamic Memory)**

- Starts after `.bss`
- Grows upward
- Used by `malloc()` / `free()`
- Fragmentation-prone
- No bounds checking
- In embedded systems, uncontrolled heap usage leads to **Fragmentation**. Many safety-critical systems restrict or avoid heap usage entirely to avoid instability.

**Stack  (Execution Context)**

- Starts at the top of RAM
- Grows **downward** from the end of RAM.
- Stores function call frames, local variables, return addresses, and interrupt context
Since the Stack grows down and the Heap grows up, they are on a collision course. If the Stack grows too deep (recursion), it will silently overwrite the Heap or `.bss` variables. This is the #1 cause of "ghost bugs."

## Startup Code: The Invisible Hand Before `main()`

In a standard C course, you are taught that "execution begins at `main()`." **On a microcontroller, this is a lie.**

Execution does **not** begin at `main()` on a microcontroller.

Before user code runs, startup code prepares the execution environment:

1. **Stack Pointer Init:** Loads the Main Stack Pointer (MSP) from the vector table. Without this, functions cannot be called.
2. **`.data` Copy:** Copies initial values from Flash to RAM. If this fails, variables start with garbage values.
3. **`.bss` Zeroing:** The entire `.bss` region is cleared to zero in RAM.
4. **System Initialization:** Clock and low-level hardware configuration is performed.
5. **Jump to `main()`** Only after memory is prepared does execution enter the application.

If any of these steps fail, variables contain garbage, the stack corrupts memory, and failures appear unrelated to the real cause.

## The Truth Table: Where Does It Go?

Here is a quick reference guide to predict where your variables will land.

| **Variable Declaration** | **Segment** | **Why?** |
| --- | --- | --- |
| `int x;` (Global) | **.bss** | No initial value. Zeroed by startup code. |
| `int x = 10;` (Global) | **.data** | Needs a non-zero initial value. Copied from Flash. |
| `const int x = 10;` (Global) | **.rodata** | Read-only. Stays in Flash. |
| `static int x = 5;` (Local) | **.data** | `static` means "persist forever." Cannot live on Stack. |
| `int x = 5;` (Local) | **Stack** | Temporary. Exists only while function runs. |
| `char *s = "Text";` | **.rodata** | String is in Flash; Pointer is in RAM. |
| `char s[] = "Text";` | **Stack** | Array is on Stack; String is copied into it. |
| `malloc(10)` | **Heap** | Requested manually by programmer. |

## Verifying Memory Placement

Understanding memory layout is meaningless unless it can be **verified**. Embedded systems do not tolerate assumptions. Use these tools to turn theory into engineering.

**Step 1:** Use this minimal snippet to force variables into every section of the memory.

```c
#include <stdio.h>
#include <stdlib.h>

int var_bss;                    // Uninitialized -> .bss
int var_data = 42;              // Initialized   -> .data
const int var_rodata = 100;     // Read-only     -> .rodata (Flash)

void memory_map_test() {
    int var_stack = 5;          // Local         -> Stack
    static int var_static = 10; // Static Local  -> .data
    int *var_heap = malloc(4);  // Dynamic       -> Heap

    printf("Code (.text):   %p\n", memory_map_test);
    free(var_heap);
}

int main() {
    memory_map_test();
    return 0;
}
```

**Step 2:** High-Level Footprint (`size`)
Run `size <filename.exe>` to see the total consumption.

```c
size test.exe
text    data     bss     dec     hex filename
14696    1560     116   16372    3ff4 test.exe
```

**Step 3:** Forensic Inspection (`nm`)
Use `nm` to prove exactly which section each variable occupies.
Run this command
```bash
nm test.exe | grep var_
```
```c
nm  test.exe | grep var_
00407070 B _var_bss
00404004 D _var_data
00405064 R _var_rodata
00404008 d _var_static.2277
```
- **T** = Text (Flash)
- **R** = Read-only (Flash)
- **D** = Data (RAM)
- **B** = BSS (RAM)

**Step 4:** The Ground Truth (Map File)

Enable the linker map file (`-Wl,-Map=output.map`) in your IDE. This is the final document showing every symbol and its physical address. Use it to verify that your symbols are not colliding and are placed within the correct memory boundaries defined in your `.ld` script.

## Final Rules to Remember
- The CPU only understands addresses
- The linker decides memory placement
- `.data` costs FLASH + RAM
- `.bss` costs RAM only
- Stack overflows are silent
- Always verify memory with tools

## Conclusion
You manage the memory, or the memory manages you. By understanding the pipeline from the Compiler to the Linker, and verifying your layout with tools, you transform from a C programmer into an Embedded Engineer.
