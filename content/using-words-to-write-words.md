{ "title": "Using Words to Write Words", "date": "2018-09-19" }

I recently wrote [a thing](https://github.com/lw2904/words). It's a really simple static site generator built, 

>Because I don't see why I should have to use giants like Hugo or Jekyll if I just want to insert some parsed markdown into simple templates, and sacrifice easy tweaking and fine tuning while I'm at it.
>
>_from the `words` README_

## Implementing `words`

The idea is that the codebase should always be small and simple enough to allow for easy and quick fine tuning of the build process. The directory structure is designed to be intuitive, it strives to remove unneccessary complexity -- why abstract away something as simple as including a CSS file or two behind "themes" and "styles"? Why make it hard to adjust the templates content is inserted into?

The following is taken from the `words` README and gives a full overview of the directory structure that is expected and (partly) created.

```
├── content		# Your markdown files go here
│   │
│   ├── building-a-brainfuck-interpreter.md
│   ├── cheating-in-osu!mania.md
│   ├── ...
│   .
│
├── public		# The static page will be built to this folder and it is
│ 			# deleted and recreated in every run
│
├── static		# This folder and all of its contents will be copied to
│   │			# public/static on building
│   ├── css
│   │   ├── highlighting.css
│   │   └── markdown.css
│   ├── favicon.png
│   └── js
│       └── utils.js
│
└── templates		# mustache template files for the...
    │
    ├── front.html	# ..."landing page" -- you will most likely
    │			# want to edit this
    └── item.html	# ...items (aka posts -- markdown files)
```

In the past I've had rather mixed experiences with common SSGs like Hugo and Jekyll, who, with their drive and enthusiasm to make everything as accessible and configurable as they could, came to be huge, bloated, messes. Something as simple as setting up a basic blog with a theme I moderately liked required reading dozens of pages of documentation and caused me much frustration.

Well, I got fed up with it. There's zero configuration with `words` -- if you're unhappy with the way something works by default, _change it_. This is why I'm currently experimenting with different languages to use, because I want to make that experience as smooth and painless as possible. JavaScript was the most obvious choice for me, at first, but especially when comparing it to generators like hugo (which, have to hand it to them, is _really_ fast) any implementation using an interpreted language (but probably JS in particular) will end up being slower by several orders of magnitude.

My next idea was C, since speed is pretty much a given there, and considering the (purposefully) small scale of this project the usual issues of C codebases becoming very troublesome to maintain and work with seemed much more tame, in theory. But, after playing around with a C implementation for a little while, it quickly became clear that it just _wouldn't do_. Memory management and inflexible types made small, supposedly quick, changes and enhancements slow and prone to causing bugs and memory leaks, and the whole thing wasn't very pleasant to read. All in all, not something I'd consider a good fit to what this project needs -- an experience where a user can just intuitively make changes to the codebase, without having to spend hours understanding it, or having to worry about breaking something down the road.

But, even with C now clearly being out of the picture, I wasn't willing to just discard speed like that. In my opinion, JS is wonderful as long as it's in small doses and in the browser -- I've gotten very sceptical of the trend to write more and more "desktop" applications in interpreted languages like JS. Optimizing JS, especially when optimizing for scalability (think sites with thousands of markdown files to parse), can quickly turn a concise and "nice" codebase into a messy and "ugly" one.

And this is where I thought of [Dlang](https://dlang.org). Advertised as a language to "write fast, read fast, run fast", it seemed almost like a perfect fit. Its syntax is very C-like -- D code should look familiar to a vast majority of programmers -- and its integrated garbage collector and conveniently huge standard library made for a pleasant developing experience. Naturally, not all is perfect; it carries over many mistakes from the C realm, like default global visibility (NodeJS solves this beautifully with `const module = require('module')`), and some of the more advanced nuances of its syntax can seem very strange and unwieldy at first.

Still, in around 50% of the lines of code that the JS implementation took I was able to build a `words` implementation in D that not only runs more than ten times faster than its interpreted sibling, but also retains (and even improves upon) the concise and straightforward feel of the former.

The road to finding the perfect language for the job doesn't end here, of course -- maybe it never will. As of the time of writing this, both the JS and D implementation are kept around and being worked on, although development in JS focuses mostly on experimental features that can be quickly prototyped thanks to JS' flexibility, whereas in D it's mostly performance tweaks. So far I'm fairly happy with that, since the project is at a size where maintaining and working on two codebases side-by-side like this very much feels manageable (and beneficial).

>Update 10/2/18
>
>The `words` GitHub now exclusively contains the D sources. This has been done because, while the JS version was wonderful for quick prototyping, it just didn't live up to what `words` is trying to be.
>`node-words` can be found in my `v0` repo, and it still serves as a playground for features that might be implemented in the main version at some point.

## Writing Words

Another gripe of mine with Hugo in particular was the unclear workflow. You had the option to use `hugo new posts/path-to-new-file`, but you could also create them manually (although I still don't know if you're supposed to), and it always was a bit of a pain to get started.

Work is being done to prevent this, the barrier to actually start _writing_ things should be as low as possible. I'm still not entirely happy with how this is currently solved, but it's a decent solution for now, in my opinion.

All content files (internally referred to as `item`s) should follow this general format,

```
{ "name": "Using Words to Write Words", "date": "2018-09-19" }

I recently wrote [a thing](https://github.com/lw2904/words). 
It's a really simple static site generator built,  ...
```

To demonstrate the point that I made earlier: Currently, only the first line is parsed so if the front matter is somewhere else, or spans more than one line, the parsing will break. This can be observed in `item.d`

```D
Item parseItem(const string itemPath)
{
	immutable content = itemPath.readText;
	JSONValue j = content[0 .. indexOf(content, '\n')].parseJSON;

	/* ... */
}
```

If you require different functionality... well, the code's there.

## Deploying Words

`words` doesn't care how you actually publish your content, it just handles the build step for you and leaves you to use the generated content as you will. Two common cases are covered below, but the idea is that at this point you're left with having to host a couple of static files somewhere which can be done in many, _many_ ways.

### To GitHub Pages

The following script should be run from inside the root of the `words` directory, read more about GitHub Pages [here](https://pages.github.com/).

```bash
#!/usr/bin/env bash
# GitHub Pages integration

STAGING_PATH=$(pwd)
# Path to your github pages repo
GHP_PATH="/home/example/projects/<username>.github.io/"

# Build the site
./words

# Delete all non-hidden files and directories, to remove previous builds
find GHP_PATH -not -path '*/\.*' -delete

# Copy generated site over
cp public/* GHP_PATH

cd GPH_PATH

MESSAGE="site rebuild ($(date))"

# Commit and push content
git add .
git commit -m "$MESSAGE"
git push origin master

# Go back to where we started from
cd $STAGING_PATH
```

### To Your own Server

There's a bazillions ways of going about this but I like it simple.

```bash
# Build the site
./words

# Copy site to the server
scp -r public/* user@server:/var/www/site/
```