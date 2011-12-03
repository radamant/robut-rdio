require 'robut'
require_relative 'server/server'
require 'rdio'

require_relative 'search_result'
require_relative 'query_parser'

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
  end

  # Returns a description of how to use this plugin
  def usage
    [
      "#{at_nick} play <song> - queues <song> for playing",
      "#{at_nick} play album <album> - queues <album> for playing",
      "#{at_nick} play artist <artist> - queues <artist> for playing",
      "#{at_nick} play track <track> - queues <track> for playing",
      "#{at_nick} play/unpause - unpauses the track that is currently playing",
      "#{at_nick} next - move to the next track",
      "#{at_nick} next|skip album - skip all tracks in the current album group",
      "#{at_nick} restart - restart the current track"
    ]
  end
 
  
  #
  # @param [String,Array] request that is being evaluated as a play request
  # @return [Boolean]
  #
  def play_results_regex
    /^(?:play)?\s?(?:result)?\s?((?:\d[\s,-]*)+|all)$/
  end
  
  #
  # @param [String,Array] request that is being evaluated as a play request
  # @return [Boolean]
  #
  def play?(request)
    Array(request).join(' ') =~ play_results_regex
  end

  #
  # @param [Array,String] track_request the play request that is going to be 
  #   parsed for available tracks.
  # 
  # @return [Array] track numbers that were identified.
  # 
  # @example Requesting multiple tracks
  # 
  #     "play 1"
  #     "play 1 2"
  #     "play 1,2"
  #     "play 1-3"
  #     "play 1, 2 4-6"
  #     "play all"
  #
  def parse_tracks_to_play(track_request)
    if Array(track_request).join(' ') =~ /play all/
      [ 'all' ]
    else
      Array(track_request).join(' ')[play_results_regex,-1].to_s.split(/(?:\s|,\s?)/).map do |track| 
        tracks = track.split("-")
        (tracks.first.to_i..tracks.last.to_i).to_a
      end.flatten
    end
  end

  #
  # @return [Regex] that is used to match searches for their parameters
  # @see http://rubular.com/?regex=(find%7Cdo%20you%20have(%5Csany)%3F)%5Cs%3F(.%2B%5B%5E%3F%5D)%5C%3F%3F
  # 
  def search_regex
    /(find|do you have(\sany)?)\s?(.+[^?])\??/
  end
  
  #
  # @param [String,Array] request that is being evaluated as a search request
  # @return [Boolean]
  #
  def search?(request)
    Array(request).join(' ') =~ search_regex
  end

  #
  # @param [String,Array] request that is being evaluated as a search and playback 
  #   request
  # @return [Boolean]
  #
  def search_and_play?(request)
    Array(request).join(' ') =~ /^play\b[^\b]+/
  end

  #
  # @param [String,Array] request that is being evaluated as a command request
  # @return [Boolean]
  #
  def command?(request)
    Array(request).join(' ') =~ /^(?:play|(?:un)?pause|next|restart|back|clear)$/
  end

  #
  # @param [String,Array] request that is being evaluated as a skip album request
  # @return [Boolean]
  #
  def skip_album?(message)
    message =~ /(next|skip) album/
  end
  
  def sender_nick
    @sender_nick
  end
  
  def sender_nick_short
    @sender_nick.split(' ').first
  end
  
  def message
    @message
  end
  
  def time
    @time
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
    @time = time
    @sender_nick = sender_nick
    @message = message
    
    establish_server_callbacks!
    
    words = words(message)
    
    if sent_to_me?(message)

      if play?(words)

        play_result *parse_tracks_to_play(words)
        
      elsif search_and_play?(words)
        
        search_and_play_criteria = words[1..-1].join(" ")
        
        unless search_and_play_result search_and_play_criteria
          reply "I couldn't find '#{search_and_play_criteria}' on Rdio."
        end
        
      elsif search?(words)
        
        find words.join(' ')[search_regex,-1]
        save_results
        reply_with_results_for_queueing
        
      
      elsif skip_album?(message)

        send_server_command("next_album")

      else command?(words)
        
        send_server_command(words.join("_"))
        
      end
      
    end
    
  rescue => exception
    reply "#{exception} #{exception.backtrace}"
  end

  #
  # As the plugin is initialized each time a request is made, the plugin maintains
  # the state of the results from the last search request to ensure that it will
  # be available when someone makes another request.
  # 
  # @return [SearchResult] the results for the current sender if present and not
  #   too old; defaults to the last result set for any user.
  # 
  def results
    @@results = {} unless defined? @@results
    
    results_for_sender = @@results[sender_nick]
    
    if results_for_sender and results_for_sender.are_not_old?(time)
      results_for_sender
    else
      @@results["LAST_RESULSET"]
    end
    
  end
  
  private

  def send_server_command(command)
    Server.command << command
  end

  #
  # @param [String] query the search criteria to use to find and then queue
  #   up.
  # 
  def find(query_string)
    query = QueryParser.parse query_string
    query_type = query.type || default_type_of_query

    reply "/me is searching for #{query.type.to_s[0] == 'a' ? 'an' : 'a'} #{query_type} with '#{query.terms}'..."
    @search_results = search(query_string)
  end
  
  def reply_with_results_for_queueing
    reply "@#{sender_nick_short} I found the following:\n#{format_results_for_queueing(@search_results.results)}"
  end
  
  #
  # Store the current results for the user and set them as the last resultset
  # so that users with expired results or no results with use someone else's
  # results.
  # 
  def save_results
    @@results = {} unless defined? @@results
    
    @@results[@search_results.owner] = @search_results
    @@results["LAST_RESULSET"] = @search_results
  end

  def play_result(*requests)
    
    unless results
      reply("I don't have any search results") and return
    end
    
    requests = requests.flatten.compact
    
    # Queue all the songs when the request is 'all'
    
    if requests.first == "all"
      queue(results.results) and return
    end
    
    queue requests.flatten.map {|request| results[request] }.flatten
    
  end
  
  #
  # @param [String] message the search criteria to use to find and then queue
  #   up.
  #
  def search_and_play_result(query)
    
    search_results = search(query)
    
    if search_results and search_results.results
      queue(search_results.results.first)
      true
    end
    
  end

  #
  # Enqueues the tracks specified and replies to the chatroom with the songs 
  # that have been enqueued.
  # 
  # @param [Result,Results] results is a result or results that you want to 
  #   enqueue.
  #
  def queue(results)
    
    # Queue the songs, while collecting, human-readable forms of the queued songs
    
    queued_songs = Array(results).map do |result|
      Server.queue << result.key
      format_result(result)
    end
    
    # If the user has requested 2 songs then show those songs, 
    # otherwise show the first song and the number of songs that were queued
    
    if queued_songs.length < 3
      queued_songs.each {|song| reply "/me queued '#{song}'" }
    else
      reply "/me queued '#{queued_songs.first}' and #{queued_songs.length - 1} other songs"
    end
    
  end
  
  #
  # Formats the results for the purposes of displaying back to the user in an
  # ordered list with prefix index to allow the user an easy way to later enqueue
  # the tracks for playing.
  # 
  # @param [Result,Results] results a result or results that you want to display
  #   with prefixed indexes.
  #
  def format_results_for_queueing(results)
    Array(results).each_with_index.map do |result, index|
      "#{index} #{format_result(result)}"
    end.join("\n")
  end

  #
  # @param [Result] search_result an Rdio object that will be displayed
  #
  def format_result(search_result)
    
    unless defined? @@result_displayer and @@result_displayer
      
      @@result_displayer = {
        ::Rdio::Album => lambda{|album| "#{album.artist.name} - #{album.name}"},
        ::Rdio::Track => lambda{|track| "#{track.artist.name} - #{track.album.name} - #{track.name}"},
        ::Rdio::Artist => lambda{|artist| "#{artist.name} - #{artist.tracks.sample.name}"}
      }
      
      fallback_display = lambda{|object| object.to_s }
      @@result_displayer.default fallback_display
    
    end
    
    @@result_displayer[search_result.class].call(search_result)
  end
  
  #
  # @param [String] query to search through the services to find the results
  # @return [SearchResult] that is associated with the current user and contains
  #   the set of results for the users's query.
  # 
  def search(query_string)
    
    # As this is only an rdio-pluin we will simply search Rdio and return the
    # results from that search operation.
    
    query = QueryParser.parse query_string
    query_type = query.type || default_type_of_query
    
    results = search_rdio query.terms, query_type.to_s.capitalize
    
    SearchResult.new sender_nick, results
  end
  
  #
  # When a query does not contain a type of query it will default to this value
  # for the user.
  # 
  def default_type_of_query
    store["#{self.class.name}::query::type::#{sender_nick}"] || :track
  end
    
  # Searches Rdio for sources matching +words+. 
  # 
  # Given an array of Strings, which are the search terms, use Rdio to find any
  # tracks that match. If the first word happens be `album` then search for
  # albums that match the criteria.
  #
  #
  # @param [String] query the query string
  # @param [String] filters the areas to filter the data (i.e. Artist, Track, Album)
  #
  def search_rdio(query,filters)
    api = ::Rdio.init(self.class.key, self.class.secret)
    api.search(query,filters)
  end

end
