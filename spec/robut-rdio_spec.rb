require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# Wherein we test legacy code, and hopefully refactor and remove this file
describe "RobutRdio Super Integration Test" do
 
  let(:plugin) do 
    plugin = Robut::Plugin::Rdio.new(nil) 

    def plugin.nick
      "dj"
    end

    plugin.stub(:reply){ |msg| @reply = msg }

    plugin
  end

  def say(msg)
    plugin.handle(Time.now, 'foo bar', msg)
  end

  describe "searching for tracks" do

    it 'should make an rdio search' do
      stub_search('neil young', ['harvest', 'after the gold rush'])
      say('@dj find neil young')
      @reply.should == "result: harvest\nresult: after the gold rush\n"
    end

    def stub_search(mock_query, results)
      plugin.stub(:search).with(['', mock_query]) { results }
      results.each do |result|
        plugin.stub(:format_result).with(result, anything()) { "result: #{result}" }
      end
    end

    
  end

  describe 'queuing tracks' do

    describe 'when there is a search result' do
      before do
        plugin.stub(:result_at) { |i| i.to_s }
        plugin.stub(:queue) { |result| @queued = result }
        plugin.stub(:has_results?) { true }
        plugin.stub(:has_result?) { true }
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
        plugin.stub(:has_results?) { false }
      end

      it 'should say there are no results' do
        say '@dj play 9'
        @reply.should == "I don't have any search results"
      end
    end

    describe 'when there are results but not at the requested index' do
      before do
        plugin.stub(:has_results?) { true }
        plugin.stub(:has_result?).with(5) { false }
      end
      it 'should say the result does not exist' do
        say '@dj play 5'
        @reply.should == "I don't have that result"
      end
    end
  end

  describe "I'm feeling lucky play/search" do
  
  end

  describe 'running commands' do
    before do
      plugin.stub(:run_command) { |command| @command = command }
    end

    %w{play unpause pause next restart back clear}.each do |command|
      it "should run #{command}" do
        say("@dj #{command}")
        @command.should == command
      end
    end
  end

end
