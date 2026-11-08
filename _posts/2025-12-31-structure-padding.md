---
title: 'Structure Padding Isn’t Wastage of Memory — It’s a Hardware Requirement'
date: 2025-12-31
permalink: /posts/2025-12-31-structure-padding/
tags:
  - discuss
  - programming
  - low level
  - computer science
---
Have you ever manually calculated the size of a struct, only to find that `sizeof` returns a larger number? You aren't crazy, and the compiler isn't broken. In this guide, we’ll decode Structure Padding. why it happens, why your CPU loves it, and how to optimize it for embedded systems.

## Table of Contents
- [What Is a Structure?](#what-is-a-structure)
- [How Structures Are Stored in Memory](#how-structures-are-stored-in-memory)
- [The Padding Myth](#the-padding-myth)
- [Why Structure Padding Is Necessary](#why-structure-padding-is-necessary)
- [Packed Structures: When to Use Them (and When Not To)](#packed-structures-when-to-use-them-and-when-not-to)
- [The Trade-Off: Memory vs Performance](#the-tradeoff-memory-vs-performance)



## What is a Structure
- A Structure in C is a user defined data type that allow programmers to group together the values of different data types under a single name.
- The items in the structure are called its members and they can be of any valid data type
- A structure in C is defined using the `struct` keyword followed by the structure’s name, inside curly braces {}

## How Structures Are Stored in Memory
Consider the following structure:
``` C
#include <stdio.h>
struct example{
    char a;     // 1 byte
                // 3 byte of padding inserted here
    int b;      // 4 bytes
    char c;     // 1 byte
                // 3 bytes of padding inserted here
};

int main(void) {
    printf("size of struct = %zu bytes\n",
           sizeof(struct example));  // prints 12 bytes (instead of 6)
    return 0;
}
```
At first glance, this structure seems simple. It contains two `char` fields (1 byte each) and one `int` field (4 bytes).
Adding the sizes manually gives 6 bytes.

Yet `size of struct example` evaluates to 12 bytes.

This is not a mistake. To understand why, we need to look at how the compiler maps this structure onto actual memory addresses.

**Byte-level layout**

The compiler places structure members into a contiguous block of memory, assigning each field a fixed offset from the start of the structure:

| Offset | Address     | Content |
|--------|-------------|---------|
| +0     | 0x00001001  | char a  |
| +1     | 0x00001002  | Padding |
| +2     | 0x00001003  | Padding |
| +3     | 0x00001004  | Padding |
| +4     | 0x00001005  | int b (LSB) |
| +5     | 0x00001006  | int b |
| +6     | 0x00001007  | int b |
| +7     | 0x00001008  | int b (MSB) |
| +8     | 0x00001009  | char c |
| +9     | 0x0000100A  | Padding |
| +10    | 0x0000100B  | Padding |
| +11    | 0x0000100C  | Padding |

> Note: Byte order shown assumes a little-endian system. Padding behavior is independent of endianness.

At this point, we can see padding but we still haven’t explained why it exists.

## The Padding Myth
To understand why padding exists at all, we need to briefly leave the C language behind and look at how CPUs actually fetch data from memory.

Let’s trigger the confusion deliberately.

``` C
struct Test {
    char c;
    int  x;
};

printf("%zu\n", sizeof(struct Test));
```

Many beginners expect this to print 5 (1 byte + 4 bytes).
On most systems, it prints 8.

At this point, you’ll often hear:
> The compiler is wasting memory by inserting padding.

That conclusion is wrong.
What actually happened is structure padding. The compiler inserted extra bytes between members and possibly at the end to satisfy the hardware alignment rules. It has nothing to do with the C language.

Visually, the memory layout looks like this:

![Memory layout of Struct with padding in banked memory](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/vg51u1qxnp3sl05i2a1n.png)

This diagram illustrates **how a C structure is laid out in memory** on a system with a **32-bit data bus** and alignment requirements.

This diagram uses a 32-bit data bus visualization to illustrate alignment constraints imposed by the hardware.

At the top-left, the `struct example` definition is shown:

* `char a` → 1 byte
* `int b` → 4 bytes
* `char c` → 1 byte

Naively, this looks like **6 bytes of data**.
However, the memory layout above shows why the actual size becomes **12 bytes**.


**Byte-level memory layout**

The table above represents memory **byte by byte**, grouped into **32-bit word banks** (BANK 0 to BANK 3), each corresponding to one byte lane of the data bus:

* **BANK 0** → D7–D0
* **BANK 1** → D15–D8
* **BANK 2** → D23–D16
* **BANK 3** → D31–D24

Each row represents a **4-byte aligned word** in memory.

**Placement of `char a`**

* `char a` occupies **only one byte**
* It is placed in **BANK 0** at offset `+0`
* The remaining three byte lanes in that word are unused for data

These unused lanes are shown as **padding bytes**.
They exist so that the next field can start at a properly aligned address.


**Alignment of `int b`**

* `int b` requires a **4-byte aligned address**
* The compiler therefore starts `int b` at offset `+4`
* All four byte lanes (BANK 0–BANK 3) are used to store the integer

This allows the CPU to fetch `int b` in **one aligned 32-bit memory access**.


### Placement of `char c` and tail padding

* `char c` occupies one byte at offset `+8`
* The remaining three bytes in that word are again unused

These final padding bytes are **tail padding**.
They ensure that the **total structure size is a multiple of 4**, so that arrays of this structure remain correctly aligned.


### Final result

* Actual data: **6 bytes**
* Padding inserted: **6 bytes**
* Total structure size: **12 bytes**

The key takeaway illustrated by this diagram is:

> Padding is not wasted memory — it is the cost of alignment, paid to allow efficient and safe access on real hardware.


**Important note**
> This diagram intentionally shows **banked memory and a 32-bit data bus** to emphasize that structure padding is driven by **hardware access rules**. Different architectures may implement alignment differently, but the principle of alignment remains the same.


## Why Structure Padding Is Necessary

![with padding and without padding memory representation](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/5stjdqdmm7nw3oh9h4bf.png)

To understand why padding is necessary, we need to bridge the gap between how we write code (byte by byte) and how the hardware runs it (word by word).

A 32-bit CPU does not access memory one byte at a time; that would be inefficient. Instead, it fetches data in 4-byte chunks known as words. The CPU runs fastest when the data it needs starts exactly at the beginning of a word boundary.

Let's visualize our structure (char a, char b, int c) and see how the CPU handles it with and without padding.

**1. The Slow Way: Without Padding (Unaligned)**
Look at the left side of the diagram. If the compiler packed data tightly, here is what happens when the CPU needs to read the 4-byte integer `int c`.

**The Problem:** Because the two char fields take up the first two bytes, `int c` starts halfway through the first 4-byte word and ends halfway through the second word. It is split across two words.

**The Cost:** To get that single integer `int c`, the CPU must perform two memory cycles. It has to fetch Word 1 to get the first half of the integer, then fetch Word 2 to get the second half, and finally stitch them together. This is slow and inefficient.

**2. The Fast Way: With Padding (Aligned)**
Now look at the right side of the diagram. This is what the compiler actually does to help the CPU. The compiler inserts padding two empty unused bytes after the char fields.

The Benefit: This forces `int c` to start exactly at the beginning of Word 2. When the CPU needs that integer, it can retrieve the entire 4-byte value in a single memory cycle (indicated by the single green arrow).


![why padding matters](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/wsjqukg51s40dm2q1c3s.png)

As the bottom of the image summarizes, structure padding is a deliberate trade-off. The compiler sacrifices a small amount of memory space (the padding bytes) to gain a significant boost in execution speed by ensuring data is aligned for single-cycle CPU access.


## Packed Structures: When to Use Them (and When Not To)
After understanding structure padding, a natural question arises:
If padding costs memory, why not just remove it?
C allows you to do exactly that using packed structures, commonly through #pragma pack or compiler-specific attributes.

**Packing through #Pragma pack**
```C
#pragma pack(1)
struct example{
    char a;     // 1 byte
    int b;      // 4 bytes
    char c;     // 1 byte
};
#pragma pack()
// total size = 6 bytes, no padding
```
**Packing through compiler-specific attributes**
```C
struct PackedExample {
    char a;
    int b;
    char c;
} __attribute__((packed));
```

This tells the compiler to ignore natural alignment rules and place structure members back-to-back with no padding.

At first glance, this looks like an optimization. In practice, it’s a trade-off, and often dangerous.

**What packing actually does**
Packing affects only memory layout, not CPU behavior.
When you pack a structure:
- Padding bytes are removed
- Multi-byte fields may become misaligned
- size of `struct` becomes smaller

**What does not change:**
- How the CPU fetches memory
- Alignment requirements of the architecture
- Cost of misaligned access

The CPU still expects aligned data.
Packing simply removes the compiler’s safety net.

**Reducing Padding by Reordering Members**

Consider this reordered structure:

```C
struct optimized {
    int  b;   // 4 bytes
    char a;   // 1 byte
    char c;   // 1 byte
    // 2 bytes of padding at the end
};
// total size = 8 bytes
```


This structure contains the same data as the original version, but the total size is reduced from 12 bytes to 8 bytes without using packed attributes.

**Why this layout is better**
The key change is member ordering.
- The int field, which requires 4-byte alignment, is placed first
- Smaller `char` fields followed after the large `int` field.
- Padding is pushed to the end of the structure, not between members

This layout allows the compiler to satisfy alignment rules with minimal padding.

**Why this is better than packing**
Compared to a packed structure:
- All fields remain naturally aligned
- The CPU can access `int b` in one aligned memory read
- No risk of misaligned access faults
- Performance and portability are preserved

This is the compiler-friendly way to reduce padding.

**The general rule**

> Order structure members from largest alignment requirement to smallest.

This simple rule often eliminates most padding automatically.

## The Trade-Off: Memory vs Performance

In engineering, there is rarely a perfect solution, only trade-offs.
Structure padding exists because software has to choose between two competing goals:
- Minimize memory usage
- Maximize execution speed and safety

You rarely get both at the same time.
Padding is the compiler’s way of deliberately choosing performance and correctness over absolute memory compactness.

**What happens when you minimize memory**
When fields are packed tightly with no padding:
- Structures are smaller
- Cache and RAM usage is reduced
- Memory footprints look efficient on paper

But the cost is hidden:
- Multi-byte fields may become misaligned
- The CPU may need multiple memory reads for a single variable
- Extra instructions are required to assemble the value
- On some architectures, misaligned access can trap or crash
In other words, you save bytes but pay in cycles.

**What happens when you allow padding**
When padding is introduced:
- Structures become slightly larger
- Some memory appears “unused”
- size of `struct` increases

But the benefits are:
- Data is naturally aligned
- The CPU fetches values in one memory access
- Code executes faster and more predictably
- Hardware behavior becomes simpler and safer

You spend a few bytes to save CPU time.