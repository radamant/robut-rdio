require 'spec_helper'

shared_examples "a routing method" do
  
  context "when given valid requests" do

    it "should return a truthy value" do
      routing_method = example.metadata[:method]
      
      valid_requests.each do |request|
        subject.send(routing_method,request).should be_true, "expected the Request '#{request}' (#{request.class}) to be valid"
      end

    end
    
  end
  
  context "when given invalid requests" do
    
    it "should return a falsy value" do
      routing_method = example.metadata[:method]

      invalid_requests.each do |request|
        subject.send(routing_method,request).should be_false, "expected the Request '#{request}' (#{request.class}) to be invalid"
      end
      
    end
    
  end
  
end

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
  
end
