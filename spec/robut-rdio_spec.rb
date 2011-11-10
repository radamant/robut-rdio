require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "RobutRdio Super Integration Test" do
  # Wherein we test legacy code, and hopefully refactor and remove this file
  describe "searching for tracks" do
    let(:plugin) do plugin = Robut::Plugin::Rdio.new(nil) 
      def plugin.nick
        "dj"
      end

      plugin
    end

    before do
      plugin.stub(:reply){|msg|
        @reply = msg
      }
    end

    it 'should make an rdio search' do
      stub_search('neil young', 'harvest')
      say('@dj find neil young')
      @reply.should == 'harvest'
    end

    def stub_search(mock_query, results)
      plugin.stub(:search).with(['', mock_query])
      plugin.stub(:format_results){results}
    end

    
    def say(msg)
      plugin.handle(Time.now, 'foo bar', msg)
    end
  end

end
