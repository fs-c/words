{ "title": "So I Have a Blog Now", "date": "2018-06-10" }

...or: "Setting up a GitHub Pages backed Hugo blog".

>It should be noted that I do not use Hugo anymore, but this does not make this post any less valid. I switched to using [words](https://github.com/LW2904/words).

I'm not going to be writing an introduction, or some long winded talk about what I want this blog to be; rather, let me tell you about how I set this up, and what little hiccups I ran into.

Now, maybe as a preface of sorts, let me mention that this is the first time I am dabbling in static site generators. I say this not as some sort of excuse for technical inadequacy, but because there is a heated discussion going on, about the use of Hugo over Jekyll and vice versa. I'm not picking any sides, I'm choosing what has been recommended to me, and what my own research has shown to be the best fit for me. If you are on the fence yourself, I would like to encourage you to have a look at both of them, and to make your choice based on that.

But, enough of that; let's get down to business.

### Installing Hugo

I use both a Windows PC, and a Laptop running Linux to work on, so I went through, and am able to share, the (dead simple) installation process for both Operating Systems.

On Windows, you will want to download the appropriate .zip archive from the [Hugo Releases](https://github.com/gohugoio/hugo/releases), extracting the contained executable to a location that is convenient for you. Ideally you would move it somewhere in your `PATH` for convenience, on Windows that would be `C:\Program Files (x86)\` by default.

For users of Debian (or a derivate like Ubuntu) a .deb package is provided on the [Hugo Releases](https://github.com/gohugoio/hugo/releases) page, which, after downloading, can be installed with the following command

```bash
$ sudo dpkg -i hugo_*.deb
```

Alternatively, or if your distribution is not a Debian derivative, you may of course download the pre-built binary and move it to your `PATH ` (most likely `/usr/local/bin`), just like you would on Windows.

This is something beautiful about Hugo, where you have the option of simply downloading a pre-built binary without all the hassle of installing dependencies and build tools you might have with others (looking at you, Jekyll).

To verify your install run the following from anywhere:

```bash
$ hugo version
```

### Setting up a Basic Site

First, we'll want to create two new repositories on GitHub which we will be using to keep our unbuilt Hugo site, and the rendered static version, respectively.

Note that the second repository which will be hosted on GitHub pages has to be called `<USERNAME>.github.io`.  In this example, the first repository will simply be called 'blog'.

After creation,

```bash
$ git clone git@github.com:<USERNAME>/blog.git
$ git clone git@github.com:<USERNAME>/<USERNAME>.github.io.git
```

Now, since Hugo does not ship with a default theme, we'll have to choose one from the [available themes](https://themes.gohugo.io/). The one that is being used in this blog is simply called [slim](https://themes.gohugo.io/slim/), and we will be using it in this example as well.

```bash
$ cd blog
$ git submodule add https://github.com/zhe/hugo-theme-slim.git themes/slim
```

Additionally, we'll want to add our `<USERNAME>.github.io.git` repository as a submodule in the `public/` directory. Hugo will build the site from the content and source files in the `blog` repository, to the `public` directory - which has our GitHub pages repository as its remote origin.

```bash
$ git submodule add https://github.com/<USERNAME>/<USERNAME>.github.io.git
```

The [Hugo docs](https://gohugo.io/documentation/) provide a great script, automating some steps of pushing a new version of the blog to GitHub pages, it is copied in full here: 

```bash
#!/bin/bash

# deploy.sh

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
hugo -t slim # if using a theme, replace with `hugo -t <YOURTHEME>`

# Go To Public folder
cd public
# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

# Come Back up to the Project Root
cd ..
```

Make it executable, and run it:

```bash
$ sudo chmod +X deploy.sh
$ ./deploy.sh  "Optional commit message."
```

### Adding Content

My workflow when writing a new post is rather simple, and as follows:

```bash
$ hugo new content/post/new-post.md
$ vim content/post/new-post.md
```

This newly created file will have some default [Front Matter](https://gohugo.io/content-management/front-matter/#readout) added, which will look something like this:

```yaml
---
title: "New Post"
date: 2018-06-11T16:54:19+02:00
draft: true
---
```

Note how the title is read from the filename, and automatically capitalized to follow the MLA style of capitalization for headlines.