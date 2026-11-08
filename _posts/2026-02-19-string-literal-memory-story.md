---
title: 'char str1[] = "hello world"; vs char *str2 = "hello world"; – The Memory Story Every C Programmer Must Know'
date: 2026-02-19
permalink: /posts/2026-02-19-string-literal-memory-story/
tags:
  - discuss
  - learning
  - C
  - beginners
---

A **string literal** is a sequence of characters stored in **read-only memory** and automatically terminated by a null character `'\0'`.

```c
char str1[] = "hello world";   //  str1 is a character array stored on stack
char *str2 = "hello world";    // str2 is a pointer stored on the stack; it points to a string literal in read-only memory

```

Although they look similar, these two lines behave **very differently in memory**.

### char str1[] = “hello world”;

- The compiler allocates an array of size **12 bytes** (`11 characters + '\0'`) **on the stack** (for local variables)**.**
- At runtime it **copies** the 12 bytes from the string literal (typically stored in `.rodata`)

So you end up with **two copies** of the string:

- One immutable in `.rodata`
- One mutable on the stack
- *(If `str1` were global or static, it would be stored in `.data` instead of the stack.)*

so if we try to change it something like that

```c
str1[0] = 'a';       // works fine because it is mutable and located on stack
str1 = "something";  // compilation error array name is not assignable
str1++;              // not allowed: array names are non-modifiable lvalues
```

In the above snippet, str1 = "something" is not allowed because str1 is an array and array names cannot be reassigned.
If we want to write new data into the existing array str1, we must copy the contents using `strcpy`.

```c
strcpy(str1, "some");   // '\0' is copied automatically
```

⚠️ `strcpy` assumes the destination array is large enough; otherwise it causes buffer overflow.

Alternatively, we can copy from another character array:

```c
char new_str[] = "new value";
strcpy(str1, new_str);
// (Here str1 is the destination array and new_str is the source string.)
```

Now, if we check the size of the variable str1, it gives 12 bytes
(11 characters + one null character `'\0'`):

```c
sizeof(str1);  // 12 bytes (11 chars + 1 null char '\0')
```

`str1` is a **real array**, and `sizeof` returns the **total allocated size of the array**, not the length of the string stored in it.

## Why can’t I do `str1 = str2`, but I can do `strcpy(str1, str2)`?

At first glance, both statements look like they should “copy” a string. However, they do two very different things in C.

Internally, `strcpy` does something like this:

```c
while (*str2 != '\0') {
    *str1 = *str2;
    str1++;
    str2++;
}
*str1 = '\0';
```

It **never changes the address of `str1`** It **writes into the memory owned by `str1`** That is why it is allowed.

### char *s2 = "hello world";

- The compiler allocates **only the pointer** (8 bytes on 64-bit, 4 bytes on 32-bit) on the stack.
- The pointer’s value is the address of the string literal (typically stored in `.rodata`).
- we cannot modify the **data that `str2` points to**, because the string literal is stored in the read-only `.rodata` segment

```c
str2[0] = 'a';         // undefined behavior (often results in segmentation fault)
str2++;                // allowed: moves the pointer, not the string data
printf("%s", str2);    // ello world
str2 = "bye world";    // allowed — repoints to another literal
```

- The **string literal** `"hello world"` is placed in **read-only memory** (`.rodata`)
- `str2` (a pointer) stores the **address** of that literal

### The const Habit we Should Adopt

```c
const char *str2 = "hello world";   // this is what we should write
```

Now the compiler will give you a compile-time error if you try str2[0] = 'x'; instead of a runtime crash.

## What Happens If Two Variables Use the Same String Literal?

Consider the following code:

```c
const char *a = "hello";
const char *b = "hello";

printf("%p %p\n", (void *)a, (void *)b);
```

On many systems, this program prints **the same address** for both `a` and `b`:

```
0x0040507D  0x0040507D
```

Most modern compilers perform an optimization called **string literal pooling** (or **string interning**):

- Identical string literals are **stored only once**
- Multiple pointers reference the **same memory location**
- This saves memory and improves cache usage

As a result:

- `a` and `b` point to the **same string literal**
- Modifying either (which is illegal anyway) would affect both

### Important Standard Note

> ⚠️ **The C standard does NOT guarantee this behavior.**
> 
- Compilers are **allowed** to merge identical literals
- Compilers are also **allowed** to keep them separate
- You must **never rely on their addresses being equal**

So this is valid C:

```c
a == b   // may be true or false
```

Both outcomes are legal.

### Why This Matters in Practice

1. Never compare string literals using pointer equality
    
    ```c
    if (a == b) { ... }   // ❌ wrong
    ```
    
2. Always use `strcmp`
    
    ```c
    if (strcmp(a, b) == 0) { ... }  // ✅ correct
    ```
    
3. Never attempt to modify string literals
4. Treat all string literals as **read-only shared objects**

```c
#include <stdio.h>
#include <string.h>

int main() {

    /* =========================================================
                PART 1: char str1[] = "hello world";
    ========================================================= */

    char str1[] = "hello world";
    /* str1 is a CHARACTER ARRAY.
    Memory for the array is allocated on the stack.
    The string literal "hello world" is COPIED into this array.
    Size allocated = 11 characters + 1 null terminator = 12 bytes. */

    // Since str1 owns writable memory, modifying characters is VALID.
    str1[0] = 'a';   // changes 'h' to 'a'

    // Prints the modified string stored in stack memory
    printf("str1: %s\n", str1);   // Output -> str1: aello world

    strcpy(str1, "aman");
    printf("str1: %s\n", str1);   // Output-> str1: aman

    // Array names are NOT pointers and are NOT modifiable lvalues.
    // str1++;              //  INVALID: cannot change base address of an array
    // str1 = "bye world";  //  INVALID: array cannot be reassigned

    // sizeof(str1) gives the TOTAL SIZE of the array in bytes
    // because str1 is a real array.
    printf("size of str1: %zu\n", sizeof(str1));   // 12 bytes

    /* =========================================================
       PART 2: char *str2 = "hello world";
       ========================================================= */

       char *str2 = "hello world";
    /* str2 is a POINTER to char.
    The string literal "hello world" is stored in READ-ONLY memory (.rodata).
    str2 only stores the ADDRESS of the first character of the literal. */

    /* Attempting to modify a string literal is UNDEFINED BEHAVIOR.
    On most systems this causes a segmentation fault or crash.
    str2[0] = 'a';    //  SEGMENTATION FAULT

    CORRECT and SAFE declaration for string literals:
    const char *str2 = "hello world";

    Pointer arithmetic is allowed because str2 itself is modifiable.
    This makes str2 point to the second character of the string. */
    str2++;

    // Prints the string starting from the new pointer location
    printf("str2: %s\n", str2);   // Output: ello world

    // Reassigning the pointer is allowed.
    // Now str2 points to a DIFFERENT string literal.
    str2 = "bye world";

    // Prints the new string literal
    printf("str2: %s\n", str2);   // Output: bye world

    // sizeof(str2) gives the size of the POINTER itself,
    // NOT the size of the string it points to.
    printf("size of str2: %zu\n", sizeof(str2));   // 8 bytes on 64-bit systems

    // All pointer types have the same size on a given architecture
    printf("size of int pointer: %zu\n", sizeof(int*)); // 8 bytes (64-bit)

    return 0;
}

```