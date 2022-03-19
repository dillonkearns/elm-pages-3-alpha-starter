# README

This is a starter to try the elm-pages 3.0 alpha. Any feedback would be very helpful for getting the release ready to go!


## Setup Instructions
You can clone this repo with `git clone --recurse-submodules https://github.com/dillonkearns/elm-pages-3-alpha-starter.git`.

`npm install` from the cloned repo. Before running the dev server or build, make sure to install Lamdera (see below).


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

Check out [the 3.0 Package Docs](https://elm-doc-preview.netlify.app/?repo=dillonkearns%2Felm-pages&version=serverless-latest). The 3.0 docs are still a work in progress. As part of the final release, I will be going through and filling in documentation and updating missing docs. Feel free to make a pull request to update or add docs, or share feedback on the APIs and naming.

You can also use `npx elm-pages docs` from your project to view the documentation for the `RouteBuilder` module.
