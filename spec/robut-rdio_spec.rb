require 'spec_helper'

describe Robut::Plugin::Rdio do
  
  subject { 
    connection = double("connection")
    connection.stub_chain(:config, :nick) { "dj" }
    connection.stub(:store).and_return(store)
    connection.stub(:reply).and_return(nil)
    Robut::Plugin::Rdio.new connection 
  }
  
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
    
    
  end
  
end
