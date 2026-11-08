---
title: 'The Inline Myth: Why the inline Keyword is Just a Suggestion'
date: 2026-02-23
permalink: /posts/2026-02-23-why-the-inline-keyword-is-just-a-suggestion/
tags:
  - discuss
  - learning
  - C
  - beginners
---

Inline functions are functions that the compiler *may* expand directly at the place where they are called, instead of performing a normal function call.

Inline functions are often misunderstood especially by beginners who assume that writing the `inline` keyword forces the compiler to inline a function.

In reality, **inline is only a suggestion** and modern compilers are far smarter than we realize.
For optimization purposes, inline is only a suggestion. (In C99, it also has defined linkage semantics.)

This post explains:

- What `inline` actually means
- Why it is only a hint
- Inline vs macros
- How modern compilers decide to inline
- Performance and binary size trade-offs
- Real compiler behavior using assembly output

## Inline Is a Suggestion, Not a Command

When you write:

```c
inline int add(int a,int b){
    return a + b;
}
```

you are **not instructing** the compiler to inline this function.

You are merely **suggesting** that inlining *may* be beneficial.

The compiler is completely free to:

- Inline the function
- Ignore the suggestion
- Inline it in some call sites but not others

### Why?

Because **the C/C++ standards do not require compilers to perform any optimization at all**.

Inlining is an optimization, and therefore it **cannot be mandatory**.

If `inline` were a mandatory, optimization itself would no longer be optional and this would violate the language standard.

## Modern Compilers Inline Even Without `inline`

A very common misconception is:

> If I don’t write `inline`, the function won’t be inlined.
> 

This is **false**.

Modern compilers (GCC, Clang, MSVC):

- Perform **automatic inlining**
- Analyze function size, call frequency, and context
- Inline functions even if the `inline` keyword is not used

Example:

```c
int add(int a,int b){
    return a + b;
}
int main(){
    return add(2,3);
}
```

With optimizations enabled (`-O2`, `-O3`), the compiler will **very likely** inline such a small function.

Today, `inline` is more of a semantic hint than a performance switch.

## Why Inline Exists at All

Inlining was originally introduced to:

- Reduce **function call overhead**
- Improve performance in tight loops
- Replace unsafe macros

A traditional function call involves:

- Pushing arguments onto the stack
- Saving registers
- Jumping to another memory location
- Returning back

Inlining eliminates this overhead by **expanding the function body at the call site**.

## But Call Overhead Isn’t That Expensive Anymore

Modern CPUs are highly optimized for function calls through:

- Branch prediction
- Instruction pipelining
- Speculative execution

As a result, the overhead of a **well-predicted function call is often very small**.

In many cases, aggressive inlining does not yield significant performance gains and can even **hurt performance** due to:

- Increased code size
- Instruction cache pressure
- Register pressure

Today, the primary benefit of inlining is **not eliminating the call itself**, but **enabling further compiler optimizations**.

## How Compilers Decide to Inline

Compilers use heuristics. They compare:

- **Cost of the function call**
- **Size of the function body**

If the **cost of call** > **cost of expanded code** then the compiler may inline.

### Likely to Be Inlined

- Very small functions
- Simple calculations
- Getters/setters
- Functions called inside loops

### Unlikely to Be Inlined

- Large functions
- Functions with loops
- Functions with static variables
- Functions called via function pointers
- Recursive functions

## Recursive Functions Cannot Be Fully Inlined

Inlining requires the compiler to expand the function body.

For recursion:

```c
int fact(int n){
    return n == 0 ? 1 : n * fact(n -1);
}
```

Inlining would require:

- Infinite expansion
- Unlimited code generation

Compilers cannot infinitely expand recursive calls, 
though they may still inline limited cases or optimize tail recursion.

## Inline vs Macros

Macros were the original “inline mechanism,” but they come with serious problems.

### Macro Example

```c
#define ADD(a, b) a + b
```

Usage:

```c
4 * ADD(2 + 2)
```

Expansion:

```c
4 * 2 + 2  //  Wrong result
```

### Inline Function Equivalent

```c
inline int add(int a,int b) {return a + b;
}
```

Usage:

```c
4 * add(2 + 2) //  Correct
```

