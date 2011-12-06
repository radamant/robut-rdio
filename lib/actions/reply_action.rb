#
# This method simply allows the Action that includes it to call #reply
# and not reply.call on the lambda object that they are given when they
# are created.
# 
module Robut::Plugin::Rdio::ReplyAction
  
  def reply(message)
    @reply.call message
  end
  
end