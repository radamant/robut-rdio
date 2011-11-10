#!/usr/bin/env ruby
require 'robut'
require_relative 'lib/robut-rdio'
require 'highline/import'


Robut::Plugin::Rdio.key = ENV['RDIO_KEY']
Robut::Plugin::Rdio.secret = ENV['RDIO_SECRET']
puts "Starting sinatra..."
Robut::Plugin::Rdio.start_server 

@plugin = Robut::Plugin::Rdio.new(nil)


def @plugin.nick
  return 'dj'
end

def @plugin.reply(msg)
  puts msg
end

def fade_out
    puts
    puts 'Exiting fake hipchat client...'
    puts
    exit
end

sleep(0.5)
puts <<-EOMSG
Welcome to the robut plugin test environment.

You can direct your messages to the bot using:
@#{@plugin.nick}

Type 'exit' or 'quit' to exit this session

EOMSG
while(true) do
  begin
    msg = ask('hipchat> ')

    @plugin.handle(Time.now, 'Bob', msg)

    if msg =~ /quit|exit/
      fade_out
    end
  rescue Interrupt
    fade_out
  end
end
