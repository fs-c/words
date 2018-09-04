_Do one thing and do it well._

This is supposed to be a static site generator for people looking to get a super simple place to publish posts on running. Nothing more, nothing less.

### Dependencies

I tried to minimize reliance on depencies as much as possible. As a result, the only ones are: 

- `marked` to parse the markdown into HTML
- `ejs` to fill the templates with data parsed from markdown
- `highlightjs` for adding syntax highlighting tags to code snippets
- `moment` to generate the human readable relative time of released posts (e.g.: X months ago)

By design, none of these are heavily entrenched in the code and never should be.

### Goals

I consider `words` to be largely feature complete, which is not particularly hard considering it has only two features: building a table of contents, and building a number of pages for parsed posts. It does those two things reasonably well, so most of the focus now lies on the quality of the codebase.

A big goal is to eventually narrow down the dependencies to simply a markdown parser and maybe a syntax highlighter, since those are way out of the scope of this project.

I'm on this crusade against dependencies mainly because the idea is to eventually be able to port this into a number of different languges, many of which might not have equivalents for many modules that are currently in use. Porting this project over would be significantly easier if most of the logic were already in _this_ codebase, and narrowed down to what is actually needed.

Therefore, to make this feasible: 

- replace `ejs` with a self-built templating language only supporting the few features that are actually needed:
	- output tag (equivalent: `<%=`, escaped and unescaped)
	- looping (equivalent: `<% array.map((item) => { %> ... <% }) %>`)
- investigate `highlightjs` alternatives
	- use and implement external services for hosting formatted code snippets? (GitHub Gist, ...)
	- replace it with a more lightweight module (500kb minified, my god) and hope that equivalents exist in other languages
- replace `moment` since we only use one little function that should be easy enough to implement as standalone
	- if that proves to be too much of a hassle, just move back to the old post timestamp view