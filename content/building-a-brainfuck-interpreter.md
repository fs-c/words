{ "title": "Building a Brainfuck Interpreter", "date": "2018-06-14" }

>**Brainfuck** is an [esoteric programming language](https://en.wikipedia.org/wiki/Esoteric_programming_language) created in 1993 by [Urban Müller](https://en.wikipedia.org/w/index.php?title=Urban_M%C3%BCller&action=edit&redlink=1), and notable for its extreme minimalism. The language consists of only eight simple commands and an [instruction pointer](https://en.wikipedia.org/wiki/Instruction_pointer). While it is fully [Turing complete](https://en.wikipedia.org/wiki/Turing_completeness), it is not intended for practical use, but to challenge and amuse [programmers](https://en.wikipedia.org/wiki/Programmers). Brainfuck simply requires one to break commands into microscopic steps.
>
>From the [Wikipedia Article](https://en.wikipedia.org/wiki/Brainfuck) on brainfuck

Created only for amusement and as a challenge to its creator (namely to implement the smallest possible compiler), both creating compilers and interpreters for, and writing actual programs in it, are an interesting and enjoyable exercise even now.

The former will be the focus here, for I’ve been toying around with implementing both an interpreter (written in C) and a brainfuck to C compiler (also in C). For someone who is just starting out on the journey of learning C these were formidable challenges, and I hope to be able to share some of the insights gained from them.

That is probably best done by diving right into code, so let’s first get the basic skeleton out of the way:

```C
#include <stdio.h>

#define MAX_LENGTH 9999

int main(int argc, char **argv)
{
	int cls[MAX_LENGTH];	// Cells.
	int ins[MAX_LENGTH];	// Instructions.

	int ilen = 0;           // Number of instructions.
    
	// Pointers to currently active cell and instruction, respectively.
	int *ptr = cls;
	int *iptr = ins;
	
	return 0;
}
```

These are almost all the variables we’ll need, but it doesn‘t really reveal any of the program structure just yet. Before getting to that we’ll have to get the reading of the brainfuck code to interpret out of the way, so let’s expand what we have so far with some file streaming and reading logic.

```C
int main(int argc, char **argv)
{
    if (argc < 2) {
		puts("expected arguments");
		return 1;
	}
	
    /* ... */

	FILE stream, *fopen();

    // Open the file given as first argument with read permissions.
    stream = fopen(argv[1], "r");

	// Read the brainfuck to execute from the stream.
	while (ilen < MAX_LENGTH && (ins[ilen] = getc(stream)) != EOF)
		ilen++;

	fclose(stream);
	
	return 0;
}
```

So we now accept a single (required) argument which is to be a file or a path to one, and read it into `ins`. Afterwards we close the stream to tie up any loose ends and to free up memory.

Time to get to the meat of the matter: processing the brainfuck code. The most obvious solution would be to have a `for` loop go over every character to evaluate it, but we‘ll be using a `while` loop. The reason for this will become apparent soon, but let me foreshadow a bit: The `[` and `]` characters, used to loop, will have to move `iptr` around. While a `for` loop would work in theory, this gets more obvious the way it is implemented here.

Something that might also go unnoticed and cause confusion down the road is cell initialization. The brainfuck specification requires that all cells be initialized to zero - which is quite reasonable, output would be unpredictable, otherwise.

With those minor problems out of the way, the code is fairly simple:

```C
int main(int argc, char **argv)
{
	/* ... */
    
    // Initialize all cells to zero.
	memset(cls, 0, MAX_LENGTH);
    
    // While iptr points to a character in ins, handle the char. 
    while ((iptr - ins) < ilen) {
        switch (*iptr) {
        case '+':
			++*ptr;		// Increase the value of the current cell.
			break;
		case '-':
			--*ptr;		// Decrease.
			break;
		case '>':
			++ptr;		// Move the pointer forwards by one.
			break;
		case '<':
			--ptr;		// Backwards.
			break;
		case '.':			// Output the character at the current cell.
			putchar(*ptr);
			break;
		case ',':
			*ptr = getchar();	// Read a single character from stdin into the current cell.
			break;
    	}
        
        // Move to the next instruction.
        iptr++;
    }
    
    putchar('\n');
    
    return 0;
}
```

Now, while this doesn’t cover all of brainfuck, it *does* allow us to play around with some basic brainfuck code and to test out what we’ve done so far.

So, if you go ahead and compile and run this, you’ll already be able to try some simple stuff and see the interpreter in action.

```bash
$ echo ">> ++ << >> ." > bf.txt
$ gcc main.c && ./a.out bf.txt
2
```

The `>`s and `<`s are just there for demonstration purposes, they don’t actually do anything meaningful here. Go ahead and try something like `, ++ .`, both input and output should already operate as expected.

Now, to implement the looping, I feel like it is best to go through the two loop characters in reverse order - first `]` (which “closes” a loop), then `[` (“opening” a loop).

The reason for this is that, at first execution, the `[` will usually be skipped - to be more exact, it is skipped ( = moves to the next instruction without doing anything) if the value at the current cell is nonzero.

This is the exact opposite of `]`s bahaviour, which will only act if the value at the current cell is nonzero. If that condition is fulfilled, it will move the instruction pointer back to the command *after* the matching `[`. So, unless you are using it to purposefully skip a block of code, the `[` will only be relevant as a guide for the `]` and only very rarely execute its logic.

Naturally, if `]`s condition (current cell nonzero) is not fulfilled it will move the instruction pointer forwards, instead of backwards to the matching closing bracket.

Now, getting to the logic of `[` , if the current cell is zero it will move the instruction pointer to the command *after* the matching `]`, essentially skipping the block of code within the two brackets.

Now, this might seem rather intimidating, maybe even counter-intuitive, but the code for it is fairly simple once you’ve wrapped your head around it.

```C
int brk = 0;		// Keep count of open bracket pairs.

/* ...while... */

switch (*iptr) {
/* ... */
case '[':
	if (*ptr != 0)
		break;

	++iptr;
	// Jump forwards to matching closing brace.
	while (brk > 0 || *iptr != ']') {
		if (*iptr == '[')
			brk++;
		if (*iptr == ']')
			brk--;

		++iptr;
	}
	break;
case ']':
	if (*ptr == 0 && ptr++)
		break;

	--iptr;
	// Jump backwards to matching opening brace.
	while (brk > 0 || *iptr != '[') {
		if (*iptr == '[')
			brk--;
		if (*iptr == ']')
			brk++;

		--iptr;
	}

	--iptr;
	break; 
}
```

This is a full implementation of the looping in brainfuck, and it looks like quite the handful at first.

Lets look at one of these loops in more detail, to explore how they work:

```C
while (brk > 0 || *iptr != ']') {
	if (*iptr == '[')
		brk++;
	if (*iptr == ']')
		brk--;

	++iptr;
}
```

The condition is the crucial element here, more specifically the `||`. The whole loop can be described as *“While there are open brackets, do stuff to get them to go away. Now, if there are no open brackets, and the current instruction is not the closing bracket we are looking for, do stuff to get it to be the one.”*

This “stuff” that is being done is really simple. First come the checks that allow us to ignore “child bracket-pairs” - brackets that are inside the pair we are searching in. After these, just increment the instruction pointer, moving to the next instruction.

Now, having implemented the looping, we are essentially done. The interpreter is fully implemented, and the last thing left over for us to do is testing.

My go-to brainfuck snippet to test if my loop implementations work, is the following: `, [ -> +< ] . `. It will, in essence, copy a single character from stdin to stdout by looping from 0 to the value of the character, and incrementing the next cell by one for every loop execution.