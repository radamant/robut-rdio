
class Robut::Plugin::Rdio
  
  class ResultsManager
  
    def initialize
      @results = {}
    end
  
    #
    # @param [String] sender the result set for the specified sender.
    # @param [Time] time the time of this request to use to find out if the 
    #   results are too old to be used.
    # 
    # @return [SearchResult] the results for the sender if present and not
    #   too old; defaults to the last result set for any user.
  
    def results_for(sender,time)
      results_for_sender = @results[sender]
    
      if results_for_sender and results_for_sender.are_not_old?(time)
        results_for_sender
      else
        @search_results["LAST_RESULSET"]
      end
    end
  
    #
    # @param [SearchResults] results that are being saved
    #
    def save_results(results)
      @results[results.owner] = results
      @results["LAST_RESULSET"] = results
    end
  
  end
  
end