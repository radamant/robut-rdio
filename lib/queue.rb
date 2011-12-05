class Robut::Plugin::Rdio::Queue
  include Enumerable
  
  def initialize queue_to_server
    @queue_to_server = queue_to_server
    @current_queue = []
  end
  
  def enqueue(results)

    Array(results).each do |result| 
      @queue_to_server.call(result.key)
    end
    results
  end
  
  def update(with_new_queue)
    @current_queue = with_new_queue
  end

  def each
    @current_queue.each {|item| yield item if block_given? }
  end
  
  def [](value)
    @current_queue[value]
  end
  
end