robut-rdio
====================

A web-powered RDIO plugin for robut

How to test Robut-Rdio interactively
------------------

You can test the plugin in an interative shell with:

```shell
export RDIO_KEY=<your key>
export RDIO_SECRET=<your secret>
rake shell
```

This will open a pseudo-robut environment where anything entered into the shell will be responded to as if it were a hipchat message.

You shoule see something like:

```shell
== Sinatra/1.3.1 has taken the stage on 4567 for development with backup from Thin
>> Thin web server (v1.2.11 codename Bat-Shit Crazy)
>> Maximum connections set to 1024
>> Listening on 0.0.0.0:4567, CTRL+C to stop
Welcome to the robut plugin test environment.

You can direct your messages to the bot using:
@dj

Type 'exit' or 'quit' to exit this session

hipchat> 

```

You can now point a web browser to the url that Rack gives you to run the client as well while you test the chat input.


Then you can do the following while your web browser responds to the changes:

```shell
hipchat> @dj find guero
Searching for: guero...
0: Beck - Guero
1: Beck - Guero - E-Pro
2: Beck - Guero - Girl
3: Beck - Guero - Que' Onda Guero
4: Beck - Guero - Black Tambourine
5: Beck - Guero - Missing
6: Beck - Guero - Hell Yes
7: Beck - Guero - Earthquake Weather
8: Beck - Guero - Go It Alone
9: Beck - Guero - Broken Drum
hipchat> @dj play 6
Queuing: Beck - Hell Yes
hipchat>     
```

Now, the browser should have a song queued up and playing.


Contributing to robut-rdio
----------------
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
----------

Copyright (c) 2011 Adam Pearson. See LICENSE.txt for
further details.

