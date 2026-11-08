---
title: 'MQTT Explained in Simple Terms: The Lightweight Protocol That Powers the Entire IoT World'
date: 2026-02-17
permalink: /posts/2026-02-17-mqtt-protocol/
tags:
  - discuss
  - learning
  - C
  - beginners
---

**MQTT (Message Queuing Telemetry Transport)** is a lightweight, standards-based messaging protocol designed for **machine-to-machine (M2M)** and **Internet of Things (IoT)** communication.

It is optimized for Low bandwidth, High latency networks, Resource-constrained devices like microcontrollers. Unlike HTTP, MQTT does **not** use request–response. Instead, it uses a **publish/subscribe** communication model.


![MQTT](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ycf5212og889e25x662q.jpeg)

## **Why is the MQTT protocol important?**

The MQTT protocol has become a standard for IoT data transmission because it delivers the following benefits:

- **Lightweight and efficient:** MQTT implementation on the IoT device requires minimal resources, so it can even be used on small microcontrollers. For example, a minimal MQTT control message can be as little as two data bytes. MQTT message headers are also small so that you can optimize network bandwidth.
- **Scalable:** The protocol has built-in features to support communication with a large number of IoT devices. Hence, you can implement the MQTT protocol to connect with millions of these devices.
- **Reliable:** Many IoT devices connect over unreliable cellular networks with low bandwidth and high latency. MQTT has built-in features that reduce the time the IoT device takes to reconnect with the cloud. It also defines three different quality-of-service levels to ensure reliability for IoT.
- **Secure:** MQTT makes it easy for developers to encrypt messages and authenticate devices and users using modern authentication protocols, such as OAuth, TLS1.3, Customer Managed Certificates, and more.

## **Principle behind MQTT**

MQTT is built around the **publish-subscribe communication model**, which is fundamentally different from the traditional client–server approach.

In a typical client–server system, a client directly requests data from a server, and the server responds with the requested information. This creates a **tight coupling** between both sides. The client must know where the server is and both must be available at the same time.

But MQTT removes this direct dependency by introducing an **intermediary called a broker**. Instead of sending messages directly to each other, devices communicate through the broker:

- A device that sends data is called a **publisher**
- A device that receives data is called a **subscriber**
- The **broker** receives all published messages and delivers them to the appropriate subscribers based on topics

Because of this design, publishers and subscribers remain completely independent of each other.

This creates three beautiful kinds of freedom (called decoupling):

### **Space Decoupling: "I don't need to know where you live”**

Publishers and subscribers do not need to know anything about each other’s network details. They don’t exchange IP addresses, port numbers, or device identities.

Each device only knows the broker address and the topic it publishes to or subscribes to. This makes it easy to add, remove or replace devices without changing the rest of the system.

### **Time Decoupling: "I'll leave a message for you”**

In MQTT, publishers and subscribers do not need to be connected at the same time.

A publisher can send data even when subscribers are offline, and subscribers can receive data later when they reconnect (depending on QoS and session settings). This is especially useful for IoT devices that frequently go into sleep mode or experience unstable connectivity.

### **Synchronization Decoupling: "No waiting in line”**

Publishers and subscribers operate independently and do not block each other.

A publisher can send messages without waiting for subscribers to process them and subscribers can receive messages whenever they are ready. This asynchronous behavior makes MQTT highly efficient and suitable for real-time systems with limited processing power.

## **MQTT components**

MQTT follows the publish/subscribe model by defining a small set of core components. The most important ones are **clients**, the **broker** and the **connection** that links them.

### **MQTT client**

An MQTT client is **any device or application** that communicates using the MQTT protocol. This can range from a cloud server or mobile app to a small microcontroller running an MQTT library.

A client can play different roles:

- When it sends data, it acts as a **publisher**
- When it receives data, it acts as a **subscriber**
- A single client can do both at the same time

In simple terms, if a device connects to a broker and exchanges messages using MQTT, it is considered an MQTT client.

### **MQTT broker**

The MQTT broker is the **central communication hub** of the system. All MQTT clients connect to the broker and clients never communicate directly with each other.

The broker’s main responsibilities include:

- Receiving messages from publishers
- Filtering messages based on topics
- Delivering messages to all subscribed clients
- Managing client connections and sessions

In addition, the broker often handles:

- Client authentication and authorization
- Storing and delivering messages for disconnected clients
- Forwarding data to databases, analytics engines, or cloud services

Because of this, the broker plays a critical role in ensuring reliability, scalability, and security.

### **MQTT connection**

Communication in MQTT starts when a client establishes a connection with the broker.

The process works as follows:

1. The client sends a `CONNECT` message to the broker
2. The broker responds with a `CONNACK` message to confirm the connection

This communication happens over a **persistent TCP/IP connection**, which remains open while data is exchanged. All MQTT communication flows through this connection.

An important rule in MQTT is that **clients only connect to the broker**, never directly to other clients. This design keeps the system loosely coupled and easy to scale.

## **MQTT Topics**

A **topic** is a structured string that the MQTT broker uses to **route messages** between clients. Instead of sending messages directly to a specific device, MQTT clients publish messages to a topic and the broker decides which subscribers should receive them.

Topics are arranged in a **hierarchical format**, similar to folders in a file system, with each level separated by a forward slash (`/`).

**Example topic structure**

```
ourhome/groundfloor/livingroom/light
ourhome/firstfloor/kitchen/temperature
```

Each part of the topic adds context:

