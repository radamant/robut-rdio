require_relative 'find_action'
require_relative 'reply_action'
#
# FindAndPlayAction will perform a search and an immediate queuing of the first
# item in the search results without the review from the user. This action will 
# not override the existing search results that a user has currently in the system.
# 
class Robut::Plugin::Rdio::FindAndPlayAction
  include Robut::Plugin::Rdio::ReplyAction
  
  ACTION_REGEX = /^play\b([^\b]+)$/
  
  #
  # FindAndPlay requires the ability to output information, Rdio to perform 
  # searching and queueing to place that item within the queue.
  # 
  # @param [Proce] reply the ability to reply through the client
  # @param [Rdio] rdio the initialized Rdio server instance
  # @param [Queue] queue the ability to enqueue an item is 
  #
  def initialize(reply,rdio,queue)
    @reply = reply
    @rdio = rdio
    @queue = queue
    @find_action = Robut::Plugin::Rdio::FindAction.new @reply, @rdio
  end
  
  def examples
    "play <name of artist,name of album,name of track>"
  end
  
  def match?(request)
    request =~ ACTION_REGEX
  end
  
  
  def handle(sender,nick,message)
    
    # Search for the results wth the FindAction and then afterward with those
    # results immediately enqueue the first item if results were returned.
    
    search_results = @find_action.handle(sender,nick,message[ACTION_REGEX,-1])
    
    if search_results
      queue(search_results.first)
      reply "/me queued '#{RdioResultsFormatter.format_result(search_results.first)}'"
    end
    
  end
  
  def queue(request)
    @queue.enqueue request
  end
  
end