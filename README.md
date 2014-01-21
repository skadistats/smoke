**WIP: This entire document is very new. Please submit corrections!**

# smoke

Relatively fast, complete replay parser written in cython. Cython is a Python-
like language which is processed into C and then compiled for C-like speed.

smoke parses replays at or faster than 88x game time. So if a game lasted 44
minutes, expect parsing to take around 30 seconds.

If speed is of paramount concern for your use case, or if you prefer Java,
check out [clarity](https://github.com/skadistats/clarity). It is comically
fast--even cython can't compete.


# Installation

smoke is authored using python 2.7.x*. 

If you use a [Unix-like](http://en.wikipedia.org/wiki/Unix-like) operating
system (Linux or Mac OS X), installating smoke should be pretty painless.
**Windows hackers, halp! If you figure out how to get it running on Windows,
let us know. It should be possible.**

First, you need a C compiler. OS X users will need to install the Xcode
"Command Line Tools" from
[Apple](https://developer.apple.com/downloads/index.action) and a package
manager like Homebrew or MacPorts. Ubuntu users may want to install the
`build-essential` package for a quick, standard compiler:

    sudo apt-get install build-essential

You will need the `snappy` development libraries. Mac OS X users can get this
easily with Homebrew or MacPorts. With Homebrew, for example:

    brew install snappy
    brew install protobuf

In Ubuntu, you might install dependencies thusly:

    sudo apt-get install libsnappy-dev libsnappy libprotobuf-dev libprotobuf

Next, you must install palm 0.1.9 from source--it's not in PyPI, so you can't
get it with pip:

    $ git clone https://github.com/bumptech/palm.git && cd palm
    $ python setup.py install

Finally, install smoke by cloning it:

    $ git clone https://github.com/skadistats/smoke.git && cd smoke
    $ python setup.py install

That's it! You're good to go.

\* Python 3 support might be possible, if our
[protobuf library](https://github.com/bumptech/palm) is compatible. Figuring
this out is not a priority for us, but feel free to conduct your own
investigation. Happy to accept pull requests for Python 3 support.


# Using smoke

smoke parses only the data you're interested in from a replay. Here are the
kinds of data it can parse (optionally) from files:

* **entities**: in-game things like heroes, players, and creeps
* **modifiers**: auras and effects on in-game entities
* \***voice data**: the protobuf-formatted binary data blobs that are somehow
strung into voice--only really relevant to commentated pro matches
* \***"temp" entities**: fire-and-forget things the game server tells the
client about... and then never mentions again
* \***user messages**: many different things, including spectator clicks, global
chat messages, overhead events (like last-hit gold, and much more)
* \***game events**: lower-level messages like Dota TV control (directed camera
commands, for example), combat log messages, etc.
* \***sounds**: sounds that occur in the game

An asterisk above denotes "transient" data--data that changes completely each
tick of the game. Non-transient data is instead updated at each tick.
Understanding this difference will help you make sense of the data as you
parse.

By default, smoke parses everything. This is the slowest parsing option. Here
is a simple example which parses a demo, doing nothing:

    # entity_counter.py
    import io

    from smoke.io.wrap import demo as io_wrp_dm
    from smoke.replay import demo as rply_dm

    with io.open('37633163.dem', 'rb') as infile:
        # wrap a file IO as a "demo"
        demo_io = io_wrp_dm.mk(infile)

        # read the header that occurs at demo start
        demo_io.bootstrap() 

        # create a demo with our IO object
        demo = rply_dm.mk(demo_io)

        # read essential pre-match data from the demo
        demo.bootstrap() 

        # this is the core loop for iterating over a game
        for match in demo.play():
            # this is where you will do things!
            pass

        # parses game summary found at the end of the demo file
        demo.finish()

When run with `time python entity_counter.py`, we get:

    real    0m40.974s
    user    0m40.752s
    sys     0m0.209s

Perhaps you want to be more selective about parsing. We do this by bitmask.
Here's code similar to the above, but more restrictive about what it parses.
Consequently, it'll be tons faster:

    # with_less_data.py
    import io

    from smoke.io.wrap import demo as io_wrp_dm
    from smoke.replay import demo as rply_dm
    from smoke.replay.demo import Game

    with io.open('37633163.dem', 'rb') as infile:
        demo_io = io_wrp_dm.mk(infile)
        demo_io.bootstrap() 

        # it's a bitmask -- see smoke.replay.demo for all options
        parse = Game.All ^ (Game.UserMessages | Game.GameEvents | Game.VoiceData)
        demo = rply_dm.mk(demo_io, parse=parse)
        demo.bootstrap() 

        for match in demo.play():
            pass

        # parses game summary found at the end of the demo file
        demo.finish()

When run with `time python with_less_data.py`:

    real    0m36.676s
    user    0m36.469s
    sys     0m0.201s

If you **only** need `UserMessages` or `GameEvents` (for example), you end up
with 5 second parses. So parse as little as you can!

Take a look at `smoke.replay.match` to see which properties you can play with
while `play`ing a demo.

# Rough Edges

Currently, the following are not parsed by smoke:

* User messages
* Game Events
* Temp Entities
* Sounds

No major technical limitations, just unfinished work. This should be working
soon.


# License

See LICENSE in the project root. The license for this project is a modified
MIT with an additional clause requiring specifically worded hyperlink
attribution in web properties using smoke.
