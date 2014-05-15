**This document is a work in progress. Please open an issue for any technical
or other errors you find.**


# smoke

Fast, complete Dota 2 "demo" (aka "replay") parser written in cython. Cython
is a Python-like language which is processed into C and then compiled for
execution speed.

You can interact with the smoke library like a normal python library*.

Python 3 support might be possible, if our
[protobuf library](https://github.com/bumptech/palm) is compatible. Figuring
this out is not a priority for us, but feel free to conduct your own
investigation. Happy to accept pull requests.

\* The installation process is a hair more involved.


# Speed

On a fast CPU, smoke parses pro game replays with spectators and commentators
at ~103x game time. A _full_ parse on a 57 minute-long TI game replay takes
~33 seconds.

For a normal "pub" game of 47 minutes, a _full_ parse takes ~19 seconds, or
around ~148x game time.

You can always omit data you don't need for faster parses. Voice data is a
good place to start (see below). The numbers above are upper bounds.

smoke is heavily optimized, but if speed is of utmost concern for you, or if
you prefer Java, check out [clarity](https://github.com/skadistats/clarity).
It is 2-5x faster than smoke.


# Platforms

We've successfully compiled and run smoke on these platforms:

* gcc 4.8.1 (Fedora 19 64-bit, Ubuntu 13.10 32- and 64-bit)
* gcc 4.8.2 (Fedora 20 64-bit)
* clang-500.2.79 (Mac OS X 10.9)

It probably doesn't have any serious portability issues at this point.


# Halp!

Of course. Join us on quakenet IRC in #dota2replay. But do be patient--if we
don't answer immediately, we're probably playing Dota 2.


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

You will also need `python-dev`:

    sudo apt-get install python-dev

You will need the `snappy` development libraries. Mac OS X users can get this
easily with Homebrew or MacPorts. With Homebrew, for example:

    $ brew install snappy
    $ brew install protobuf

@jptaylor helpfully points out that OS X Mavericks users need to set some compiler options via environment variables, like so:

    export CFLAGS=-Qunused-arguments
    export CPPFLAGS=-Qunused-arguments

In Ubuntu, you might install dependencies thusly:

    $ sudo apt-get install libsnappy-dev libprotobuf-dev python-dev

And the python libraries, preferably in your virtualenv:

    $ pip install cython # http://bit.ly/1dd0JRI for problems with virtualenv
    $ pip install palm
    $ pip install python-snappy

Next, you must install `palm` 0.1.9 from source--it's not in PyPI, so you can't
get it with pip:

    $ git clone https://github.com/bumptech/palm.git && cd palm
    $ python setup.py install

Finally, install `smoke` by cloning it:

    $ git clone https://github.com/skadistats/smoke.git && cd smoke
    $ python setup.py install

That's it! You're good to go.


# Hacking

If you want to hack on smoke, you might consider doing this instead of the
second line in the last section above:

    $ python setup.py build_ext --inplace # no system install
    $ export PYTHONPATH=$PWD

If you hack on smoke, you might occasionally get persistent build failures
that have nothing to do with your code (this only applies to --inplace). It's
a bit kludgy, but you can reset the build thusly from within your project dir:

    $ find . -name \*.so -delete
    $ find . -name \*.h -delete
    $ find . -name \*.c -delete
    $ find . -name \*.pyc -delete
    $ rm -rf build

If you have compile or runtime problems _after_ this, it's not Cython.


# Replay Data

smoke parses only the data you're interested in from a replay. Choose from:

* **entities**: in-game things like heroes, players, and creeps
* **modifiers**: auras and effects on in-game entities✝
* **"temp" entities**: fire-and-forget things the game server tells the
client about*
* **user messages**: many different things, including spectator clicks, global
chat messages, overhead events (like last-hit gold, and much more), etc.*✝
* **game events**: lower-level messages like Dota TV control (directed camera
commands, for example), combat log messages, etc.*
* **voice data**: the protobuf-formatted binary data blobs that are somehow
strung into voice--only really relevant to commentated pro matches*✝
* **sounds**: sounds that occur in the game*✝
* **overview**: end-of-game summary, including players, game winner, match id,
duration, and often picks/bans

\* **transient**: new dataset (i.e. list, dict) for each tick of the parse

✝ **unprocessed**: data is provided as original protobuf message object


# Parsing Replay Data

By default, smoke parses everything. This is the slowest parsing option. Here
is a simple example which parses a demo, doing nothing:

    # entity_counter.py
    import io

    from smoke.io.wrap import demo as io_wrp_dm
    from smoke.replay import demo as rply_dm

    with io.open('37633163.dem', 'rb') as infile:
        # wrap a file IO as a "demo"
        demo_io = io_wrp_dm.Wrap(infile)

        # read the header that occurs at demo start
        demo_io.bootstrap() 

        # create a demo with our IO object
        demo = rply_dm.Demo(demo_io)

        # read essential pre-match data from the demo
        demo.bootstrap() 

        # this is the core loop for iterating over a game
        for match in demo.play():
            # this is where you will do things! see smoke.replay.match
            count = len(match.entities)

        # parses game overview found at the end of the demo file
        demo.finish()

When run with `time python entity_counter.py`, we get:

    real    0m32.689s
    user    0m32.411s
    sys     0m0.242s

Perhaps you want to be more selective about parsing. We do this by bitmask.
Here's code similar to the above, but more restrictive about what it parses.
Consequently, it'll be tons faster:

    # with_less_data.py
    import io

    from smoke.io.wrap import demo as io_wrp_dm
    from smoke.replay import demo as rply_dm
    from smoke.replay.const import Data

    with io.open('37633163.dem', 'rb') as infile:
        demo_io = io_wrp_dm.Wrap(infile)
        demo_io.bootstrap() 

        # it's a bitmask -- see smoke.replay.demo for all options
        parse = Data.All ^ (Data.UserMessages | Data.GameEvents | Data.VoiceData | Data.TempEntities)
        demo = rply_dm.Demo(demo_io, parse=parse)
        demo.bootstrap() 

        for match in demo.play():
            count = len(match.entities)

        # parses game overview found at the end of the demo file
        demo.finish()

When run with `time python with_less_data.py`:

    real    0m20.116s
    user    0m19.904s
    sys     0m0.196s

Finally, if we just want an overview of the game:

    # overview_only.py
    import io

    from smoke.io.wrap import demo as io_wrp_dm
    from smoke.replay import demo as rply_dm
    from smoke.replay.demo import Data

    with io.open('37633163.dem', 'rb') as infile:
        demo_io = io_wrp_dm.Wrap(infile)
        overview_offset = demo_io.bootstrap() # returns offset to overview

        # we can seek on the raw underlying IO instead of parsing everything
        infile.seek(overview_offset)

        demo = rply_dm.Demo(demo_io)
        demo.finish()

        print demo.match.overview

When run with `time python overview_only.py':

    real    0m0.189s
    user    0m0.124s
    sys     0m0.034s

If you **only** need `UserMessages` or `GameEvents` (for example), you end up
with 5 second parses. So parse as little as you can!

Take a look at `smoke.replay.match` to see which properties you can access
while `play`ing a demo.


# License

See LICENSE in the project root. The license for this project is a modified
MIT with an additional clause requiring specifically worded hyperlink
attribution in web properties using smoke.
