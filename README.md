# SBOS

**Table of contents**
1. **[Introduction](#introduction)**
2. **[Why ?](#the-why)**
3. **[How to run on a linux machine](#how-to-run-on-a-linux-machine)**

---

<br>

## Introduction

SBOS (**S**imple **B**asic **O**perating **S**ystem) is a **16 bit** OS *(if you want to call it that, I personally avoid using the term OS when talking about this project)* written **purely in x86** assembly. This is just a fun project for me and I hope you like it as well or even better inspire you to do the same and write your own small 16 bit operating system from scratch, that would be amazing.

This project is no longer maintained.

## The why

So, I have a professor in my university that is responsible to teach me and the rest of the class about operating systems and I really liked the subject and I still do. Now you see, I failed to get a passing grade, **alongside the  80% of the class**, so I decided to make this operating system as a gift to my professor and because I really like low level programming. Also, I do not hate the professor, if anything I really like his lessons although I still feel a bit sour about the grade I got.

Now let me say this, this small project of mine should not be taken seriously at all, I am someone who knows very few things in assembly and how to write a bootloader. I made this because I wanted to, not because it has some meaning to anyone else other than me.

<br>

## How to run on a linux machine

To run the OS under an emulator you will need [Qemu](https://www.qemu.org/) and [nasm](https://www.nasm.us/), after you have those installed on your linux machine just use the make.sh file I included in the repository by typing the following command

```
> bash make.sh
```
