require_relative 'no_action'

class Actions
  
  def initialize(*actions)
    @actions = actions.flatten.compact
  end
  
  def action_for(message)
    @actions.find {|action| action.match?(message) } || NoAction
  end
  
end