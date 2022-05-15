# SBOS

**Table of contents**
1. **[Why ?](#the-why)**
2. **[How to run on a linux machine](#how-to-run-on-a-linux-machine)**
3. **[Future plans](#future-plans)**
4. **[What is not going to be implemented in the future](#what-is-not-going-to-be-implemented-in-the-future)**
5. **[Current bugs](#current-bugs)**

---

<br>

## The why

So, I have a professor in my university that is responsible to teach me and the rest of the class about operating systems and I really liked the subject and I still do. Now you see, I failed to get a passing grade, **alongside the  80% of the class**, so I decided to make this operating system as a gift to my professor and because I really like low level programming. Also, I do not hate the professor, if anything I really like his lessons although I still feel a bit sour about the grade I got.

Now let me say this, this small project of mine should not be taken seriously at all, I am someone who knows very few things in assembly and how to write a bootloader. I made this because I wanted to, not because it has some meaning to anyone else other than me.

<br>

## How to run on a linux machine

To run the OS under an emulator you will need [Qemu](https://www.qemu.org/) and [nasm](https://www.nasm.us/), after you have those installed on your linux machine just use the make.sh file I included in the repository by typing the following command

```
> bash make.sh
```

<br>

## Future plans

I plan on improving the OS as much as I can with my limited knowledge and my depleting sanity, that includes:

1. ~~Restructuring the code to make it easier to read~~
2. ~~Improving the code~~
3. ~~Adding new features~~
4. Fixing the notepad application so it works properly

If anything my **top priority** is improving the code itself so I can make the OS smaller in size and making it more readable, after that is done I will improve the notepad application to make it more user friendly and only then I will focus on adding new features to the operating system itself.

<br>

## What is not going to be implemented in the future

There are two primary things I won't include to this OS of mine, that is making it 32 or 64bit because there is no reason to do that, I can't really use that much computing power. The second thing is any networking except for maybe a crossover ethernet cable so that two computer with this OS installed can communicate to each other although that is **very** unlikely because let's be honest with ourselves, who is going to run this OS to more than one computer ?

<br>

## Current bugs

1. There is a bug when you press a character on a line that's not the first line where if you type something over an existing character it will just freeze the OS
2. Maybe something in the brainfuck interpreter, I am not sure since I haven't tested it that much, I will test it more once I gather the willpower

<br>

---

*Current version: 1.0.3*
