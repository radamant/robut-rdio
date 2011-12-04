class ShowQueueAction
  
  def initialize(reply,queue)
    @reply = reply
    @queue = queue
  end
  
  def match?(request)
    Array(request).join(' ') =~ /^show queue$/
  end
  
  def example
    "show queue - returns the current songs queued to be played"
  end

  def handle(time,sender,message)
    
    if Array(@queue).empty?
      
      reply "@#{sender.split(' ').first} there are currently no songs in the queue"
      
    else
      
      formatted_queue_data = Array(@queue).map do |song|
        "#{song["artist"]} - #{song["album"]} - #{song["track"]}"
      end.join("\n")
      
      reply "@#{sender.split(' ').first} the queue is currently:\n#{formatted_queue_data}"
      
    end
      
  end
  
  def reply(message)
    @reply.call message
  end
end