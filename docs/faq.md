# Frequently Asked Questions

## Why rewrite pico, again?

[Nano](https://www.nano-editor.org/) is a great editor, and I recommend using it if you are happy with it.
I used to use pico (companion of the Pine e-mail client, later the [Alpine](https://alpineapp.email/) project) for
many years, and was happy to find nano as an advanced version of that.  Tico is my attempt to address what I see as
its shortcomings:

* Syntax highlighting in nano is not good.  You can configure it with regex definitions and colors in your
configuration, but these do not give a good result, especially for dynamic languages like Perl (which I
work with often).  Tico takes a more opinionated approach, using tree-sitter grammars internally.  What you lose
is some individual configurability, but what you gain is better accuracy.  Tico also supports embedded
languages, so heredocs containing HTML or another language get the HTML highlighting.

* Nano keeps removing features.  They recently removed support for Mac Classic format text files.  This is quite
defensible in 2026, since classic Mac OS was discontinued a couple of decades ago.  For me it is kind of
annoying though, because I work with vintage systems (including an old Mac Plus which uses such text files),
and I am not sure how its removal benefits anyone.

* Tico handles file changes on-disk more gracefully.  If the buffer hasn't been modified and the on-disk
copy changes, tico will reload it.  If the buffer has been modified, it will allow you to load the new version,
keep your changes, or merge the two.  This is the sort of capability that has been available in modern IDEs
for many years.

There are some reasons you might want or need to keep using nano:

* Nano is a much smaller, lightweight executable.

* Nano is a more mature project.

## Why Rust?

I consider the language tico is written in to be an implementation detail, and you shouldn't need to think
about it very much as a user.  If one day it makes sense to reimplement tico in another language, I am all
for it.  There are some benefits to using Rust, which is why I chose it:

* Cross-platform support is relatively easy.  I can support Linux, macOS and Windows with a small amount of isolated
platform-specific code without having to worry about the different ways string functions work in libc.

## Is Tico the Toucan a Dinosaur?

Yes, as with all birds, Tico is a dinosaur.
