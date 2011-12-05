require_relative 'reply_action'
require_relative 'find_action'

class FindAndPlayAction
  include ReplyAction
  
  def initialize(reply,rdio,queue_action)
    @reply = reply
    @rdio = rdio
    @queue_action = queue_action
    @find_action = FindAction.new @reply, @rdio
  end
  
  def examples
    "play <name of artist,name of album,name of track>"
  end
  
  def match?(request)
    request =~ /^play\b[^\b]+/
  end
  
  def handle(sender,nick,message)
    
    search_results = @find_action.handle(sender,nick,message)

    queue(search_results.first) if search_results
    
  end
  
  def queue(request)
    @queue_action.enqueue request
  end
  
end