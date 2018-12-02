_Do one thing and do it well._

This is a static site generator. It should take some text files with some metadata (currently in the form of front matter), parse them, and insert relevant content into a HTML template. Additionally, it should generate an index page, listing and linking to all parsed files.

These are the minimum requirements. At the same time, it should never go too far beyond them.

### Dependencies

Less is more. Ideally an implementation should have zero dependencies, but clean, manageable, and _simple_ code takes precedence. Therefore, more complex components like a markdown parser or a templating language/engine are reasonable dependencies, while more mundane things should be implemented in this codebase.

### Features

Given an arbitrary number of markdown files, 

- build a HTML page for each file including the parsed markdown and any relevant metadata
- build a table of contents presenting and linking to all built pages

This is a very loose specification, but I'm not a standards body so that's alright.
