---
title: 'Flash Memory Explained: NAND vs NOR, Architecture, and Memory Organization'
date: 2026-02-07
permalink: /posts/2026-02-07-flash-memory-nand-nor/
tags:
  - discuss
  - learning
  - architecture
  - science
---
Flash memory is a type of non-volatile semiconductor memory that can be electrically erased and reprogrammed. It is based on floating-gate MOSFETs (Metal-Oxide-Semiconductor Field-Effect Transistors) where data is stored by trapping electrons in a floating gate, altering the threshold voltage of the transistor to represent binary states. Unlike volatile memory like DRAM, flash retains data even when power is removed, making it ideal for applications requiring persistent storage such as SSDs, USB drives, memory cards and embedded systems. Flash memory evolved from EEPROM, but instead of erasing individual bytes, it erases data in larger blocks, which significantly improves speed, density, and cost efficiency.

### Table of Contents
- [Types of Flash Memory: NAND and NOR](#types-of-flash-memory-nand-and-nor)
  - [NOR Flash](#nor-flash)
  - [NAND Flash](#nand-flash)
- [Comparison of NAND and NOR](#comparison-of-nand-and-nor)
- [Memory Organization: Sector, Block, and Page](#memory-organization-sector-block-and-page)



## Types of Flash Memory: NAND and NOR

The two primary types of flash memory are NAND and NOR which are named after the way their memory cells are connected internally, which resembles NAND and NOR logic gates.

Both use the same basic **floating-gate cell** design, but they differ in **architecture, access methods, performance, cost, and applications**.


![NAND and NOR flash memory diagram with truth table](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/0moxeizcpbv32fevgdq8.png)
*Image source: [nexusindustrialmemory](https://nexusindustrialmemory.com/guides/what-is-nand-memory/)*

### NOR Flash


![NOR Flash memory](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/v0u7lpemf86z376f7as9.png)
*Image source: [embedded.com](https://www.embedded.com/flash-101-nand-flash-vs-nor-flash/)*

In **NOR flash**, memory cells are connected in **parallel**, with the **drain of each cell connected to a bit line** and the **source connected to a common source line** (typically ground). This parallel connection resembles the structure of a **NOR logic gate**, which is the origin of the name *NOR flash*.

This architecture enables **true random access at the byte level**, allowing the processor to directly read instructions from flash memory. As a result, code can be executed directly from NOR flash using **Execute-In-Place (XIP)**, without first copying the code into RAM.

NOR flash offers **fast read access**, making it ideal for code storage. However, **write and erase operations are slower** because erase operations occur at the **sector level**, and the cell structure requires higher voltages and larger physical area. This leads to **lower memory density** and a **higher cost per bit** compared to NAND flash.

Typical applications of NOR flash include **firmware storage** in embedded systems such as **bootloaders, BIOS, and microcontroller internal flash**.

### Key Components

- **Memory Cell**: The basic storage element implemented as a **floating-gate MOSFET**. Data is stored by trapping or removing charge from the floating gate, representing logic `0` or `1`.
- **Word Line**: Horizontal lines (in black color) that connect to the control gates of the memory cells. These are used to select specific rows of cells for operations like read, program (write), or erase.
- **Bit Line**: Vertical orange line at the top which is connected to the drain of the cells. This carries data in and out during read and write operations.
- **Source Line**: Vertical blue line at the top right. This is typically connected to ground or a reference voltage and is shared among cells.

### Structural Characteristics

- **Direct electrical path per cell:** Each memory cell is connected directly between the **bit line (drain)** and the **source line (ground)**. This one-to-one connection allows the state of a single cell to be sensed without interference from neighboring cells.
- **Independent cell access:** Because cells are not connected in series, selecting a specific **word line** activates only the targeted cell(s). This independence enables **true random access** to individual bytes or words.
- **Larger physical cell size:** Each cell requires its own drain contact, source connection, and routing lines. This increases the silicon area per bit, resulting in **lower storage density** compared to NAND flash.
- **High reliability for code storage:** The simple read path and minimal need for complex error correction make NOR flash highly reliable for instruction fetch and execution, which is critical for firmware and boot code.

### Operational Implications

- **Read Operation**: Read operations are **fast and byte-addressable**. The processor can directly fetch instructions from NOR flash using **Execute-In-Place (XIP)**, eliminating the need to copy code into RAM before execution.
- **Write Operation**: Programming is **slower** because it involves injecting charge into the floating gate using precise voltage pulses. Writes typically occur at the **page level**, even if only a small amount of data is modified.
- **Erase Operation:** Erase operations are performed at the **sector level**, where a group of memory cells is cleared simultaneously by removing charge from their floating gates. This operation is relatively slow and requires higher voltages.

### NAND Flash


![NAND flash memory](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/djn1r8eywkqf00pq48qy.png)
*Image source: [embedded.com](https://www.embedded.com/flash-101-nand-flash-vs-nor-flash/)*

In **NAND flash**, memory cells are connected **in series**, forming a **cell string** typically consisting of **32 to 128 cells**. The **drain of one cell is connected to the source of the next** and the entire string is connected between a **bit line** at the top and a **common source line** at the bottom. This serial connection resembles the structure of a **NAND logic gate**, which is the origin of the name NAND flash.

This architecture significantly reduces the number of required contacts and routing lines per cell, enabling **much higher storage density**, **lower cost per bit** and **larger memory capacities** than NOR flash. However, because cells are accessed through a series path, NAND flash does **not support true random access**. Instead, data is accessed in **pages**, and erase operations are performed in **blocks**, making random reads slower but bulk data operations highly efficient.

### Key Components

- **Memory Cell**: The basic storage element implemented as a **floating-gate MOSFET**. Data is stored by trapping or removing charge from the floating gate, representing logic 0 or 1.
- **Word Line**: Horizontal lines (in black color) that connect to the control gates of the memory cells. These are used to select specific rows of cells for operations like read, program (write), or erase.
- **Bit Line**: Vertical orange line at the top, which is connected to the drain of the top select transistor. This carries data in and out during read and write operations.
- **Source Line**: Horizontal blue line at the bottom. This is typically connected to ground or a reference voltage and is shared among strings.
- **Ground Line Select Transistor (SL Select):** A switch transistor at the bottom of the string that connects or isolates the string from the source line.

### Structural Characteristics

- **Series-connected cell strings:** Memory cells are connected in a chain, requiring current to pass through multiple cells to access a target cell.
- **High-density layout:** Fewer contacts and shared routing allow more cells to fit in the same silicon area, resulting in **significantly higher density** than NOR flash.
- **Shared access path:** Cells do not have independent read paths. All unselected cells in a string must be biased ON to access the selected cell.
- **Complex peripheral circuitry:** NAND flash requires page buffers, sense amplifiers, and **error correction codes (ECC)** to ensure data integrity.
    
    

### Operational Implications

- **Read Operation:** Reads are performed at the **page level**. An entire page is transferred into an internal buffer and the requested data is then output. This makes random reads slower compared to NOR flash.
- **Write Operation:** Programming is **fast and efficient**, occurring at the page level. NAND flash is well suited for frequent data writes.
- **Erase Operation:** Erase operations are performed at the **block level**, where a block consists of many pages. Block erase in NAND flash is faster and more energy-efficient **per bit erased** compared to NOR flash.

### NAND Flash Cell Types

NAND flash is further classified based on the number of bits stored per cell:

- **SLC (Single-Level Cell):** Stores 1 bit per cell. Offers the highest speed, endurance (up to ~100,000 cycles), and reliability, but at higher cost and lower density.
- **MLC (Multi-Level Cell):** Stores 2 bits per cell. Balances density and endurance (3,000–10,000 cycles).
- **TLC (Triple-Level Cell):** Stores 3 bits per cell. Higher density with reduced endurance (1,000–5,000 cycles); common in consumer SSDs.
- **QLC (Quad-Level Cell):** Stores 4 bits per cell. Very high density with lower endurance (100–1,000 cycles) and slower performance.
- **PLC (Penta-Level Cell):** Stores 5 bits per cell. Emerging technology focused on ultra-high density with increased reliability challenges.

## Comparison of NAND and NOR

| Feature | NOR Flash | NAND Flash |
| --- | --- | --- |
| **Cell Architecture** | Parallel connection (like NOR gate) | Series connection (like NAND gate) |
| **Access Method** | Random byte-level access, supports XIP | Sequential page/block access |
| **Read Speed** | Faster (e.g., 100-200 ns per byte) | Slower for random reads, faster for sequential |
| **Write/Erase Speed** | Slower (sector erase in tens to hundreds of milliseconds, writes in milliseconds) | Faster (erase in ms, write in µs per page) |
| **Density/Cost** | Lower density, higher cost per bit | Higher density, lower cost per bit |
| **Endurance** | Higher than NAND (typically 10⁴–10⁵ erase cycles) | Varies by type (SLC high, QLC low) |
| **Typical Capacities** | Up to a few GB | Up to TB-scale |
| **Power Consumption** | Higher for writes/erases | Lower overall |
| **Use Cases** | Code storage, firmware, embedded systems | Data storage, SSDs, USB drives, memory cards |

## Memory Organization: Sector, Block, and Page

Flash memory is **not organized like RAM**. Instead of allowing free read, write, and erase operations on individual bytes, flash memory follows a **strict hierarchical structure**. This structure exists because of the **physical nature of flash memory cells** and how they are erased.

Flash memory is organized into **pages** (read/write units) and **blocks or sectors** (erase units). This design directly impacts how data is stored, modified, and managed.

## Why Flash Memory Uses Pages and Blocks

Flash memory cells store data using **charge trapped in floating gates**. To erase data, a **high voltage** must be applied to remove this charge.

Because applying such high voltage to individual cells is impractical and unsafe, flash memory erases **groups of cells together**. This leads to the following rules:

- **Read operations** occur at the page level
- **Write operations** occur at the page level
- **Erase operations** occur at the block (or sector) level

This asymmetry is fundamental to all flash memory technologies.

## The Hierarchical Structure of Flash Memory

### Page

A page is the smallest unit used for reading or writing data in flash memory. It is a row of memory cells that share a common word line, which is a control signal.

- In NAND flash: Pages are usually 2KB to 16KB in size, with 4KB being common in modern SSDs. They include a spare area of 64-512 bytes for error correction codes (ECC), metadata, and bad block markers.
- In NOR flash: Pages are smaller, often 256-512 bytes.

Writing to a page involves charging or discharging the floating gates in the cells, which takes microseconds. Pages cannot be overwritten directly; the block that contains the page must be erased first. In NAND, pages have a main data area and a spare area for extra information.

### Block

A block is a group of pages and the smallest unit that can be erased at once. It is a grid of strings (columns of connected cells) and pages (rows). Erasing uses high voltage to set all bits to 1 via Fowler-Nordheim tunneling.

- In NAND flash: 64-512 pages per block, totaling 128KB to 8MB (e.g., 4MB common).
- In NOR flash: Often called sectors, with erase units of 4KB-256KB.

Blocks wear out over erase cycles. In NAND-based storage devices, this is managed by a Flash Translation Layer (FTL), which performs wear leveling and garbage collection by relocating valid pages before erasing blocks.

### Sector

The term **sector** is used differently depending on the type of flash memory and the context. In **NOR flash**, a sector refers to the **smallest erasable unit** of memory and is functionally equivalent to a block in NAND flash. NOR flash sectors typically range from **4 KB to 256 KB** and contain multiple pages.

In **NAND flash**, the term sector is not a formal physical unit. It is often used informally to describe a **512-byte or 4 KB logical chunk of data**, a convention inherited from hard disk drives. These logical sectors map to portions of a page but do not represent erase units. In NAND flash, **pages are the smallest read/write units**, and **blocks are the smallest erase units**.