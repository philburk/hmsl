[Home](../), [Tours](README.md)

# Composing with Morphs or Hierarchical Scheduling

HMSL has a lot of fun tools for playing with notes,
but at its heart is a theoretical framework based on the ideas of Larry Polansky and David Rosenboom. Please see the list of [papers](/docs/papers.md) for more background.

Let's explore some of those ideas.

## Shapes, Players, and Interpreters

A fundamental object in HMSL is the Shape. It is a multi-dimensional array in an arbitrary space.
Here is an example where a Shape represents notes in a melody. The zeroth dimension is "duration," then "pitch," and then "velocity."

    include hp:demo_player.fth
    demo.player

Use the "Draw" mode to edit each "Dim"ension.

See the [source code for demo_player.fth](https://github.com/philburk/hmsl/blob/master/hmsl/pieces/demo_player.fth).

A Player object is used to play a Shape. It uses an Interpreter to convert the Shape data into meaningful behavior.
Here is a piece where an Interpreter uses one shape to transpose a melody contained in another shape.

    include hp:demo_interpreter.fth
    demo.interpreter

See the [source code for demo_interpreter.fth](https://github.com/philburk/hmsl/blob/master/hmsl/pieces/demo_interpreter.fth).

## Collections

An HMSL piece can be defined as a hierarchy of objects.
A container that plays its children one after the other is called a Sequential Collection.
A container that plays all of its children at once is called a Parallel Collection.
Collections can contain other collections.

    include hp:demo_collection.fth
    demo.collection

See the [source code for demo_collection.fth](https://github.com/philburk/hmsl/blob/master/hmsl/pieces/demo_collection.fth).

A Collection can also have a custom Behavior that decides which children to play.
Here is a piece that plays Players—or even other Collections—in a random order.

    include hp:demo_behave.fth
    demo.behave

See the [source code for demo_behave.fth](https://github.com/philburk/hmsl/blob/master/hmsl/pieces/demo_behave.fth).

## Markov Chains

A Markov Chain uses a two-dimensional array of weights to decide which thing follows another. The things could be notes, other Collections, or just about anything.

    include hp:demo_structure.fth
    demo.structure

See the [source code for demo_structure.fth](https://github.com/philburk/hmsl/blob/master/hmsl/pieces/demo_structure.fth).

I hope these simple examples give you some idea of the basic objects used in HMSL. With these objects, it is possible to build more elaborate pieces.

[Next >> Score Entry](score.md)
