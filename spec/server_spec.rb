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
end
