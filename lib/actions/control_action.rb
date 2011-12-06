#
# Performs a command that is sent to the server.
# 
class Robut::Plugin::Rdio::ControlAction
  
  def initialize server_command_proc
    @server_command_proc = server_command_proc
  end
  
  def examples
    [
      "play/unpause - unpauses the track that is currently playing",
      "next - move to the next track",
      "next album - skip all tracks in the current album group",
      "restart - restart the current track"
    ]
  end
  
  def match?(request)
    request =~ /^(?:play|(?:un)?pause|next|restart|back|clear|next album)$/
  end
  
  def handle(time,sender,message)
    send_server_command message.gsub(/\s/,'_')
  end
  
  def send_server_command(command)
    @server_command_proc.call command
  end
  
end