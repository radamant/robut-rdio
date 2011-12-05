require_relative 'reply_action'
require_relative '../query_parser'
require_relative '../search_result'


class FindAction
  include ReplyAction
  
  def initialize(reply,rdio)
    @reply = reply
    @rdio = rdio
  end
  
  def handle(time,sender,message)
    
    find_results_for(sender,message)
    
  end
  
  #
  # @param [String] query the search criteria to use to find and then queue
  #   up.
  # @return [SearchResult] that is associated with the current user and contains
  #   the set of results for the users's query.
  #
  def find_results_for(sender,query_string)
    query = QueryParser.parse query_string
    query_type = query.type || default_type_of_query

    reply "/me is searching for #{query.type.to_s[0] == 'a' ? 'an' : 'a'} #{query_type} with '#{query.terms}'..."
    
    results = search_rdio(query.terms, query_type.to_s.capitalize)
    
    Robut::Plugin::Rdio::SearchResult.new @rdio, sender, results, query.terms, query_type.to_s.capitalize
  end
  
  
  #
  # Default the type query to track if one was not found by the QueryParser
  # 
  def default_type_of_query
    :track
  end
  
  # Searches Rdio for sources matching +words+. 
  # 
  # Given an array of Strings, which are the search terms, use Rdio to find any
  # tracks that match. If the first word happens be `album` then search for
  # albums that match the criteria.
  #
  #
  # @param [String] query the query string
  # @param [String] filters the areas to filter the data (i.e. Artist, Track, Album)
  #
  def search_rdio(query,filters,start=0,count=10)
    @rdio.search(query,filters,nil,nil,start,count)
  end

end
