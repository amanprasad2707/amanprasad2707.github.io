---
title: 'Discovering Hall Sensors: The Hidden Tech in Laptops and TWS Earbuds'
date: 2026-01-30
permalink: /posts/2026-01-30-discovering-hall-sensors/
tags:
  - discuss
  - learning
  - architecture
  - beginners
---

Have you ever wondered why your laptop screen turns off when you close the lid? Or how your True Wireless Stereo (TWS) earbuds, know when the charging case is open or closed? It all comes down to a clever little component called the Hall sensor. In this short post, I'll share a fun experiment I did that uncovers this tech in everyday devices.

## The Laptop Trick
It started with a simple curiosity. I placed a magnet near the edges of my laptop base and the display turned off! Why? Laptops use Hall sensors (named after physicist Edwin Hall) to detect magnetic fields. These sensors are typically embedded near the hinge or edges. When you close the lid, a small magnet in the display aligns with the sensor in the base and it signal the system to sleep or turn off the screen. By mimicking that with an external magnet, you can "trick" the laptop into thinking the lid is closed.

I even made a quick video demonstrating this.
![gif demonstrate how the laptop screen is off when it comes with the magnet](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/33ecl6rif44wd1ca5anq.gif)

[Watch the same demo in higher quality](https://drive.google.com/file/d/1FF5mvIboPbtt53mJtUKB2PfJWi54nwyD/view?usp=sharing)

## Extending to TWS Earbuds
Inspired, I dug into my TWS charging case. These cases also detect lid status to pause charging, play audio, or enter sleep mode. Sure enough, after some disassembly, I spotted a Hall sensor inside! It's positioned to react to a magnet in the lid, just like in laptops.
Here's a photo I took of the Hall sensor in the TWS.

![TWS circuit](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/uwcfydrr19x28ijize2m.jpg)

![TWS circuit](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ol0giplbu9uv0fb2s3vt.jpg)


![hall sensor in TWS](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/jwuwmd7mt11a3jh6hvmq.gif)

[Watch the same demo in higher quality](https://drive.google.com/file/d/1omv9YTGlJNzZh3EbewhAbpz1DXRb0cnx/view?usp=sharing)


The sensor is tiny but powerful, using the Hall effect to measure magnetic field changes and convert them into electrical signals that the device interprets.


## How Hall Sensors Work
A Hall sensor is a semiconductor that generates a voltage difference when exposed to a magnetic field perpendicular to the current flow.
In devices like laptops and TWS, this voltage triggers actions like screen off/on or power management.
Pro tip: If you're into hardware hacking, tools like a multimeter or Arduino can help you experiment with these sensors safely.

This discovery shows how universal tech like Hall sensors powers seamless user experiences across gadgets. Next time you close your laptop or pop open your earbuds case, give a nod to Edwin Hall!

If you've tried similar experiments or have tips on Hall sensor projects, drop a comment below. Thanks for reading! 🚀