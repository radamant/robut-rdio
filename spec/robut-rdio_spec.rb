require 'spec_helper'

describe Robut::Plugin::Rdio do
  
  subject { 
    connection = double("connection")
    connection.stub_chain(:config, :nick) { "dj" }
    connection.stub(:store).and_return(store)
    connection.stub(:reply).and_return(nil)
    Robut::Plugin::Rdio.new connection 
  }
  
  let(:sender) { "sender" }
  
  let!(:store) { {} }
  
  let(:time) { Time.now }
  
  describe "#usage" do
    
    # Though it is acceptable for the plugin to return a String here,
    # it is important that we return an Enumerable list of instruction examples
    # as we have so many different commands.
    it "should return a list of commands on how to use the plugin" do
      subject.usage.should be_kind_of(Enumerable)
    end
    
  end
  
  describe "Routing Methods" do
    
    describe "#play?", :method => :play? do
      
      it_should_behave_like "a routing method"

      let(:valid_requests) do
        [ 
          "play 0", 
          "play 999999", 
          [ "play", "0" ], 
          "result1", 
          "result 1", 
          [ "result 0"] 
        ]
      end

      let(:invalid_requests) do
        [ 
          "play Abba", 
          "play ",
          [ "play", "three-eleven" ]
        ]
      end

    end
    
    describe "search?", :method => :search? do
      
      it_should_behave_like "a routing method"
      
      let(:valid_requests) do
        [ 
          "find the beatles", 
          "do you have any grey poupon", 
          [ "find", "breeders" ], 
          "do you have Weezer", 
          "find finding nemo"
        ]
      end

      let(:invalid_requests) do
        [ 
          "play Abba", 
          "play ",
          [ "play", "three-eleven" ]
        ]
      end
      
    end
    
    describe "#search_and_play?", :method => :search_and_play? do
      
      it_should_behave_like "a routing method"
      
      let(:valid_requests) do
        [ 
          "play the beatles", 
          [ "play", "breeders" ], 
          "play doh re me ...", 
          "play me a song mister piano man"
        ]
      end
    
      let(:invalid_requests) do
        [ 
          "play",
          "find this and play it for me", 
          " play even with that space at the start",
          [ "plato", "first", "album" ]
        ]
      end
      
    end
    
    describe "#command?", :method => :command? do
      
      it_should_behave_like "a routing method"
      
      let(:valid_requests) do
        [ 
          "play", 
          "pause",
          "unpause",
          "next",
          "restart",
          "back",
          "clear",
          [ "play" ]
        ]
      end
    
      let(:invalid_requests) do
        [ 
          " play",
          "play       ",
          "player",
          "play-pause",
          "clearing house"
        ]
      end
      
    end
    
  end
  
  describe "#handle" do
    
    it "should create a communication channel with the music server" do
      
      subject.should_receive(:establish_server_callbacks!).and_return(nil)
      subject.handle(time,"","")
      
    end

    context "when not sent to the agent" do

      let(:message) { "This message does not mention the dj" }
      
      it "should perform no action" do
        
        subject.should_not_receive(:play?)
        subject.handle(time,sender,message)
        
      end
      
    end
    
    context "when sent to the agent" do
      
      context "when it is a play request" do
        
        let(:message) { "@dj play 0" }
        
        it_should_behave_like "a successfully routed action", 
          :route => :play?, :action => :play_result, :parameters => 0
        
      end
      
      context "when it is a search and play request" do
        
        let(:message) { "@dj play the misfits" }

        context "when the search returns a result" do
          
          it_should_behave_like "a successfully routed action", 
            :route => :search_and_play?, :action => :search_and_play_result, 
              :parameters => "the misfits", :returning => true
          
        end
        
        context "when the search result does not return a result" do

          before :each do 
            subject.should_receive(:reply).with("I couldn't find 'the misfits' on Rdio.")
          end

          it_should_behave_like "a successfully routed action", 
            :route => :search_and_play?, :action => :search_and_play_result, :parameters => "the misfits"
          
        end
        
      end
      
      context "when it is a search request" do
        
        let(:message) { "@dj find the partridge family" }
        
        it_should_behave_like "a successfully routed action",
          :route => :search?, :action => :find, :parameters => "the partridge family"
        
      end
      
      context "when it is a skip album request" do
        
        let(:message) { "skip album @dj" }
        
        it_should_behave_like "a successfully routed action",
          :route => :skip_album?, :action => :run_command, :parameters => "next_album"
        
      end
      
      context "when it is command" do
        
        let(:message) { "@dj pause" }
        
        it_should_behave_like "a successfully routed action",
          :route => :command?, :action => :run_command, :parameters => "pause"
        
      end
      
    end
    
    
  end
  
end
