# Brain

Create a `knowledge graph` from `markdown` documents

This project still has `alpha status`

## requirements

installed packages for

* uuid
* dot
* elixir ~> 1.7

## memories

Memories are placed in `priv/memories`

Every memory has an `header` with an id, a title, and possible links.
The id should be an `uuid`.

```
title: Example memory
links
  - 156e3432-4995-11ea-8b44-8fcb8a4ac214
```

The header should be placed at first as a mardown code block.
The format must be parsable as `yaml` format.

Everything after it can be simple markdown content.

You can take a look at the `priv/memories` folder for more examples.

You can use the [create.sh](create.sh) script to get a memory scaffold.

## generating examples 

`brain` will output `dotlang`, so the output of

```
$ brain --all 
```

will be

```
graph {
        node [fontname="helvetica" shape=none];
        graph [fontname="helvetica"];
        edge [fontname="helvetica"];

        splines=curved;
        style=filled;
        K=1.5;

        x54d5db6c498f11ea9aca2730c9a77870 -- x6fac4c0a498f11eaa5ab9fc7267c3a49;
x9604dc6a498e11eaa8ba5735c97c7a5a -- xb67cf9fa498e11ea98143bf9bced96b6;
x9604dc6a498e11eaa8ba5735c97c7a5a -- xcfceb538498e11eaab5c33d1551dabc7;
xb67cf9fa498e11ea98143bf9bced96b6 -- xe7603e24498e11eaaed53f642ea71551;
xb67cf9fa498e11ea98143bf9bced96b6 -- x059f7f1c498f11eaac79e3793c82252c;
x059f7f1c498f11eaac79e3793c82252c -- x54d5db6c498f11ea9aca2730c9a77870;
xe7603e24498e11eaaed53f642ea71551 -- x059f7f1c498f11eaac79e3793c82252c;

        x54d5db6c498f11ea9aca2730c9a77870 [label=< ecto >];
x9604dc6a498e11eaa8ba5735c97c7a5a [label=< elixir >];
xb67cf9fa498e11ea98143bf9bced96b6 [label=< hex.pm >];
xcfceb538498e11eaab5c33d1551dabc7 [label=< mix >];
x059f7f1c498f11eaac79e3793c82252c [label=< phoenix >];
xe7603e24498e11eaaed53f642ea71551 [label=< plug >];
x6fac4c0a498f11eaa5ab9fc7267c3a49 [label=< sql >];
      }
```

when you pipe it to a `dotlang` processor, you get

```
$ brain --all | fdp -Tpng > all.png
```

![all][all]

`brain` will do a full text search in all accesable markdown dokuments, so you can do something like

```
$ brain --search sql | fdp -Tpng > /tmp/sql.png
```

and you get a sub graph with

![sql][sql].

## build

```
$ make
if [ ! -d deps ]; then mix deps.get; fi
Resolving Hex dependencies...
Dependency resolution completed:
Unchanged:
atomic_map 0.9.3
earmark 1.4.3
yamerl 0.7.0
yaml_elixir 2.4.0
* Getting earmark (Hex package)
* Getting yaml_elixir (Hex package)
* Getting atomic_map (Hex package)
* Getting yamerl (Hex package)
mix compile --force --warnings-as-errors
===> Compiling yamerl
==> atomic_map
Compiling 1 file (.ex)
Generated atomic_map app
==> yaml_elixir
Compiling 6 files (.ex)
Generated yaml_elixir app
==> earmark
Compiling 1 file (.yrl)
Compiling 2 files (.xrl)
Compiling 3 files (.erl)
Compiling 32 files (.ex)
Generated earmark app
==> brain
Compiling 5 files (.ex)
Generated brain app
```

## install

```
$ make install
if [ ! -d deps ]; then mix deps.get; fi
mix compile --force --warnings-as-errors
Compiling 5 files (.ex)
Generated brain app
mix do escript.build, escript.install --force
Generated escript brain with MIX_ENV=dev
* creating /home/gooose/.asdf/installs/elixir/1.9.2/.mix/escripts/brain

warning: escript "brain" overrides executable "/home/gooose/src/project/brain/brain" already in your PATH
```

## Configure

Currently the [config.ex](config/config.exs) file is used to configure the `brain`

```
config :brain,
  memory_paths: ["priv/memories/"]
```

All given paths will be merged.
So you can add for example a path for private stuff as well as work related stuff.
You can also link memories between the different locations.

## idea 

As a normal brain you can add something like `short time memory`, 
where you can only acces things not older than a year.
This prevents poluting the whole graph, where you can see nothing.

This is like the real world. 
When you are trying to remember a more general thing, you get too much infomation.
You only get the `best connected` or the newest memories.

## Contact

Jan Frederik Hake, <jan_hake@gmx.de>. [@enter_haken](https://twitter.com/enter_haken) on Twitter.

[all]: examples/all.png
[sql]: examples/sql.png
