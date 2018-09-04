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

- _(edited)_ `ejs` has been replaced with `handlebars`, which is implemented in a number of different languages and should not be an obstacle to future porting efforts
- _(edited)_ the `moment` dependecy was removed and the only function that was used has been implemented in `utils.js`
- investigate `highlightjs` alternatives
	- use and implement external services for hosting formatted code snippets? (GitHub Gist, ...)
	- replace it with a more lightweight module (500kb minified, my god) and hope that equivalents exist in other languages
