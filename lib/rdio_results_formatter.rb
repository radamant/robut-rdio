module RdioResultsFormatter
  extend self
  
  def results_displayer
    @results_displayer ||= begin 

      display_hash = {
        ::Rdio::Album => lambda{|album| "#{album.artist.name} - #{album.name}"},
        ::Rdio::Track => lambda{|track| "#{track.artist.name} - #{track.album.name} - #{track.name}"},
        ::Rdio::Artist => lambda{|artist| "#{artist.name} - #{artist.tracks.sample.name}"}
      }

      fallback_display = lambda{|object| object.to_s }
      
      display_hash.default fallback_display
      display_hash
    end
  end
  
  #
  # @param [Result] search_result an Rdio object that will be displayed
  #
  def format_result(search_result)
    results_displayer[search_result.class].call(search_result)
  end
  
end