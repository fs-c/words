{ "title": "Learning to Code", "date": "2018-11-10", "hidden": true }

This is my take at attempting to convey the usefulness and beauty of programming to those new to the craft.

Here, you will have the opportunity to learn about some of the very basics of software development using __JavaScript__ (or JS for short) through studying __working code of practical relevance__. It is very much a __personal document__, as everyone absords and assimilates knowledge differently, but I don't feel like that should stop me from writing it down.

>JavaScript (not to be confused with Java) is a high-level, dynamic, multi-paradigm and weakly-typed language used for both client-side and server-side scripting. Its primary use is in rendering and performing manipulation of web pages
>
>From ["About JS"](https://stackoverflow.com/tags/javascript/info) on StackOverflow

While this is all well and good, we don't really care too much about what the above actually means for us, for now. The important thing to take away here, is that it's __primarily used on websites__ to render (convert data into a visual form) and manipulate them.

This means that your browser runs JavaScript code that is loaded alongside websites, which can then be used to make them interactive. To see a demonstration of your browser's JS interpreter just hit <kbd>F12</kbd> and switch to the "Console" tab.

You're now in the developer tools of your browser, which (among other things) provides you with a REPL -- a read–eval–print loop. It takes user input (in this case, JavaScript code), evaluates it, and prints the result.

![A demonstration of the REPL.](https://i.imgur.com/rxvvoks.gif)

For example, `Math.PI` is evaluated, and returned (ergo printed). Same for `Math.PI * 2`, the expression is evaluated and the result is returned.

A slightly more advanced example can be seen in the following screenshot.

![Demonstrating some more advanced features.](https://i.imgur.com/Ufvgnkd.png)

While this is pretty fun to play around with, and also great for learning and discovering new things thanks to the autocompletion suggestions, we want to write bigger, more complex scripts.

Now, as previously mentioned, JS is usually run on websites, in the browser. That's a bigger detour to actually programming things than I would like, so we are going to use [NodeJS](https://nodejs.org/en/) to run our code.

>Node.js is an event-based, non-blocking, asynchronous I/O framework that uses Google's V8 JavaScript engine and libuv library. It is used for developing applications that make heavy use of the ability to run JavaScript both on the client, as well as on server side and therefore benefit from the re-usability of code and the lack of context switching.
>
>From ["About node.js"](https://stackoverflow.com/tags/node.js/info) on StackOverflow

Yes. Got that? No? Well, that's ok. What you need to know is: NodeJS (commonly referred to as just "Node") can run JavaScript on your PC, without requiring you to load a website (be it local or not). To do that it uses the V8 engine, which is also used in Chromium, and therefore Google Chrome. (Assuming you don't use Firefox, you used V8 just now to play around with the REPL!)

It's mainly used on servers and to write quick little console scripts, but through a number of pretty neat frameworks, some beautiful desktop and mobile apps have been developed (Discord, Atom, parts of the Facebook App). To top it off, Node is Open Source (under the MIT license) and backed by the Linux Foundation.

Enough of that now, though, let's get into writing scripts using Node! Once you've installed Node, go ahead and fire up a terminal (Windows: search for "cmd" in the start menu), and type `node -v` to verify that you correctly installed NodeJS -- this should return the version of Node that is installed on your system.

![CMD window with the node -v command.](https://i.imgur.com/pZfJ70c.png)

Now, to see that I didn't just talk out of my ass earlier, try out the `node` command, without any switches or arguments. Lo and behold, it's a REPL!

![Node REPL inside a CMD window.](https://i.imgur.com/f3zL4eo.gif)

This is pretty nice and all, but we still haven't gotten to the point where we can actually run scripts, as in files containing JavaScript code. With NodeJS that's done by running `node <script>.js`, where `<script>` is the name of the file you want to run.

<script src="https://gist.github.com/LW2904/171a379fe525ca81660292f61b77566f.js"></script>

The above code introduces [function declarations](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/function), and [template literals](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals).

Okay, so in the beginning I mentioned "learning to code through studying working code of practical relevance". I will now throw (well commented) code at your feet, tell you what parts of it are new/important, and give you links to relevant documentation.

If you survive that for long enough, you can call yourself a programmer, congratulations.

Yeah so there should be something here but I'm not creative.