## Too Much Inline Increases Binary Size

Inlining duplicates code at every call site.

If a function is used in many places:

- Binary size increases
- Instruction cache pressure increases
- Performance may actually degrade

This phenomenon is known as **code bloat**.

So:

> **Inlining trades space for speed.**
> 

## Experiment: Verifying Inlining Across Optimization Levels

We test a simple program with and **without the `inline` keyword** to observe how the compiler behaves at different optimization levels.

**Test Code**

```c
inline int add(int a, int b) {
    return a + b;
}

int main() {
    return add(2, 3);
}

```

### Case 1: Compilation with `-O0` (No Optimization)

```c
gcc -S  test.c -O0
```


![assembly generated for the inline function with O0](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/dfs71j9rdwt4qtsf2o13.png)

### Assembly Observation

```nasm
call    _add
```

- `main()` explicitly **calls `_add`**
- Stack frame setup is visible
- No inlining occurs

### Symbol Table

```bash
nm a.exe | grep add
```

```rust
00401b40 T ____w64_mingwthr_add_key_dtor
00403880 T ___mingw_readdir
00401460 T _add   // we can see the add symbol with -O0
```

### Conclusion:

At -O0, GCC prioritizes debuggability. Almost no inlining happens even if inline is written.

### ⚠️ Important Warning About `inline` at `-O0`

In **C**, writing `inline` does **not** create a normal, externally callable function.

At `-O0`:

- The compiler does not inline
- A function call may still be generated
- No external definition is emitted for the `inline` function

This leads to a linker error:

> **Call exists, but function does not.**


To avoid this issue in C, always use:

```c
static inline
```

or provide a separate external definition.

⚠️ Important Clarification About C99 `inline`

In C99, `inline` is not only about optimization — it also affects linkage and symbol emission.

There are three forms:

- `inline` → provides an inline definition but does not emit an external definition.
- `extern inline` → forces emission of the external definition in one translation unit.
- `static inline` → gives internal linkage (each translation unit gets its own copy).

To avoid linker issues at low optimization levels, you can either:

• Use `static inline` in headers (common and simple), or  
• Use `inline` in a header and `extern inline` in exactly one .c file (the strict C99 model).


## Case 2: Compilation with `-O2` (Optimized Build)

```bash
gcc -S test.c -O2
```

### Assembly Observation


![assembly generated for the inline function with O0](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/yczr9pcmwysgyidekefw.png)

- No `call _add`
- Function is fully inlined
- Constant folding reduces `add(2,3)` to `5`

### Symbol Table

```bash
nm a.exe | grep add
```

```reason
00401b10 T ____w64_mingwthr_add_key_dtor
00403850 T ___mingw_readdir
00401460 T _add 
```

⚠️ **Important Observation**
 `_add` still exists, but it is **never called**.

### Why `_add` Exists but Is Never Called

This is the **core question**, and the answer is subtle but fundamental.

**Reason 1: External Linkage**

```c
inline int add(int a,int b);
```

Functions have external linkage by default, meaning another translation unit might call add().
The compiler must therefore keep the symbol.

**Reason 2: No Whole-Program Visibility**

Without Link Time Optimization (LTO), the compiler cannot prove the function is unused globally.

### Forcing Removal of `_add`

**Option 1: Make the Function `static`**

```c
static int add(int a,int b){
    return a + b;
}
```

Internal linkage allows the compiler to remove the symbol.

**Option 2: Enable Link Time Optimization (LTO)**

```bash
gcc -O2 -flto test.c
```

### ⚠️ Important Note

Although the example uses the `inline` keyword for explanation, I also tested the **same code without `inline`**.

When compiled with `-O2`, the compiler **still inlined the function automatically**.

This confirms that **inlining at higher optimization levels is driven by the compiler’s heuristics**, not by the presence of the `inline` keyword.

## Key Takeaways

- `inline` is a **hint**, not a guarantee
- The compiler may inline even without `inline`
- - Inline primarily enables optimization, but in C99 it also affects linkage
- Macros are unsafe; inline functions are type-safe
- Recursive functions cannot be inlined
- Excessive inlining increases binary size
- Modern CPUs reduce the benefit of aggressive inlining