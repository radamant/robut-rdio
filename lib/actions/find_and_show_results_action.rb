require_relative 'reply_action'
require_relative 'find_action'
require_relative 'show_results_action'

require_relative '../query_parser'
require_relative '../search_result'

class FindAndShowResultsAction
  include ReplyAction
  
  #
  # @see http://rubular.com/?regex=(find%7Cdo%20you%20have(%5Csany)%3F)%5Cs%3F(.%2B%5B%5E%3F%5D)%5C%3F%3F
  # 
  SEARCH_REGEX = /(find|do you have(\sany)?)\s?(.+[^?])\??/

  
  def initialize(reply,rdio,results)
    
    @find_action = FindAction.new reply, rdio
    @show_results_action = ShowResultsAction.new reply, results
    @results = results
    
  end

  def examples
    [ "play <song> - queues <song> for playing",
      "play album <album> - queues <album> for playing",
      "play artist <artist> - queues <artist> for playing",
      "play track <track> - queues <track> for playing" ]
  end

  def match?(request)
    request =~ SEARCH_REGEX
  end


  def handle(time,sender,message)
    
    search_results = @find_action.handle(time,sender,message[SEARCH_REGEX,-1])
    
    save_results search_results
    
    @show_results_action.handle(time,sender,message)
    
  end
  
  def save_results(search_results)
    @results[search_results.owner] = search_results
    @results["LAST_RESULSET"] = search_results
  end

end
