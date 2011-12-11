require_relative 'no_action'
require_relative 'reply_action'

#
# Actions maintains a list of actions that are accessed through #action_for
# method with a specified message. Actions will always return an object that
# responds with the #handle method even if that is a NoAction.
# 
class Robut::Plugin::Rdio
  
  class Actions
  
    #
    # Initialize with a list of actions. An action should repond to two
    # methods #match? and #handle to ensure that no error occurs while
    # processing the actions
    # 
    # The first action to match will be returned so create them in the
    # orer which they should be handled.
    # 
    # @param [*Actions] actions a flexible list of Action objects
    #
    def initialize(*actions)
      @actions = actions.flatten.compact
    end
  
    #
    # @param [String] message to be compared to each action to see if
    #   that action should handle the message
    #
    def action_for(message)
      Array(@actions).find {|action| action.match?(message) } || NoAction
    end
  
    def examples
      Array(@actions).map {|action| action.examples }.flatten
    end
  
  end
end