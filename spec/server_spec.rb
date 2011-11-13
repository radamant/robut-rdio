require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Robut::Plugin::Rdio::Server do 
  include Rack::Test::Methods

  def app
    @app ||= Robut::Plugin::Rdio::Server
  end

  it 'should render a web player' do
    get '/'
    last_response.should be_ok
    last_response.body.should include '<div id="apiswf"></div>'
  end

  it 'should be able to tell HipChat what song is playing' do
    Robut::Plugin::Rdio::Server.reply_callback = lambda{ |message| @message = message }
    get '/now_playing/The%20National%20-%20Bloodbuzz%20Ohio'
    last_response.should be_ok
    @message.should == 'Now playing: The National - Bloodbuzz Ohio'
  end
end
