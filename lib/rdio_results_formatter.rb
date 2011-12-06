module Robut::Plugin::Rdio::RdioResultsFormatter
  extend self
  
  def results_displayer
    @results_displayer ||= begin 

      display_hash = {
        ::Rdio::Album => lambda{|album| "#{album.artist_name} - #{album.name}"},
        ::Rdio::Track => lambda{|track| "#{track.artist_name} - #{track.album_name} - #{track.name}"},
        
        ::Rdio::Artist => lambda do |artist| 
          tracks = artist.tracks(nil,0,1)
          unless tracks.empty?
            "#{artist.name} - #{tracks.first.album_name} - #{tracks.first.name}"
          else
            "#{artist.name}"
          end
          
        end
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