require_relative '../spec_helper'

describe ShowQueueAction do
  
  describe "#examples" do
    
    subject { ShowQueueAction.new nil, nil }
    
    it "should return a single example or list of examples" do
      examples = subject.examples
      (examples.class == String || examples.class == Enumerable).should be_true
    end

  end
  
  describe "#match?" do

    subject { ShowQueueAction.new nil, nil }

    it_should_behave_like "a matching method"

    let(:valid_messages) do
      [ 
        "show queue" 
      ]
    end
    
    let(:invalid_messages) do
      [ 
        "queue show",
        "show queueue"
      ]
    end

  end
  
  describe "#handle" do

    subject { ShowQueueAction.new nil, queue }

    let(:time) { Time.now }
    let(:sender) { "sender" }
    let(:message) { "show queue" }

    context "when the queue is empty" do
      
      let!(:queue) { [] }
      
      let(:expected_results) do
        "@sender there are currently no songs in the queue"
      end
      
      it "should reply with the correct queue state" do
        
        subject.should_receive(:reply).with(expected_results)
        subject.handle(time,sender,message)
        
      end

    end
    
    context "when the queue has tracks" do

      let!(:queue) do
        [{ "artist" => "ARTIST", "album" => "ALBUM", "track" => "TRACK" }]
      end
      
      let(:expected_results) do
        "@sender the queue is currently:\nARTIST - ALBUM - TRACK"
      end

      it "should reply with the correct queue state" do
        
        subject.should_receive(:reply).with(expected_results)
        subject.handle(time,sender,message)
        
      end

    end

    

  end
  
end
