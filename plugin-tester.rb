#!/usr/bin/env ruby
require 'robut'
require_relative 'lib/robut-rdio'
require 'highline/import'

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
