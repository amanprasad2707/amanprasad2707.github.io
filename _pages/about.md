---
permalink: /
title: "About Me"
author_profile: true
redirect_from: 
  - /about/
  - /about.html
---



I am an Embedded Systems Developer at **Zaptics Research** with a background in Electronics and Communication Engineering from Panipat Institute of Engineering and Technology (PIET). I have a strong interest in Embedded Systems, Firmware Development, and the Internet of Things (IoT).

I enjoy working close to the hardware, understanding how electronic components communicate with microcontrollers, and writing firmware that makes hardware perform useful tasks.

For me, embedded engineering is not just about writing code. It is about understanding the complete system from hardware connections and communication protocols to firmware architecture, and debugging.

I use this website to document my engineering journey, share what I learn, showcase my projects, and write about the technical challenges I encounter along the way.

## My Interest in Embedded Systems

I have always been curious about how hardware and software work together. What interests me most about embedded systems is the ability to write software that interacts directly with physical hardware and controls how a device behaves.

I enjoy exploring microcontrollers, understanding how different components communicate, and learning what happens behind the scenes when firmware interacts with hardware. I am also interested in how embedded software is designed, debugged, and improved to make systems more reliable and efficient.

My interests mainly revolve around:

- **Firmware Development:** Developing embedded applications using C and C++.
- **Microcontrollers:** Exploring microcontroller architectures, peripherals, and hardware interfaces.
- **RTOS:** Understanding real-time systems, task management, and multitasking.
- **Communication Protocols:** Learning how devices exchange data through different communication interfaces.
- **IoT:** Exploring how embedded devices connect and interact with other systems over networks.
- **System-Level Development:** Understanding the relationship between hardware, firmware, memory, and system architecture.

I prefer understanding how things work internally rather than relying entirely on existing libraries and abstractions. I find the process of exploring datasheets, experimenting with hardware, debugging issues, and gradually understanding a system particularly interesting.

## Technologies and Tools I Work With

Technologies and tools I work with across embedded development, firmware projects, and hardware experimentation.

- **Programming:** C, C++, Python, JavaScript
- **Microcontrollers:** STM32, Espressif MCUs, AVR
- **Embedded Platforms:** ESP-IDF, STM32 HAL, Arduino, PlatformIO
- **RTOS:** FreeRTOS, Zephyr (Learning)
- **Communication:** UART, SPI, I2C, CAN, BLE, Wi-Fi, RS485, Modbus RTU, MQTT, HTTP
- **Development Tools:** VS Code, STM32CubeIDE, Arduino IDE, Git, GitHub, Logic Analyzers, Debugging Tools

I continue to expand my knowledge through hands-on development, experimentation, and working with hardware.

## Projects and Practical Experience

I believe practical implementation is one of the best ways to learn engineering. I try to apply the concepts I study by building systems, experimenting with hardware, and solving real technical problems.
Some of the major areas I have worked on include:

### 1. UART Bootloader and OTA Firmware Update System
*STM32 | ARM Cortex-M | ESP32 | UART | C | GitHub Actions*

Developed a custom UART bootloader for STM32 that receives firmware updates from an ESP32, which downloads the latest firmware from GitHub Releases.

- Designed Flash memory layout with separate bootloader and application sections.
- Implemented Flash erase and programming operations for firmware updates.
- Added CRC-based firmware integrity checks and application validity checks.
- Handled application startup, including stack pointer setup, vector table relocation, and bootloader-to-application handover.
- Integrated GitHub Actions CI/CD to automatically build and publish firmware releases on updates to the main branch.

### 2. STM32F407 Preemptive Task Scheduler
*Bare-Metal | ARM Cortex-M4 | C*

- Developed a preemptive task scheduler for STM32F407 using SysTick and PendSV exceptions for task scheduling and context switching.
- Implemented Round-Robin and Priority-Based scheduling with custom Task Control Blocks (TCBs).
- Implemented manual context switching by saving and restoring R4–R11 registers, with separate PSP and MSP stack management.

### 3. STM32F407 Peripheral Drivers and Sensor Library
*Bare-Metal | Register-Level Programming | C*

- Developed register-level GPIO, UART, SPI, and I²C drivers for STM32F407 using reference manuals and datasheets.
- Implemented sensor drivers for DHT11, DS18B20, and DS3231 RTC.
- Verified communication protocols, signal timing, and peripheral behavior using a logic analyzer.

### 4. IoT-Based QR Payment System
*STM32F407 | ESP32 | AWS IoT Core | MQTT | Razorpay | DynamoDB*

- Developed an STM32-based QR payment system with ESP32 for Wi-Fi connectivity and AWS IoT Core integration.
- Integrated Razorpay webhooks and DynamoDB to process payment events and publish transaction updates through MQTT.
- Implemented QR code display on OLED and real-time payment status updates.

## What I Enjoy Learning

I enjoy exploring the internals of embedded systems and understanding how processors, memory, and firmware interact. Some of the topics I particularly focus on include:

- **ARM Cortex-M Architecture:** Processor modes, privilege levels, exception handling, and the reset sequence.
- **Processor Internals:** AAPCS, register usage, stack frames, and exception entry and return (stacking and unstacking).
- **Memory and Boot Process:** Memory organization, linker scripts, startup code, vector tables, and bootloader design.
- **Interrupts and Peripherals:** NVIC, interrupt priorities, timers, DMA, and peripheral-level programming.
- **RTOS Internals:** Task scheduling, context switching, concurrency, synchronization, and inter-task communication.
- **Firmware Architecture:** Device drivers, hardware abstraction, debugging, and firmware update mechanisms.

I am also exploring Zephyr RTOS and automotive embedded software architectures.

## Technical Writing and Knowledge Sharing

I believe that explaining a technical concept is one of the best ways to understand it properly.

Whenever I learn something interesting or solve a challenging technical problem, I try to document it so that I can refer to it later and help others who are learning the same subject.

I write about topics such as:

- Embedded C and C++.
- Microcontroller architecture.
- ARM Cortex-M internals.
- Communication protocols.
- RTOS concepts.
- Firmware debugging and troubleshooting.

I also publish technical articles on **[Dev.to](https://dev.to/amanprasad)**, where I share practical explanations, experiments, and lessons from my engineering journey.

You can explore my technical articles through the Blog section of this website.

## My Approach to Learning

I prefer learning by building things.

When I come across a new concept, I try to understand its fundamentals, implement it on actual hardware, observe its behavior, and debug it when something goes wrong.

I believe that debugging is just as important as writing code. Understanding why something fails often teaches more than simply making it work.

I also enjoy reading technical documentation, exploring open-source projects, experimenting with development boards, and learning from other engineers.

My goal is to develop a strong understanding of embedded systems and become capable of designing and developing reliable firmware for real-world applications.

## Let's Connect

I enjoy connecting with people who are interested in embedded systems, electronics, firmware development, IoT, and automotive technologies.

If you are working on something interesting, have a technical question, or simply want to discuss embedded engineering, feel free to connect with me.

- **GitHub:** [Explore my projects](https://github.com/amanprasad2707)
- **Dev.to:** [Read my technical articles](https://dev.to/amanprasad)
- **LinkedIn:** [Connect with me](https://www.linkedin.com/in/amanprasad2707/)
- **Email:** [Get in touch](mailto:aprasad2707@gmail.com)
