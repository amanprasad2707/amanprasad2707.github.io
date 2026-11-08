---
title: 'Blog Post number 3'
date: 2026-01-04
permalink: /posts/2026-01-04-why-array-starts-at-index-0/
tags:
  - programming
  - discuss
  - C
  - compouter science
---


Have you ever wondered why arrays in C/C++ (and many other languages) start with indexing at 0 instead of 1?
To understand this properly, we need to look at how arrays are stored in memory and how the compiler computes element addresses.


## 📌 Table of Contents
1. [Arrays as Contiguous Memory Blocks](#arrays-as-contiguous-memory-blocks)
2. [How `arr[i]` Works: Pointer Arithmetic Explained](#how-raw-arri-endraw-works-pointer-arithmetic-explained)
3. [Why This Forces Indexing to Start at 0](#why-this-forces-indexing-to-start-at-0)
4. [What If Arrays Started at Index 1?](#what-if-arrays-started-at-index-1)
5. [Why `arr[i]` and `i[arr]` Mean the Same Thing](#why-raw-arri-endraw-and-raw-iarr-endraw-mean-the-same-thing)
6. [Conclusion](#conclusion)


## Arrays as Contiguous Memory Blocks
At its core, an array in C/C++ is a fixed-size collection of elements of the same type, stored in contiguous memory locations. When you declare
```C
int arr[100];
```
The compiler allocates space for `100` consecutive integers.
On most modern systems:
- An int typically occupies `4 bytes` (on 32/64-bit architectures).
- So, the array consumes `400 bytes`, laid out back-to-back in memory.


## How `arr[i]` Works: Pointer Arithmetic Explained
The real reason arrays start at index 0 has nothing to do with counting or convention. It comes from how the compiler rewrites array indexing into pointer arithmetic.

When you write `arr[i]` it is translated directly into `*(arr + i)`
This is not an implementation detail. It is how the language defines array subscripting.
This single translation explains why array indexing starts at zero.

Let’s unpack what each part in `*(arr + i)` means:
- `arr` Refers to the base address of the array. It is the address of the first element (i.e., `&arr[0]`)
- `+ i` Performs pointer arithmetic. This does not add i bytes.
It adds `i × sizeof(element_type)` bytes
- `*` Dereferences the computed address to read or write the value.

> So `arr[i]` literally means: Go i elements away from the start of the array, then access the value stored there.

Let’s verify this equivalence with a simple C program
```C
#include <stdio.h>

int main() {
    int arr[] = {10, 20, 30, 40};
    
    // Direct array access
    printf("arr[1]: %d\n", arr[1]);  // Output: 20
    
    // Equivalent pointer version
    printf("*(arr + 1): %d\n", *(arr + 1));  // Same: 20
    
    return 0;
}
```

## Why This Forces Indexing to Start at 0

Here’s the key insight: the first element isn’t one step away — it lives at the base address.
There is zero distance and zero bytes to skip.

That means:
- distance from base address = 0
- offset = 0
- index = 0

That’s why the first element is accessed as:
- `arr[0] == *(arr + 0)` — no adjustment needed

Each subsequent element is reached by moving forward in memory:
- `arr[1] == *(arr + 1)` — skip 1 element (4 bytes for `int`)
- `arr[2] == *(arr + 2)` — skip 2 elements (8 bytes)
- and so on

Each index represents how many elements to move forward from the base address.
No additional arithmetic or correction is required.

An index is an offset measured in elements.
Offsets start at 0 because nothing can be closer than zero distance from the origin.
This follows directly from how memory addressing and pointer arithmetic work.

## What If Arrays Started at Index 1?
Now that we know `arr[i]` is just syntactic sugar for `*(arr + i)`, let’s imagine a different design.

Suppose arrays were **1-based indexed**, as in some mathematical tools (for example, MATLAB), where the first element is accessed as `arr[1]`.

Pointer arithmetic itself does not change.
`arr[i]` would still translate to:
`*(arr + i)`
If we applied this rule directly:
`arr[1]` → `*(arr + 1)`
this would actually point to the second element, not the first.
To make 1-based indexing work, the compiler would need to internally rewrite every access as:
`arr[i]` → `*(arr + (i - 1))`
That subtraction is the key difference.

While modern compilers can often optimize this subtraction away, one-based indexing still introduces a semantic mismatch with the hardware’s base + offset addressing model. It complicates bounds reasoning and obscures the simple “offset from base” mental model.

Modern CPU addressing modes operate naturally in terms of base address plus offset, making zero-based indexing a direct and transparent match.


## Why `arr[i]` and `i[arr]` Mean the Same Thing
Once you understand that array indexing in C is defined in terms of pointer arithmetic, an interesting (and often surprising) consequence follows.
In fact, the C standard defines `a[b]` as `*(a + b)`, which is why `b[a]` is also valid C. 

In C, the subscript operator is defined as:
`a[b]` = `*(a + b)`
This definition does not treat `a` as “the array” and `b` as “the index.”
It simply means: add `b` to `a`, then dereference the result.

Now consider the implication of this definition.
Pointer addition is just integer addition under the hood, and addition is commutative:
(a + b) == (b + a)

Because of this, both of the following expressions compute the same address
- `*(a + b)`
- `*(b + a)`

Which means:
a[b] == b[a]

This is not a trick, a compiler hack, or undefined behavior.
It is a direct and intentional consequence of how the C language defines array subscripting.

The example below demonstrates this equivalence in practice.

```C
#include <stdio.h>

int main(void) {
    // Declare an array with 5 elements
    int arr[5] = {1, 2, 3, 4, 5};

    /*
     * In C, array access is defined as:
     *   a[b] == *(a + b)
     *
     * Because addition is commutative:
     *   a + b == b + a
     *
     * This means:
     *   arr[3] == 3[arr]
     */

    // Normal array indexing
    printf("arr[3]  = %d\n", arr[3]);   // Output: 4

    // Equivalent but unusual indexing
    printf("3[arr]  = %d\n", 3[arr]);   // Output: 4

    return 0;
}

```
**NOTE:** While `i[arr]` is valid C, it is rarely used in real code because it hurts readability. It exists only because array indexing is defined in terms of pointer arithmetic.

## Conclusion
In C/C++, array indexing is not about counting positions. It is about measuring offsets from a base address.

