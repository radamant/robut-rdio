(function($) {

  window.Track = Backbone.Model.extend({

    updateWithRdioTrack: function(rdioTrack) {
      
      this.set({artist: rdioTrack.artist, 
        album: rdioTrack.album, 
        title: rdioTrack.name, 
        duration: rdioTrack.duration});
    }
    
  });

  window.TrackView = Backbone.View.extend({
    tag: 'li',
    className: 'track',
    
    initialize: function() {
      _.bindAll(this, 'render');
      this.model.bind('change',this.render);
      this.template = _.template($('#track-template').html());
    },

    render: function() {
     if ( this.model.has("title") ) {
        // When there no content to be displayed we should render hidden
        var renderedContent = this.template(this.model.toJSON());
        $(this.el).html(renderedContent);      
      } else {
        // When there is no content to be displayed we should render hidden
        //var renderedContent = this.template({title: 'All lines are open ...'});
        //$(this.el).html(renderedContent);      
      }
      return this;
    }
  });

  window.currentTrack = new Track();
  window.currentTrackView = new TrackView({model:currentTrack});
  $('#current_track').append(currentTrackView.render().el);
})(jQuery);
