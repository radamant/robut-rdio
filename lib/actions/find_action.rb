require_relative 'reply_action'
require_relative '../query_parser'
require_relative '../search_result'

#
# FindAction is likely not the best representation of this operation as this is not
# matched like other actions. It instead shoudl simply a searching wrapper for
# the Rdio interface that allows the encapsulation of the query becoming the 
# search results.
# 
class FindAction
  include ReplyAction
  
  #
  # The FindActions requires the ability to output to the system what it is
  # currently searching for when it begins and search and also the Rdio API
  # instance to provide the ability to search.
  # 
  # @param [Proc] reply proc that allows one string parameter for output
  # @param [Rdio] rdio an instance of rdio api that has been initalized
  #
  def initialize(reply,rdio)
    @reply = reply
    @rdio = rdio
  end
  
  def handle(time,sender,message)
    
    find_results_for(sender,message)
    
  end
  
  #
  # Convert the query string into the correct componenets and filters as used
  # by Rdio. The specification of the sender is to include that user's name
  # as the originator of the search query.
  # 
  # @param [String] query the search criteria to use to find and then queue
  #   up.
  # @return [SearchResult] that is associated with the current user and contains
  #   the set of results for the users's query.
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
    results = @rdio.search(query,filters,nil,nil,start,count)
    
    # Artist results that come back are not queuable so we need to find a track
    # by that artist and place that in the search results.

    # Here we say that if an Artist is returned we will replace it with three of 
    # their songs.
    # @note that for searching for artists like 'kool' or 'bjork' return a large
    #   set of data this way.
    
    results.map do |result|
      result.is_a?(::Rdio::Artist) ? result.tracks(nil,0,3) : result
    end.flatten.compact
    
  end

end
