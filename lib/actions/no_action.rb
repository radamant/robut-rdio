module NoAction
  extend self
  
  def handle(time,sender,message)
    puts %{
      I have no action for the message: #{message}
    }
  end
  
end