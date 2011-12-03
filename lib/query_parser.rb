
module QueryParser
  extend self
  
  ParsedQuery = Struct.new :terms, :type
  
  def parse(query)
    
    terms = query[/^(?:album|track|artist)?\s*(.+)$/i,1]
    ParsedQuery.new terms, determine_type(query)
    
  end
  
  #
  # Determine from the query the type of query that has been specified. If none
  # match it will return the default query for the system.
  # 
  # @param [String] query that is being interogated
  #
  def determine_type(query)
    if query.to_s =~ /^album.+/i
      :album
    elsif query.to_s =~ /^track.+/i
      :track
    elsif query.to_s =~ /^artist.+/i
      :artist
    end
  end
  
end