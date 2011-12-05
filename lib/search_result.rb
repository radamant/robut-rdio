class Robut::Plugin::Rdio::SearchResult
  
  attr_reader :owner, :results, :created, :query, :filters
  
  def initialize rdio, owner, results, query, filters, relative_for_seconds = 120
    
    @rdio = rdio
    @owner = owner
    @results = results
    @query = query
    @filters = filters
    
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
    @results[result_index.to_i] if results
  end
  
  def length
    @results.length
  end

  def has_results?
    @results and @results.length > 0
  end
  
  def all
    @results
  end
  
  def first
    @results ? @results.first : nil
  end
  
  def empty?
    !has_results?
  end
  
  def append(new_results)
    @accessed = Time.now
    @results = @results + Array(new_results)
  end
  
  def more!(count)
    @accessed = Time.now
    more_results = @rdio.search(query,filters,nil,nil,@results.length + 1,count)
    @results = @results + more_results
    more_results
  end
  
end