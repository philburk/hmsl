[Home](../), [Tours](README.md)

# Quick Introduction to Forth

Forth is the language that HMSL was written in. There are several advantages to Forth:

1. Forth is quick. In 1985 it could take two minutes to compile a simple C program. But a
   Forth program could compile in less than a second.
2. Forth is interactive. You can enter commands and program on-the-fly. This is handy if you are making music.
3. Forth is estendable. We wanted to create new language and Forth allows you to extend the basic language in many ways.

So let's give it a try. I will show you a few basic features of Forth, just enough so that you can experiment with HMSL.
If you want to learn Forth then there is a [complete tutorial](http://www.softsynth.com/pforth/pf_tut.php).

Forth has a "data stack" where you can put numbers. Let's put two numbers on the stack.

    23 45

HMSL will show you the numbers now on the stack.  You can move those numbers around.

    SWAP

In Forth this would be documented as "( a b -- b a )".
You can also do math on the top numbers.

    +

You should now see a 68 on the stack.  I you want to print a number  use a "dot".

    .

That prints the number at the top of the stack and removes it. You can combine multiple commands.

    11 7 DUP + SWAP - .

Hit the UP arrow on your keyboard. That let's you edit previous commands.

Forth has a dictionary full of words like SWAP and DUP. To see the list enter:

    WORDS

Note that Forth is generally case insensitive. So you could also use "swap dup", etc.
But we often use upper case words just to make it clear what is Forth and what is English.
For example, "You can swap numbers using SWAP".

Lets add a new word to the dictionary using a colon followed by the name of the word. A semicolon finishes the word.

    : SQUARE   DUP * ;

Now let's use our new word. We can pass it a 7 and get back 49.

    7 SQUARE .

We can do things multiple times in a loop.

    10 0 DO i . LOOP

This is probably enough Forth to let you experiment with HMSL.
You can crash Forth, just like most languages.
If you do then just quit HMSL and restart it.
Don't worry too much. People crash Forth all the time when they are programming.
It is part of the experience.

