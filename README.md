# robut-rdio

Robut-rdio gives the ability for individuals within a [Hipchat](http://www.hipchat.com) chat room to enqueue, play, and manage songs through a web-based [rdio](http://www.rdio.com/) page. Robut-rdio is a plugin for [robut](https://github.com/justinweiss/robut).

## Usage 

### Controls

* `find <ARTIST, ALBUM, TRACK>` - searches for the given term and returns a result set
* `play <INDEX>` - play the track with the given index in the result set
* `pause` - pause the current playing song
* `unpause` or `play` - will resume playing the current track
* `next` will move to the next avaiable track
* `back` will move to the previous track
* `restart` will restart the current track over at the beginning
* `clear` will remove all the currently enqueued songs

#### `find` and `play`

As a user within a Hipchat channel, you will likely spend your time searching for and queuing music.

```
@dj find <ARTIST, ALBUM, TRACK>
```

A list of matching results will be returned and presented in the chat room.

```
<Index>: <Artist> - <Album> - <Track>
```

* You can enqueue one of the results by simply referencing the index number.
* If there is no <Track> specified, the result will enqueue the entire <Album> for the specified <Artist>
* Any user can make a selection from the results that are returned.
* Making new requests of robut will replace any previously specified indexes.

##### Example

```
user > @dj find Beck - Guero

dj   > Searching for: guero...
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

user > @dj play 0
```

### Web 

Along with the bot within the hipchat channel to provide you with feedback information, the webpage playing the music also provides information about the state of the current track and playlist. Most of the images used are standard images to represent: play; paused; and stopped. There are two other states that are important to note:

![Buffering](https://github.com/radamant/robut-rdio/raw/event-reporting/lib/server/public/images/buffering.png) This appears when a track is first loaded and the audio data is being loaded for playback.

![Disconnected](https://github.com/radamant/robut-rdio/raw/event-reporting/lib/server/public/images/disconnected.png) This appears when the current Rdio account is being used in another location. This will prevent all playback.


### Web Controls

The webpage itself allows for keyboard input. This allows for the system running the webpage to expose the ability to control the music similar to individuals within the chatroom. This has been tested with [Remote Buddy](http://www.iospirit.com/products/remotebuddy/) with custom keys mapped to the remote's buttons.

* `space` to toggle playing and pausing the current playing track
* `<-` or `p` to restart the current track or twice to move to the previous track
* `->` or `n` to move to the next track

## Installation

### Requirements

* [Robut](https://github.com/justinweiss/robut)
* [Rdio API](http://developer.rdio.com/) (Key & Secret)

### Robut Chatfile

```ruby
# Require the plugin into your chat file
require 'robut-rdio'

# Specify your RDIO_KEY and RDIO_SECRET
Robut::Plugin::Rdio.key = "RDIO_KEY"
Robut::Plugin::Rdio.secret = "RDIO_SECRET"

# Start the Sinatra Server required to stream the music from Rdio
Robut::Plugin::Rdio.start_server

# Add the plugin to the list of available plugins
Robut::Plugin.plugins << Robut::Plugin::Rdio

# ... other robut configuration information ...
```


## Development

### Robut-Rdio without Hipchat

Robut-Rdio comes with an interactive shell mode that makes it wasy to interact with the Rdio service. This functionaliy allows you to interact with the plugin without the requirement of Hipchat.

### Start the interactive shell

* Clone the repository

* Execute the following command:

```shell
export RDIO_KEY=<your key>
export RDIO_SECRET=<your secret>
rake shell
```

* Visit the server and port specified in start up:

```shell
== Sinatra/1.3.1 has taken the stage on 4567 for development with backup from Thin
>> Thin web server (v1.2.11 codename Bat-Shit Crazy)
>> Maximum connections set to 1024
>> Listening on 0.0.0.0:4567, CTRL+C to stop
Welcome to the robut plugin test environment.
```

By default the server will start at [localhost:4567](http://localhost:4567). It is important that the page is open to allow requests that are made to be added to the queue maintained by the Rdio object within the page.

* Make requests to the DJ within the interactive shell:

You can make any requests that you would normally make within a Hipchat channel. The bot will read and respond to requests prefaced with the username `@dj`.

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

