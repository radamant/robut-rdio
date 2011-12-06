require_relative 'spec_helper'

describe Robut::Plugin::Rdio::PlayResultsAction do
  
  describe "#examples" do
    
    subject { Robut::Plugin::Rdio::PlayResultsAction.new nil, nil, nil }
    
    it "should return a single example or list of examples" do
      examples = subject.examples
      (examples.class == String or examples.class == Array).should be_true
    end

  end
  
  describe "#match?" do

    subject { Robut::Plugin::Rdio::PlayResultsAction.new nil, nil, nil }

    it_should_behave_like "a matching method"

    let(:valid_messages) do
      [ 
          # play keyword
          "play 0",
          "play 999999", 
          # result keyword
          "result1", 
          "result 1", 
          # multiple tracks
          "play 1, 2, 3",
          "play 1 2 3",
          "play 1 - 3",
          "play 1-3",
          # all tracks
          "play all"
      ]
    end
    
    let(:invalid_messages) do
      [ 
        "play Abba", 
        "play ",
        [ "play", "three-eleven" ]
      ]
    end

  end
  
  describe "#parse_tracks_to_play" do

    subject { Robut::Plugin::Rdio::PlayResultsAction.new nil, nil, nil }

    context "when given tracks delimited by spaces or commas" do

      let(:track_request) { "play 0 1 4,  6" }

      it "should add them to the list of tracks" do
        subject.parse_tracks_to_play(track_request).should == [ 0, 1, 4, 6 ]
      end
      
    end

    context "when given tracks delimited by dashes" do

      let(:track_request) { "play 0 1-4, 6" }
      
      it "should add the range of tracks to the list" do
        subject.parse_tracks_to_play(track_request).should == [ 0, 1, 2, 3, 4, 6 ]        
      end

    end
    
    context "when given 'play all'" do

      let(:track_request) { "play all" }

      it "should resturn the value all" do
        subject.parse_tracks_to_play(track_request).should == [ "all" ]
      end

    end

  end
  
  describe "#handle" do

    subject { Robut::Plugin::Rdio::PlayResultsAction.new nil, nil, results }

    let(:results) { Hash.new }

    let(:time) { Time.now }
    let(:sender) { "sender" }
    let(:message) { "play 2" }

    context "when the search results are empty" do
      
      let(:expected_message) { "I don't have any search results" }
      
      it "should reply with the correct queue state" do
        
        subject.should_receive(:reply).with(expected_message)
        subject.handle(time,sender,message)
        
      end

    end
    
    context "when the search results have tracks" do

      context "when the user requests an unknown track" do
        
        let(:stubbed_results) do
          stub_results = double()
          stub_results.stub(:empty?).and_return(false)
          stub_results.stub(:[]).with(2).and_return(nil)
          stub_results
        end
        
        it "should send an empty list of tracks to the queue method" do
          subject.stub(:results_for).and_return(stubbed_results)
          subject.stub(:display_enqueued_tracks)
          
          subject.should_receive(:queue).with( [2], stubbed_results )
          subject.handle(time,sender,message)
        end
        
      end
      
      context "when the user requests a known track" do

        let(:stubbed_results) do
          stub_results = double()
          stub_results.stub(:empty?).and_return(false)
          stub_results.stub(:[]).with(2).and_return(2)
          stub_results
        end

        it "should send a list of tracks to the queue method" do
          subject.stub(:results_for).and_return(stubbed_results)
          subject.stub(:display_enqueued_tracks)
          
          subject.should_receive(:queue).with( [2], stubbed_results )
          subject.handle(time,sender,message)
        end

      end

    end

  end
  
end