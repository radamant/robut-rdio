
#
# NoAction is a fallback action for the Actions object to allow for the
# code to perfom some action even if a registered action could not be found
# 
# @see Actions#action_for
# 
module NoAction
  extend self
  
  def handle(time,sender,message)
    puts %{
      I have no action for the message: #{message}
    }
  end
  
end