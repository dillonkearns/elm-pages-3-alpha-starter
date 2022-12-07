# README

This is a starter to try the elm-pages 3.0 beta. Any feedback would be very helpful for getting the release ready to go!

This branch is a setup for trying out elm-pages Scripts (the `elm-pages run` command) without an actual `elm-pages` app. You can use it by moving the `script/` folder (and any other files you'd like) into your project, whether it uses `elm-pages` otherwise or not!


Examples:

```shell
$ npx elm-pages run Stars --repo elm-graphql
fetch https://api.github.com/repos/dillonkearns/elm-graphql: 384.544ms
745
```

## Minimal Setup

All you need to run `elm-pages run` is the `script/` folder, and an installation of `elm-pages` and Lamdera. The rest is optional! Though
I recommend locking your `elm-pages` installation to a specific version with a `package.json` file rather than just using a globally installed version.

## What is elm-pages Script

I hope for this to be the easiest way to execute a pure Elm file from the command-line, and pull in data (like reading files or environment variables) or performing effects (like writing files, logging, or performing HTTP requests).

This is done using `elm-pages`' [DataSource](https://package.elm-lang.org/packages/dillonkearns/elm-pages-v3-beta/latest/DataSource) API. Using [`DataSource.Port`](https://package.elm-lang.org/packages/dillonkearns/elm-pages-v3-beta/latest/DataSource-Port),
you can define async JavaScript functions that execute in NodeJS. They receive JSON data, and send back JSON data, and they execute in parallel to other DataSource's, leveraging Node's strength for parallel I/O operations.

## Setup Instructions

You can clone this repo with `git clone -b script-only https://github.com/dillonkearns/elm-pages-3-alpha-starter.git`.

`npm install` from the cloned repo. Before running the `elm-pages run` command, make sure to install Lamdera (see below).

### Install Lamdera

[Install Lamdera with these instructions](https://dashboard.lamdera.app/docs/download).

`elm-pages` 3.0 uses the lamdera compiler, which is a superset of the Elm compiler with some extra functionality to automatically serialize Elm types to Bytes. That means there is no more `OptimizedDecoder` API, you can just use regular `elm/json` Decoders! And no more `DataSource.distill`, since types are now automatically serialized all those optimizations come for free.

### Debugging Lamdera Errors

Sometimes Lamdera will give compiler errors due to corrupted dependency cache. These messages will display a note at the bottom:

```
-- PROBLEM BUILDING DEPENDENCIES ---------------

...


Note: Sometimes `lamdera reset` can fix this problem by rebuilding caches, so
give that a try first.
```

Be sure to use `lamdera reset` to reset the caches for these cases. See more info about that in the Lamdera docs: https://dashboard.lamdera.app/docs/ides-and-tooling#problem-corrupt-caches

### Docs

Check out [the 3.0 Package Docs](https://package.elm-lang.org/packages/dillonkearns/elm-pages-v3-beta/latest/). The 3.0 docs are still a work in progress. As part of the final release, I will be going through and filling in documentation and updating missing docs. Feel free to make a pull request to update or add docs, or share feedback on the APIs and naming.

The docs for `elm-pages` Scripts is at https://package.elm-lang.org/packages/dillonkearns/elm-pages-v3-beta/latest/Pages-Script.

## Running the `elm-pages run` command

- `npm install`
- `npx elm-pages codegen Stars --repo elm-graphql` - now you can try out the generator! And you can tweak it, or even define new generator modules in the `codegen/` folder!
