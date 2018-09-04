# words

Because I don't see why I should have to use giants like Hugo or Jekyll if I just want to insert some parsed markdown into simple templates, and sacrifice easy tweaking and fine tuning while I'm at it.

Taking some inspiration from the people over at [suckless](https://suckless.org), this project takes a zero-configuration approach.

- __Want to change the .css of the markdown?__ `$ mv desired.css static/css/markdown.css`
- __Want to insert some custom HTML in every page?__ Go to `templates/item.html` or `front.html` and _do it_.
- __Want to exchange the code parser for some exotic asynchronous one?__ `words.js` is <100 LOC, it'll take you a minute or two at most.

### To get started...

Clone the repository, 
```bash
$ clone https://github.com/LW2904/words.git
```

remove the example posts,

```bash
$ rm -rf content/*
```

and throw your markdown files into `content/`. If you haven't already, add some front-matter ([see below](https://github.com/LW2904/words#front-matter)) and you're good to go.

`node words.js` will build the page in `public/`, you can do what you will from then on.

- Symlinking public to some folder your web server of choice is hosting
- Making `public/` a submodule pointing to `<NAME>.github.io` (et al)
- ...

### Front matter

I hate it. But until I come up with an alternative to throwing some metadata in front of every file that's processed, you will have to add some JSON at the beginning of an `item` (ergo anything in `content/`) and it will be parsed. This looks something like:

```
{ "name": "Front Matter and other Atrocities", "date": "2018-08-31T14:50:00" }

Your content goes here. Yes, just don't mind the ugly blob at the top. The `name` element will be used as the heading for this item.
```

`date` can be in any format JavaScript's `Date.parse()` recognises, maybe I'll expand this at some point.

### Defaults

The default markdown CSS is in `static/css/markdown.css` and is straight up stolen from [sindresorhus/github-markdown-css](https://github.com/sindresorhus/github-markdown-css). It's the minimal amount of CSS needed to replicate GitHub's markdown look. [marked](https://github.com/markedjs/marked) is used to parse markdown.

CSS for the code highlighter is in `static/css/highlight.css` and [highlight.js](https://highlightjs.org/) is used. `highlight.css` is a slightly modified copy of the VScode 2015 theme provided by highlight.js.