- `ourhome` → identifies the system
- `groundfloor` / `firstfloor` → identifies the location
- `livingroom` / `kitchen` → identifies the room
- `light` / `temperature` → identifies the device or data type

This hierarchy makes it easy to organize data logically and scale the system as more devices are added.

## **MQTT Publish**

**Publishing** is the process of sending data to the broker.

When an MQTT client publishes a message, it includes:

- A **topic** (where the message belongs)
- A **payload** (the actual data)
- Optional settings like QoS and retain flag

The payload is sent as raw bytes, which means the client is free to choose any data format, such as Plain text, JSON, Binary data, Sensor readings

**Example**

A smart lamp in a home automation system may publish:

```
Topic: ourhome/groundfloor/livingroom/light
Payload:ON
```

Once published, the message is delivered to **all clients subscribed to that topic**, based on broker rules.

point to remember:

Publishers do not know who receives the message. It only send data to a topic.

## **MQTT Subscribe**

**Subscribing** is how an MQTT client expresses interest in receiving certain messages.

To subscribe, a client sends a `SUBSCRIBE` request to the broker that includes:

- One or more topic filters
- The desired QoS level for each topic

After subscribing, the broker automatically forwards any matching messages to the client whenever data is published on those topics.

### **Example**

A mobile app that monitors home lighting may subscribe to:

```
ourhome/+/+/light
```

Every time a light publishes its state (`ON` or `OFF`), the app receives the update and can:

- Display the current status
- Update a counter of active lights
- Trigger notifications or automation rules

## **Quality of Service (QoS)**

In MQTT, **Quality of Service (QoS)** defines **how reliably a message is delivered** from a publisher to a subscriber.

Because IoT networks can be slow, unstable, or intermittent. MQTT allows developers to choose the **right balance between reliability, speed, and bandwidth usage**.

MQTT supports **three QoS levels**:

- QoS 0 – *At most once*
- QoS 1 – *At least once*
- QoS 2 – *Exactly once*

Each level provides a different delivery guarantee.

### QoS 0

QoS 0 delivers a message **at most once** (fire and forget). The message is sent **without any acknowledgment** from the receiver.

- Publisher sends the message
- No confirmation is expected
- Message may be lost if the connection fails
- It ensures fastest delivery, lowest bandwidth usage and no retry mechanism.


![QoS 0](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/wu4xhboppesy647ud7lv.png)

**Use cases**

Temperature and humidity readings, live sensor streams where occasional loss is acceptable

### QoS 1

QoS 1 guarantees that a message is delivered **at least once**. However, **duplicate messages are possible**.

1. Publisher sends message
2. Subscriber (via broker) sends an acknowledgment (`PUBACK`)
3. If no acknowledgment is received, the publisher retransmits
4. It ensures reliable delivery, it may contain duplicate messages and in this case moderate bandwidth is used.

![QoS 1](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/riz9qn50xb2f2u4ltsmw.png)

**Use cases**

Device control commands, status updates, alerts and notifications

### QoS 2

QoS 2 ensures that a message is delivered **exactly once**, with **no loss and no duplication**.

It uses a **four-step handshake**:

1. `PUBLISH`
2. `PUBREC`
3. `PUBREL`
4. `PUBCOMP`

This ensures both sender and receiver agree that the message was delivered once and only once.

It provides the highest reliability with the cost of increased overhead, higher latency, and greater memory usage.


![QoS 2](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/oqvt2dw46dak75vxhl0h.png)

**Use cases**

Financial transactions, billing data, critical industrial control messages


![QoS](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/jdmdezokvl8cxprtlx8f.png)


## **Last Will and Testament (LWT)**

In MQTT, **Last Will and Testament (LWT)** is a mechanism that helps detect **unexpected client failures**.

It allows an MQTT client to tell the broker in advance:

> *“If I disconnect suddenly or crash, publish this message on my behalf.”*


This feature is extremely useful in IoT systems where devices may lose power, crash, or disconnect due to unstable networks.

Without LWT, other systems would have **no way of knowing** whether a device went offline intentionally or failed unexpectedly.

LWT solves this problem by automatically informing subscribers about the device’s failure.

## Common MQTT question

**What Does a Will Message Contain?**
A will message is just like a normal MQTT message and includes:

- **Topic** - where the message will be published
- **Payload** - the message content
- **QoS level** - reliability of delivery
- **Retain flag** (optional)

**What Port does MQTT Normally Use?**
The standard port is 1883.

**Can you use MQTT without a broker?**
No

**What Protocol does MQTT use?**
The standard version uses TCP/IP.

**Can multiple clients publish to the same topic?**
Yes, Multiple clients can publish messages to the same topic.

**Is is possible to know the identity of the client that published a message?**
No, not unless the client includes that information in the topic or payload.

**What happens to messages that get published to topics that no one subscribes to?**
They are discarded by the broker.

**How can I find out what topics have been published?**
You can’t do this easily as the broker doesn’t seem to keep a list of published topics as they aren’t permanent.

**Can I subscribe to a topic that no one is publishing to?**
Yes, Subscribing to a topic does not require an active publisher.

**Are messages stored on the broker?**
Yes, but only temporarily. Once messages are delivered to all subscribers, they are discarded.
(See retained messages below.)

**What are retained messages?**
When you publish a message with the retain flag set, the broker stores only the last published message** for that topic.

This retained message is immediately sent to new subscribers when they subscribe to the topic. MQTT retains only one message per topic.


### Image sources
[All the images are from this youtube video](https://youtu.be/LTAm1R_4YYE?si=LPI4z6zkOzG-Ynw-)