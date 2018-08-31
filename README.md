# words

Because I don't see why I should have to use giants like Hugo or Jekyll if I just want to insert some parsed markdown into simple templates, and sacrifice easy tweaking and fine tuning while I'm at it.

Taking some inspiration from the people over at [suckless](suckless.org), this is a zero-configuration framework.

- __Want to change the .css of the markdown?__ `$ mv desired.css static/css/markdown.css`
- __Want to insert some custom HTML in every page?__ Go to `templates/item.html` or `front.html` and _do it_.
- __Want to exchange the code parser for some exotic asynchronous one?__ `words.js` is <100 LOC, it'll take you a minute or two at most.

### To get started...

```bash
$ clone https://github.com/LW2904/words.git
$ rm -rf words/content/*
```

Throw your markdown files into `content/`, optionally add some front-matter (see below) and you're good to go. 

`node words.js` will build the page in `public/`, you can do what you will from then on.

- Symlinking public to some folder your web server of choice is hosting
- Making `public/` a submodule pointing to `<NAME>.github.io` (et al)
- ...

### Front matter

Front matter. I hate it. But until I come up with an alternative to throwing some metadata in front of every file I write you can add some JSON at the beginning of an `item` (ergo anything in `content/`) and it will be parsed. This looks something like:

```
{ "name": "Front Matter and other Atrocities", "date": "2018-08-31T14:50:00" }
```

`date` can be in any format JavaScript's `Date.parse()` recognises, maybe I'll expand this at some point.