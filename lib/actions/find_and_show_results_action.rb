require_relative 'reply_action'
require_relative 'find_action'
require_relative 'show_results_action'

#
# FindAndShowResultsAction will search for the matching music with the query
# string, save the results, and then present the results to the user to allow
# them the ability to make a deicision about the results instead of playing
# the first specified song.
# 
class Robut::Plugin::Rdio::FindAndShowResultsAction
  include Robut::Plugin::Rdio::ReplyAction
  
  #
  # @see http://rubular.com/?regex=(find%7Cdo%20you%20have(%5Csany)%3F)%5Cs%3F(.%2B%5B%5E%3F%5D)%5C%3F%3F
  # 
  SEARCH_REGEX = /(find|do you have(\sany)?)\s?(.+[^?])\??/

  #
  # FindAndPlay requires the ability to output information, Rdio to perform 
  # searching and results to store the results from the search.
  #
  # @param [Proce] reply the ability to reply through the client
  # @param [Rdio] rdio the initialized Rdio server instance
  # @param [Results] results object to store the search results
  #
  def initialize(reply,rdio,results)
    @find_action = Robut::Plugin::Rdio::FindAction.new reply, rdio
    @show_results_action = Robut::Plugin::Rdio::ShowResultsAction.new reply, results
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
    
    # Search based on the user's query, save the results, and then show them to 
    # the user.
    
    search_results = @find_action.handle(time,sender,message[SEARCH_REGEX,-1])
    
    save_results search_results
    
    @show_results_action.handle(time,sender,message)
    
  end
  
  #
  # Results are saved for both the owner of the search results and as the last
  # saved search results.
  # 
  # @todo this Results needs to change as a structure to something that will
  #   handle this logic.
  # 
  # @param [SearchResults] search_results are saved as the latest request that
  #   is made and by owner of the search.
  #
  def save_results(search_results)
    @results[search_results.owner] = search_results
    @results["LAST_RESULSET"] = search_results
  end

end
