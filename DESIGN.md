_Do one thing and do it well._

This is supposed to be a static site generator for people looking to get a super simple place to publish posts on running. Nothing more, nothing less.

### Dependencies

Less is more. Ideally an implementation should have zero dependencies, but clean, manageable, and _simple_ code takes precedence. Therefore, more complex components like a markdown parser or a templating language/engine are reasonable dependencies, while more mundane things should be implemented in this codebase.

### Features

Given an arbitrary number of markdown files, 

- build a HTML page for each file including the parsed markdown and any relevant metadata
- build a table of contents presenting and linking to all built pages

This is a very loose specification, but I'm not a standards body so that's alright.
