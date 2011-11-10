require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# Wherein we test legacy code, and hopefully refactor and remove this file
describe "RobutRdio Super Integration Test" do
  let(:plugin) do plugin = Robut::Plugin::Rdio.new(nil) 
  def plugin.nick
    "dj"
  end


  plugin.stub(:reply){|msg|
    @reply = msg
  }

  plugin
  end

  def say(msg)
    plugin.handle(Time.now, 'foo bar', msg)
  end

  describe "searching for tracks" do


    it 'should make an rdio search' do
      stub_search('neil young', 'harvest')
      say('@dj find neil young')
      @reply.should == 'harvest'
    end

    def stub_search(mock_query, results)
      plugin.stub(:search).with(['', mock_query])
      plugin.stub(:format_results){results}
    end

    
  end

  describe 'queuing tracks' do

    describe 'when there is a search result' do
      before do
        plugin.stub(:result_at){|i| i.to_s}
        plugin.stub(:queue){|result| @queued = result}
        plugin.stub(:has_results?){true}
        plugin.stub(:has_result?){true}
      end

      it 'should queue the track at the given position with "play <number>"' do
        say '@dj play 1'
        @queued.should == '1'

        say '@dj 8'
        @queued.should == '8'
      end

    end

    describe 'when there are no search results' do
      before do
        plugin.stub(:has_results?){false}
      end

      it 'should say there are no results' do
        say '@dj play 9'
        @reply.should == "I don't have any search results"
      end
    end

    describe 'when there are results but not at the requested index' do
      before do
        plugin.stub(:has_results?){true}
        plugin.stub(:has_result?).with(5){false}
      end
      it 'should say the result does not exist' do
        say '@dj play 5'
        @reply.should == "I don't have that result"
      end
    end
  end

end
