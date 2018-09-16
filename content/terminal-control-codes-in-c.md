{ "title": "Terminal Control Codes in C", "date": "2018-07-26" }

Many terminals (and terminal emulators) support color and cursor control through a system of escape sequences. A commonly supported and used standard is often referred to as "ANSI Colour", on which the VT100 terminal specification which we will be using is based.

A terminal control code is a special sequence of characters that is sent to `stdout` (like any other text). If the terminal understands the code it won't display the sequence, but will perform the action which correlates to the code.

As an example, the code which can be used to erase the screen looks like `<ESC> [ 2J` where `<ESC>` represents the ASCII escape character, 27. Spaces are ignored, and can be added for increased readability.

A more or less complete list of these sequences can be found on [termsys.demon.co.uk](http://www.termsys.demon.co.uk/vtansi.htm#status), but I'll explain the codes used here as we go along.

Now, the title says "in C", so here goes:

```c
#include <stdio.h>

#define ASCII_ESC 27

int main()
{
    setbuf(stdout, NULL);
    
	printf("%c[2J", ASCII_ESC);

	return 0;
}
```

The above snippet uses the code which was already introduced as an example to clear the screen; its behavior is very similar to the `CTRL + L` shortcut in bash.

A very important statement to note is the call to `setbuf()` in line 7, which disables buffering for stdout.

Having these control codes strewn about in code can only be considered a bad practice, so we're always going to write abstractions for them. This will help readability and make the code cleaner, not to speak of the fact that remembering and always typing these codes out in full can get very annoying, very quickly.

One such abstraction, which will come in very handy in the next few examples, could be called `move_cursor()`.

```c
void move_cursor(int x, int y)
{
	printf("%c[%d;%dH", ASCII_ESC, y, x);
}
```

The control code to move the cursor naturally has to accept arguments in the form of line and column numbers, which are passed directly after the `[` and seperated by semicolons. Note that the control code is defined as `[{row};{column}H`, which is why we first pass `y`, followed by `x`. The arguments to `move_cursor()` could also be called `line` and `column`, but I've found `x` and `y` to be more intuitive, not to speak of them being much quicker to type.

In combination with basic stdio functions we can do a great many things with `move_cursor()`. For example, drawing a line could be done with the following function.

```c
void draw_line(int slope, int width)
{
	for (int i = 0; i < width; i++) {
		move_cursor(i, (slope * -1) * i);

		putchar('#');
	}
}
```

The possibilities are endless, and I don't feel like it would add much value if I would provide more examples here - for an example use case (and implementation) do feel free to read through the code of [vt-space](https://github.com/LW2904/vt-space), a 2D space shooter in the terminal.