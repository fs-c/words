{ "title": "The Beauty of Valgrind's 'memcheck'", "date": "2018-08-29" }

To someone who is used to programming in languages with a GC, even just dipping ones toes into the legendary language that is C can be intimidating. You'll worry about buffer overflows, memory leaks, and the much dreaded SIGSEV that will await you when dereferencing that one little harmless looking pointer that just happened to point into an empty void.

It's these things (among many others, admittedly) that eventually led to the massive popularity of languages that introduced more and more hand-holding. Now, that's not a bad thing per se, but the speed, size and speed (!) benefits of C can and should not be dismissed easily. It's gotten all too common to accept that simple "Hello World" applications use up hundreds of megabytes of RAM, or depend on massive system libraries to work.

But; I'm getting off track. The reason I am mentioning this, is that I feel like Valgrind  (especially the default  `memcheck` utility) is doing an amazing job at rightfully minimizing the fear of these things.

Put in their own words:

> The Valgrind tool suite provides a number of debugging and profiling tools that help you make your programs faster and more correct. The most popular of these tools is called Memcheck. It can detect many memory-related errors that are common in C and C++ programs and that can lead to crashes and unpredictable behaviour.

Where before, I would have never used `malloc` (et al) to create a dynamic array of outputs out of fear of a memory leak or even more tricky to find bugs down the road, I can now confidently say that I know that all of my memory is being `free`d appropiately and none of it goes missing (or even worse, corrupted).

Valgrind, for me, changes the mentality with which I write C code. Maybe you didn't have this fear to begin with. Maybe you were content with always pairing `malloc`s and `free`s closely enough to make them manageable, but many, many, programmers aren't. And Valgrind, which has been around for almost two decades now, is doing a great job at making C _manageable_ again.

I say manageable also because you will very frequently find yourself in the situation where you are using some huge other library to get things done, say `Xlib`, and these libraries will also allocate memory. They will also use `malloc` or some wrapper to deliver your data, thereby essentially putting potentially very large allocations of memory out of your direct control. Continuing the example of `Xlib`, you will have to `XFree()` every piece of data returned through pointers; with increasing complexity, it will very much become _hard to manage_.

Back to Valgrind. _Every call to `malloc` is wrapped and known_, which naturally also includes libraries and whatever else you might use in your software. Forgot to `XFree` something? Valgrind will let you know. I've discovered hundreds of little (and not so little) memory leaks and straight up bugs through this - who would've thought that an innocuous seeming function to fetch a window ID given a process ID could leak close to a hundred megabytes _each time it's run _ (admittedly, that is mostly owed to the somewhat weird design of X, but that's besides the point).

I strongly recommend to read the [Valgrind FAQ](http://valgrind.org/docs/manual/faq.html) and the [Quick Start Introduction](http://valgrind.org/docs/manual/quick-start.html#quick-start.intro) and I'm certain you will be surprised once running some of your projects under it.