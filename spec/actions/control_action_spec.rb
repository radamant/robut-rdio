require_relative 'spec_helper'

describe Robut::Plugin::Rdio::ControlAction do
  
  describe "#match?" do

    subject { Robut::Plugin::Rdio::ControlAction.new nil }
    
    it_should_behave_like "a matching method"
    
    let(:valid_messages) do
      [ 
        "play", 
        "pause",
        "unpause",
        "next",
        "restart",
        "back",
        "clear",
        "next album",
      ]
    end

    let(:invalid_messages) do
      [ 
        " play",
        "play       ",
        "player",
        "play-pause",
        "clearing house"
      ]
    end

  end
  
  describe "#handle" do

    let(:subject) { Robut::Plugin::Rdio::ControlAction.new nil }
    
    let(:time) { Time.now }
    let(:sender) { "sender" }
    
    
    context "when given a singluar word command" do
      
      let(:message) { "play" }
      
      it "should execute the command" do
        subject.should_receive(:send_server_command).with("play")
        subject.handle(time,sender,message)
      end

    end
    
    context "when given a two word command" do

      let(:message) { "next album" }
      
      it "should execute the command with a underscore instead of spaces" do
        subject.should_receive(:send_server_command).with("next_album")
        subject.handle(time,sender,message)
      end

    end

  end
  
  
end
