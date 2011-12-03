class Robut::Plugin::Rdio::SearchResult
  
  attr_reader :owner, :results, :created
  
  def initialize owner, results, relative_for_seconds = 120
    
    @owner = owner
    @results = results
    @created = Time.now
    @relative_for_seconds = relative_for_seconds

  end
  
  #
  # Search results are too old when they were created or accessed over 2 minutes
  # ago.
  # 
  # @param [Time] comparison_time is the time to compare against the search
  #   results to determine if these search results are too old.
  #
  def are_not_old?(comparison_time)
    comparison_time - [ created, accessed ].max < @relative_for_seconds
  end
  
  def accessed
    @accessed || Time.at(0)
  end
  
  def [](result_index)
    @accessed = Time.now
    results[result_index.to_i] if results
  end

  def has_results?
    results and results.length > 0
  end
  
end