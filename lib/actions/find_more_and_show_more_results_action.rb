require_relative 'reply_action'
require_relative 'find_action'
require_relative 'show_results_action'

require_relative '../query_parser'
require_relative '../search_result'

class FindMoreAndShowResultsAction
  include ReplyAction
  
  def initialize(reply,rdio,search_results)
    
    @reply = reply
    @find_action = FindAction.new reply, rdio
    @show_results_action = ShowResultsAction.new reply, search_results
    @search_results = search_results
    
  end

  def examples
    "show 10 more results"
  end

  SHOW_MORE_RESULTS = /^show(?: me)? ?(\d+)? ?more(?: results)?$/

  def match?(request)
    request =~ SHOW_MORE_RESULTS
  end


  def handle(time,sender,message)
    
    more_count = message[SHOW_MORE_RESULTS,-1]
    
    current_results = results_for(sender,time)
    starting_index = current_results.length
    
    # TODO: create message for when loading more results
    
    more_results = current_results.more!(more_count)
    
    formatted_results = @show_results_action.format_results_for_queueing(more_results,starting_index)
    
    reply "@#{sender.split(' ').first} I found the following:\n#{formatted_results}"
    
  end
  
  #
  # @param [String] sender the result set for the specified sender.
  # @param [Time] time the time of this request to use to find out if the 
  #   results are too old to be used.
  # 
  # @return [SearchResult] the results for the sender if present and not
  #   too old; defaults to the last result set for any user.
  
  def results_for(sender,time)
    results_for_sender = @search_results[sender]
    
    if results_for_sender and results_for_sender.are_not_old?(time)
      results_for_sender
    else
      @search_results["LAST_RESULSET"]
    end
  end
  
end
