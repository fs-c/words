# `words`

![](https://github.com/lw2904/words/workflows/build/badge.svg)

Because I don't see why I should have to use giants like Hugo or Jekyll if I just want to insert some parsed markdown into simple templates, and sacrifice easy tweaking and fine tuning while I'm at it.

Taking some inspiration from the people over at [suckless](https://suckless.org), this project takes a zero-configuration approach.

- __Want to change the .css of the markdown?__ `$ mv desired.css static/css/markdown.css`
- __Want to insert some custom HTML in every page?__ Go to `templates/item.html` or `front.html` and _do it_.
- __Want to exchange the code parser for some exotic asynchronous one?__ `source/app.d` is <100 LOC, it'll take you a minute or two at most.

## To get started...

Download the latest build from the [releases](https://github.com/LW2904/words/releases) section. These are automatically built from the master branch on every push.

Throw your markdown files into `content/` (or tell `words` about their location with `--content`). If you haven't already, add some front-matter ([see below](https://github.com/LW2904/words#front-matter)) to the markdown files and you're good to go.

Running `./words-*` will build the page in `public/`, you can do what you will from then on.

- Symlinking public to some folder your web server of choice is hosting
- Making `public/` a submodule pointing to `<NAME>.github.io` (et al)
- ...

## Folder Structure

All utilities expect a folder structure like the following, relative to the current working directory.

```
├── [content]       # Your markdown files go here, the location can be
│   │               # customized
│   ├── building-a-brainfuck-interpreter.md
│   ├── cheating-in-osu!mania.md
│   ├── ...
│   .
│
├── public          # The static page will be built to this folder and it is
│                   # deleted and recreated in every run
│
├── static          # This folder and all of its contents will be copied to
│   │               # public/static on building
│   ├── css
│   │   ├── highlighting.css
│   │   └── markdown.css
│   ├── favicon.png
│   └── js
│       └── utils.js
│
└── templates       # mustache template files which are used to build the site
    │
    ├── front.html  # Template for the "landing page" - you will most likely
    │               # want to edit this
    └── item.html   # ...for the items (aka posts, markdown files, ...)
```

## Front matter

I don't like the way this is handled currently. But until I come up with an alternative to throwing some metadata in front of every file that's processed, you will have to add some JSON at the beginning of an `item` (ergo anything in `content/`) and it will be parsed. This looks something like:

```
{ "name": "Front Matter and other Atrocities", "date": "2018-08-31" }

Your content goes here. Yes, just don't mind the ugly blob at the top.
The `name` element will be used as the heading for this item.
```

`date` has to be in the ISO 8601 extended date format. Yeah, I had to look that up too, just format it like in the example above, kay?

## Options

The `--content`, `--public`, and `--templates` switches can be used to control input and output paths. They default to their respective names (i. e. `content/`, ...).

## Building from Source

Clone the repository,

```bash
$ git clone https://github.com/LW2904/words.git
```
get yourself a [D compiler](https://wiki.dlang.org/Compilers) and do

```bash
$ dub build
```

in the root of the project.
