require_relative 'reply_action'

#
# ShowQueueAction will respond with the state of the song queue. As the main
# application will likely maintain the queue object (for the moment) this 
# action will give insights into the state of the queue for users to allow
# them to see music within the queue without having to visit the local website
# 
class Robut::Plugin::Rdio::ShowQueueAction
  include Robut::Plugin::Rdio::ReplyAction
  
  #
  # @param [Lambda] reply the lambda that can be called with a message
  # @param [Enumerable] queue object that is a reference to the queue
  # 
  # @note when assigning the queue object here, ensure the other instance
  #  is not replaced and is instead maintained and updated or the connection
  #  with the queue will be lost.
  #
  def initialize(reply,queue)
    @reply = reply
    @queue = queue
  end
  
  def match?(request)
    Array(request).join(' ') =~ /^show queue$/
  end
  
  def examples
    "show queue - returns the current songs queued to be played"
  end

  def handle(time,sender,message)

    #
    # When the queue is empty we will tell the user that it is empty
    # 
    # When the queue has tracks we will tell the user the tracks in the queue
    # 
    
    if Array(@queue).empty?
      
      reply "@#{sender.split(' ').first} there are currently no songs in the queue"
      
    else
      
      #
      # @note tracks stored in the queue are considered to be a Hash
      #  with three keys: artist; album; track.
      
      formatted_queue_data = Array(@queue).map do |song|
        "#{song["artist"]} - #{song["album"]} - #{song["track"]}"
      end.join("\n")
      
      reply "@#{sender.split(' ').first} the queue is currently:\n#{formatted_queue_data}"
      
    end
      
  end
  
end