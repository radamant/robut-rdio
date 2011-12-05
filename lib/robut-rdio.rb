require 'robut'
require_relative 'server/server'
require 'rdio'

require_relative 'queue'
require_relative 'search_result'
require_relative 'query_parser'
require_relative 'actions/actions'

require_relative 'actions/find_and_show_results_action'
require_relative 'actions/find_and_play_action'
require_relative 'actions/play_results_action'
require_relative 'actions/find_more_and_show_more_results_action'
require_relative 'actions/show_results_action'
require_relative 'actions/show_queue_action'
require_relative 'actions/control_action'


# A plugin that hooks into Rdio, allowing you to queue songs from
# HipChat. +key+ and +secret+ must be set before we can deal with any
# Rdio commands. Additionally, you must call +start_server+ in your
# Chatfile to start the Rdio web server.
class Robut::Plugin::Rdio
  include Robut::Plugin

  class << self
    # Your Rdio API Key
    attr_accessor :key

    # Your Rdio API app secret
    attr_accessor :secret

    # The port the Rdio web player will run on. Defaults to 4567.
    attr_accessor :port

    # The host the Rdio web player will run on. Defaults to localhost.
    attr_accessor :host

    # The playback token for +domain+. If you're accessing Rdio on
    # localhost, you shouldn't need to change this. Otherwise,
    # download the rdio-python plugin:
    #
    #   https://github.com/rdio/rdio-python
    #
    # and generate a new token for your domain:
    #
    #   ./rdio-call --consumer-key=YOUR_CONSUMER_KEY --consumer-secret=YOUR_CONSUMER_SECRET getPlaybackToken domain=YOUR_DOMAIN
    attr_accessor :token

    # The domain associated with +token+. Defaults to localhost.
    attr_accessor :domain
  end

  # Starts a Robut::Plugin::Rdio::Server server for communicating with
  # the actual Rdio web player. You must call this in the Chatfile if
  # you plan on using this gem.
  def self.start_server
    @server = Thread.new { Server.run! :host => (host || "localhost"), :port => (port || 4567) }
    Server.token = self.token || "GAlNi78J_____zlyYWs5ZG02N2pkaHlhcWsyOWJtYjkyN2xvY2FsaG9zdEbwl7EHvbylWSWFWYMZwfc="
    Server.domain = self.domain || "localhost"
  end
  
  #
  # Because an instance of this plugin is not created until the Robut client has
  # recieved at least one message. The server callbacks need to be created during
  # the #handle request. This allows for the server to communicate back through
  # the Robut communication channel that it receives the messages.
  # 
  def establish_server_callbacks!
    Server.reply_callback ||= lambda{|message| reply(message, :room)}
    Server.state_callback ||= lambda{|message| reply("/me #{message}", :room)}
    Server.update_queue ||= lambda{|queue| save_song_queue queue }
    
  end
  
  def actions
    unless defined? @@actions
      reply_lambda = lambda{|message| reply(message, :room)}
      server_command_lambda = lambda{|command| send_server_command command }
      
      @@actions = Actions.new PlayResultsAction.new(reply_lambda, song_queue, results),
        FindAndPlayAction.new(reply_lambda, rdio, song_queue),
        FindAndShowResultsAction.new(reply_lambda, rdio, results),
        FindMoreAndShowResultsAction.new(reply_lambda, rdio, results),
        ShowResultsAction.new(reply_lambda, results),
        ShowQueueAction.new(reply_lambda, song_queue),
        ControlAction.new(server_command_lambda)
    end
    
    @@actions
  end

  # Returns a description of how to use this plugin
  def usage
    # TODO: composed of all the action's examples
  end

  def show_more_regex
    /^show(?: me)? ?(\d+)? ?more(?: results)?$/
  end
  
  #
  # @param [String,Array] request that is being evaluated as a show more results
  #   request.
  # @return [Boolean]
  #
  def show_more?(request)
    Array(request).join(' ') =~ show_more_regex
  end
  
  
  #
  # This method is called by Robut when a new message has been added to the 
  # chatroom.
  # 
  # @param [Time] time that the message arrived
  # @param [String] sender_nick is the user that sent the message
  # @param [String] message that the user has sent
  #
  def handle(time, sender_nick, message)
    
    establish_server_callbacks!
    
    words = words(message)
    
    # if sent_to_me?(message)
      
      meaningful_message = words.join(' ')
      actions.action_for(meaningful_message).handle(time,sender_nick,meaningful_message)
      
    # end
    
  rescue => exception
    reply "#{exception} #{exception.backtrace}"
  end

  #
  # As the plugin is initialized each time a request is made, the plugin maintains
  # the state of the results from the last search request to ensure that it will
  # be available when someone makes another request.
  # 
  def results
    @@results = {} unless defined? @@results
    @@results
  end
  
  #
  # Store the current results for the user and set them as the last resultset
  # so that users with expired results or no results with use someone else's
  # results.
  # 
  def save_results(search_results)
    @@results = {} unless defined? @@results
    
    @@results[search_results.owner] = search_results
    @@results["LAST_RESULSET"] = search_results
  end
  
  def song_queue
    unless defined? @@queue
      enqueue_lambda = lambda{|track_key| send_server_enqueue(track_key) }
      @@queue = Queue.new enqueue_lambda
    end
    @@queue
  end
  
  def save_song_queue(queue)
    unless defined? @@queue
      enqueue_lambda = lambda{|track_key| send_server_enqueue(track_key) }
      @@queue = Queue.new enqueue_lambda
    end
    @@queue.update queue
  end
  
  def rdio
    @@rdio = ::Rdio.init(self.class.key, self.class.secret) unless defined? @@rdio
    @@rdio
  end
  
  
  private
  
  def send_server_enqueue(track_key)
    Server.queue << track_key
  end

  def send_server_command(command)
    Server.command << command
  end

end
