RdioPlayer = (function () {

  var playerElement = {};

  function initPlayer (options) {
      // on page load use SWFObject to load the API swf into div#apiswf
    var flashvars = {
      'playbackToken': options.token, // from token.js
      'domain': options.domain,                // from token.js
      'listener': options.callbackName    // the global name of the object that will receive callbacks from the SWF
    };
    
    var params = {
      'allowScriptAccess': 'always'
    };
    
    var attributes = {};
    
    playerElement = options.elementId;
    
    swfobject.embedSWF('http://www.rdio.com/api/swf/', // the location of the Rdio Playback API SWF
                       options.elementId, // the ID of the element that will be replaced with the SWF
                       1, 1, '9.0.0', 'expressInstall.swf', flashvars, params, attributes);
  }

  function establishControls(rdio) {
      
      rdio.isPlaying = function () { 
          return rdio.callback.playing;
      }
      
      rdio.isPaused = function () {
          return !rdio.callback.playing;
      }
      
      rdio.play = function () { 
          rdio.player.rdio_play();
          $(rdio.player).attr("playingState","playing");
      }
      
      rdio.pause = function () { 
          rdio.player.rdio_pause();
          $(rdio.player).attr("playingState","paused");
      }
      
      rdio.toggle = function () { 
          if ( rdio.isPlaying() ) {
              rdio.pause();
          } else {
              rdio.play();
          }
      }
  }

  function reporting(rdio) {

    rdio.announce = function(message,announcementType) {

      announcementType = typeof(announcementType) != 'undefined' ? announcementType : 'announcement';
      
      $.ajax({
        url: '/' + announcementType + '/' + message,
        dataType: 'json'
      });
    }
    
    rdio.queueChanged = function(newQueue) {
      
      var queueJSONData = $.map(newQueue,function(value,index) {
        return { artist: value.artist,
          album: value.album,
          track: value.name,
          url: value.url }
      });
      
      $.ajax({
        url: '/queue.json',
        type: 'POST',
        dataType: 'json',
        data: JSON.stringify(queueJSONData)
      });
    
    }


  }

  var checkCommand = function (callbackObject, element) {
      
      $.ajax({
         url: '/command.json',
         dataType: 'json',
         success: function (data) {
             if (data.length > 0) {
                 var command = data[0];
		 if(command == 'next_album'){
		   element.rdio_next(true);
		 }

                 if (command == "pause") {
                     element.rdio_pause();
                 }
                 
                 if (command == "unpause" || command == "play") {
                     element.rdio_play();
                 }

                 if (command == "next") {
                     element.rdio_next();
                 }
                 
                 if (command == "restart") {
                     element.rdio_previous();
                 }

                 if(command == "clear") {
                   element.rdio_clearQueue();
                   element.rdio_next(true);
                 }

                 
             }
         }
          
      });
      
      setTimeout(function () {
        checkCommand(callbackObject, element)
      }, 2000);
      
  }

  var updateQueue = function (callbackObject, element) {
    
    $.ajax({
      url: '/queue.json',
      dataType: 'json',
      success: function (data) {
        if (data.length > 0) {

          if (!callbackObject.playing) {
            element.rdio_play(data[0]);
            data = data.slice(1);
          }

          for (var i = 0, _length = data.length; i < _length; i++) {
            element.rdio_queue(data[i]);
          }

        }
      }
    });
  
    setTimeout(function () {
      updateQueue(callbackObject, element)
    }, 5000);
  };

  function createCallback(rdio, callbackName, elementId) {
    var callback = {};

    callback.ready = function () {
      self.ready = true;
      var element = document.getElementById(elementId);
      rdio.player = element;
      updateQueue(callback, element);
      checkCommand(callback, element);
    }
    
    callback.playStateChanged = function (playState) {
      if (playState === 0 || playState === 4) {
        callback.playing = false;
        $('#player_state').html("<img src=\"images/circle-pause.png\">");
        rdio.announce("Pausing for station identification.");
      } else if (playState === 1) {
        callback.playing = true;
        $('#player_state').html("<img src=\"images/circle-play.png\">");
      } else if (playState === 2) {
        callback.playing = false;
        $('#player_state').html("<img src=\"images/circle-stop.png\">");
        rdio.announce("Stopping for station identification.");      
      } else if (playState === 3) {
        callback.playing = true;
        $('#player_state').html("<img src=\"images/buffering.png\">");
        //rdio.announce("We'll continue this song after we go to Traffic with our in the sky Chopper Dave!")
      }
    }

    callback.playingSomewhereElse = function() {
      rdio.announce("The FCC has called our bluff and we are being taken off the air. Good night and good luck!");
      $('#player_state').html("<img src=\"images/disconnected.png\">");
    }

    callback.sourceTitle = function (source) {
      return source.artist + " - " + source.name;
    }

    callback.sourceList = function (source) {
      var queue = "";
      for (var i = 0, _length = source.length; i < _length; i++) {
        queue += "<li class=\"source\">" +
          callback.sourceTitle(source[i]) +
          "</li>";
      }
      return queue;
    }
    
    callback.queueChanged = function (newQueue) {
      $('#queue').html(callback.sourceList(newQueue));
      if (newQueue.length > 0) {
        $('#queue_header').show().html('Queue (' + newQueue.length + ')');
        
      } else {
        $('#queue_header').hide();
      }
      
      rdio.queueChanged(newQueue);
      
    }

    callback.playingSourceChanged = function (playingSource) {
      var source = []
      if (playingSource.tracks) {
        source = playingSource.tracks;
      } else {
        source = [playingSource];
      }
      $('#now_playing').html(callback.sourceList(source));
      $('#album_art').attr('src', playingSource.icon); 
    }

    callback.playingTrackChanged = function(playingTrack, sourcePosition) {
      if (playingTrack) {
        var title = callback.sourceTitle(playingTrack);
        
        // Remove the current playing highlight on the current track and move it
        // to the correct track.
        
        $('#now_playing li').removeClass('playing');
        $('#now_playing li').eq(sourcePosition).addClass('playing');
        
        // Update the browser page title 
        
        $('title').html(title + " - Powered by Rdio");
        
        // Update the playing header
        $('#current_track').show();
        $('#current_track_name').html(title);
        
        rdio.announce(encodeURIComponent(title),"now_playing");
       
      } else {
        $('#current_track').hide();
      }
    }

    window[callbackName] = callback;
    return callback;
  }

  function RdioPlayer (options) {
    this.options = options;
    this.callback = createCallback(this, options.callbackName, options.elementId);
    
    establishControls(this);
    reporting(this);

    initPlayer(options);
  }

  return RdioPlayer;
})();

function playerKeyboardShortcuts() {
  if (window.top.frames.main) return;
  
  $(document).keydown(function(evt) {
      
      if (evt.altKey || evt.ctrlKey || evt.metaKey || evt.shiftKey) return;
      
      if (typeof evt.target !== "undefined" &&
          (evt.target.nodeName == "INPUT" ||
          evt.target.nodeName == "TEXTAREA")) return;
      
      switch (evt.keyCode) {
          
        // Space Bar is play/pause
        case 32: 
        window.rdio.toggle(); 
        return false;
        break;

        // Previous Track - Left Arrow, P
        case 37: case 80: case 112: 
        window.rdio.player.rdio_previous(); 
        return false;
        break;

        // Next Track - Right Arrow, N
        case 39: case 78: case 110: 
        window.rdio.player.rdio_next(); 
        return false;
        break;
        
      }
      
  });
  
}


$(document).ready(function () {
  window.rdio = new RdioPlayer({
    token: rdio_token,
    domain: rdio_domain,
    elementId: 'apiswf',
    callbackName: 'rdio_callback'
  });
  
  $(playerKeyboardShortcuts);
});

