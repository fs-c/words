_Do one thing and do it well._

This is supposed to be a static site generator for people looking to get a super simple place to publish posts on running. Nothing more, nothing less.

### Dependencies

I tried to minimize reliance on depencies as much as possible. As a result, the only ones are: 

- `marked` to parse the markdown into HTML
- `mustache` to fill the templates with data parsed from markdown
- `highlightjs` for adding syntax highlighting tags to code snippets

By design, none of these are heavily entrenched in the code and never should be. As an example, switching from `ejs` to `mustache` was a minor issue and only required minimal changes.

### Features

I consider `words` to be largely feature complete, so the following both represents what is currently implemented, and what is the goal.

Given an arbitrary number of markdown files, 

- build a HTML page for each file including the parsed markdown and any relevant metadata
- build a table of contents presenting and linking to all built pages

### Goals

As mentioned above, `words` currently does all it is asked to do, and reasonably well at that. Therefore, the main goal is to improve the codebase - making small enhancements where appropiate, fixing bugs, improving performance.

A big goal is to eventually narrow down the dependencies to simply a markdown parser and maybe a syntax highlighter, since implementing those would be way out of the scope of this project. I'm still on the fence on whether or not the templating should have it's own module (as is currently the case), or if it is feasible and reasonable to build a specific implementation.

I'm on this crusade against dependencies mainly because the idea is to eventually be able to port this into a number of different languges, many of which might not have equivalents to many modules that are currently in use, especially not lightweight and performant ones. Porting this project over would be significantly easier if most of the logic were already in _this_ codebase, and narrowed down to what is actually needed.

Therefore, to make this feasible: 

- _(edited)_ `ejs` has been replaced with `mustache`, which is implemented in a number of different languages and should not be an obstacle to future porting efforts
- _(edited)_ the `moment` dependecy was removed and the only function that was used has been implemented in `utils.js`
- investigate `highlightjs` alternatives (see issue [#3](https://github.com/LW2904/words/issues/3))
