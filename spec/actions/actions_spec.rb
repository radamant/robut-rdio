require_relative 'spec_helper'

describe Actions do
  
  describe "#initialize" do
    
    context "when given no parameters" do

      it "should create an instance" do
        subject.should be
      end

    end
    
    context "when given any number of parameters" do
      
      subject { Actions.new :a, :b, :c }

      it "should create an instance" do
        subject.should be
      end

    end
    
  end
  
  describe "#action_for" do
    
    let(:message) { "find something" }
    
    context "when there are no actions" do

      it "should return NoAction" do
        subject.action_for(message).should == NoAction
      end

    end

    context "when no actions match the message" do
      
      subject { Actions.new example_action }
      
      let(:example_action) do 
        non_matching_action = double()
        non_matching_action.stub(:match?).and_return(false)
        non_matching_action
      end
      
      it "should return NoAction" do
        subject.action_for(message).should == NoAction
      end

    end
    
    context "when an action matches the message" do

      subject { Actions.new example_action }

      let(:example_action) do 
        matching_action = double()
        matching_action.stub(:match?).and_return(true)
        matching_action
      end

      it "should return that action" do
        subject.action_for(message).should == example_action
      end

    end
    
  end
  
  describe "#examples" do

    context "when there are actions with examples" do

      subject { Actions.new first_action, second_action }

      let(:first_action) do 
        action = double()
        action.stub(:examples).and_return(expected_examples.first)
        action
      end
      
      let(:second_action) do
        action = double()
        action.stub(:examples).and_return(expected_examples[1..-1])
        action
      end

      let(:expected_examples) do
        [ 
          "play <track> - plays this track", 
          "play artist <artist>", 
          "play album <album>"
        ]
        
      end

      it "should return an array of examples" do
        subject.examples.should == expected_examples
      end

    end

  end
  
end
