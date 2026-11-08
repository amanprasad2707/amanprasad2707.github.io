---
title: 'Pointers Store Addresses; So Why Do They Have Types?'
date: 2025-12-23
permalink: /posts/2025-12-23-pointers-store-address-so-why-do-they-have-types/
tags:
  - programming
  - discussion
  - learning
  - beginners
---

We’ve all heard about this: "**A pointer is just a variable that stores a memory address.**"

That statement is technically true — but incomplete. If pointers were only addresses, every pointer would be exactly the same (usually 4 or 8 bytes of data). But in C/C++, we have `char*`, `int*`, `double*`, `struct*` and so on.

If the address is just a number, why does the type matter?

To understand pointer types, we have to look at how memory actually works. Physical memory doesn’t know the difference between an integer, a character, or a floating-point number. It is simply a sequence of bytes.

The pointer type acts as a template. It tells the compiler two critical things:

1. **Width:** How many bytes to read starting from that address?
2. **Interpretation:** Once we have those bytes, how do we treat them (e.g., as a signed integer, an IEEE 754 float, or an ASCII character)?


![Memory visualization showing char* vs int* pointer behavior](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/qluxj7e22n1rf45brmu9.png)

## A Tale of Two Pointers: Scenario A vs. Scenario B
Look at the visualization above. We have 4 bytes of memory starting at address 0x20000000.
```
Address        Value
0x20000000     0x01
0x20000001     0x02
0x20000002     0x03
0x20000003     0x04
```

## Scenario A: `char* pc`
When we dereference a `char*`, the compiler thinks: "Okay, start at 0x20000000, read exactly 1 byte, and treat it as a character."
**Result:** 0x01

## Scenario B: `int* pi`
When we dereference an int* at the exact same address, the compiler thinks: "Start at 0x20000000, read the next 4 bytes, and combine them into an integer."
On a little-endian system, it reads 01, 02, 03, 04 and interprets it as:
**Result:** 0x04030201

The address stayed the same. The data in memory stayed the same.
This difference exists even though the underlying hardware memory is unchanged.

## The facts that matter more than any definition

Everything discussed so far reduces to a few fundamental truths:

- Memory is a linear address space of byte-sized storage units
- The address itself is only a starting point
- Pointer types tell the compiler how to interpret those bytes


## What pointer types tell the compiler

Because memory itself has no notion of types, the pointer type becomes critical.

A pointer type tells the compiler:

- How many bytes to read or write
- How to interpret those bytes
- How pointer arithmetic should behave

Because pointer arithmetic is scaled by the size of the pointed-to type, this is why it works like this:
```c
int *p;
p + 1;   // moves 4 bytes, not 1 because size of int is 4 bytes
```

## Conclusion
If you only know that *“a pointer stores an address,”*
you haven’t understood pointers — you’ve memorized a sentence.

Understanding pointer types means understanding **how software actually talks to memory.**



