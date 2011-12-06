require_relative 'reply_action'
require_relative 'find_action'
require_relative 'show_results_action'

#
# FindMoreAndShowResultsAction will take an existing result set for the user
# and continue to expand it so that it contains more data. This is useful if
# the first 10 results do not contain all the tracks that the user wanted to
# see.
# 
class Robut::Plugin::Rdio::FindMoreAndShowResultsAction
  include Robut::Plugin::Rdio::ReplyAction
  
  SHOW_MORE_RESULTS = /^show(?: me)? ?(\d+)? ?more(?: results)?$/
  
  #
  # FindAndPlay requires the ability to output information, Rdio to perform 
  # searching and results to store the results from the search.
  #
  # @param [Proce] reply the ability to reply through the client
  # @param [Rdio] rdio the initialized Rdio server instance
  # @param [Results] search_results object to store the search results
  #
  def initialize(reply,rdio,search_results)
    @reply = reply
    @find_action = FindAction.new reply, rdio
    @show_results_action = ShowResultsAction.new reply, search_results
    @search_results = search_results
  end

  def examples
    "show 10 more results"
  end

  def match?(request)
    request =~ SHOW_MORE_RESULTS
  end

  
  def handle(time,sender,message)
    
    # Find the current results for the user that are not tool old to be used.
    # 
    # @note that a user may not get the behavior she wants in this situation
    #  as they would be adding results onto someone else's result set and 
    #  that would change to whatever is the latest. The best solution would
    #  to allow for the resultset to have mutiple owners and in the case
    #  that a user added on more results they would be immediately adopt
    #  this result set as their own.
    
    current_results = results_for(sender,time)
    
    if current_results
      
      more_count = message[SHOW_MORE_RESULTS,-1]
      starting_index = current_results.length

      reply "/me is searching for #{more_count} more for the query '#{current_results.query}'"

      # SearchResults ask for more results and immediately append the results
      # to the existing SearchResult structure. It returns the newly found results.
      
      more_results = current_results.more!(more_count)

      formatted_results = @show_results_action.format_results_for_queueing(more_results,starting_index)

      reply "@#{sender.split(' ').first} I found the following:\n#{formatted_results}"
    
    else
      
      reply "Unable to find any more results as there are currently no results to base it on!"
      return
      
    end
    
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
