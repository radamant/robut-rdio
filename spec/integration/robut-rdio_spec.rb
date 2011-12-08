require_relative '../spec_helper'

# Wherein we test legacy code, and hopefully refactor and remove this file
describe "RobutRdio Super Integration Test" do
 
  let(:mock_rdio) do
    rdio = double()
    rdio
  end
 
  let(:plugin) do 
    plugin = Robut::Plugin::Rdio.new(nil) 

    def plugin.nick
      "dj"
    end
    
    plugin.stub(:store){ Hash.new }
    
    plugin.stub(:reply){ |msg| @reply = msg }

    plugin.stub(:rdio).and_return(mock_rdio)

    plugin
  end

  def say(msg)
    plugin.handle(Time.now, 'foo bar', msg)
  end

  it 'should set up a callback for the Server on startup' do
    say('boo')
    Robut::Plugin::Rdio::Server.reply_callback.should_not be_nil
  end

  # describe "searching for tracks" do
  # 
  #   it 'should make an rdio search' do
  #     
  #     stub_search "neil young", 
  #     [ { :artist => 'Neil Young', :album => 'Something', :name => 'harvest' },
  #       { :artist => 'Neil Young', :album => 'Something', :name => 'after the gold rush' } ]
  #     
  #     say '@dj find neil young'
  #     
  #     @reply.should == "@foo I found the following:\n0: Neil Young - Something - harvest\n1: Neil Young - Something - after the gold rush"
  #   end
  # 
  #   #
  #   # @param [String] query that needs to be stubbed out
  #   # @param [Array<Hash>] stubbed_responses this is the response data
  #   #
  #   def stub_search(query, stubbed_responses)
  #     mock_rdio.stub(:search).with(query,"Track",nil,nil,0,10) do 
  #       
  #       stubbed_responses.map do |response|
  #         td = Rdio::Track.new ""
  #         response.each{|attribute,value| td.send("#{attribute}=",value) }
  #         td
  #       end
  #       
  #     end
  #     
  #   end
  #   
  # end

  describe 'queuing tracks' do

    before :each do
      plugin.stub(:results).and_return(results)
      plugin.stub(:song_queue).and_return(song_queue)
    end

    let(:song_queue) do
      queue = double()
      queue.stub(:enqueue) { |result| @queued = result }
      queue
    end
    
    let(:results) do
      results = double()
    end
    
    describe 'when there is a search result' do
      
      it 'should queue the track at the given position with "play <number>"' do
        
        results.stub(:results_for).and_return([ 0000, 1111, 2222, 3333, 4444, 5555, 6666, 7777 ])
        
        say '@dj play 1'
        @queued.should == [1111]

        say '@dj 4'
        @queued.should == [4444]
        
      end

    end

  end

end
