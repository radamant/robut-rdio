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
  
  describe "#usage" do
    
    it "should return a list of commands on how to use the plugin" do
      subject.usage.should be_kind_of(Enumerable)
    end
    
  end
  
  describe "#actions" do
    
    it "should return a list of actions" do
      subject.actions.should be_kind_of(Robut::Plugin::Rdio::Actions)
    end
    
  end

  describe "#song_queue" do

    it "should return a song queue" do
      subject.song_queue.should be_kind_of(Robut::Plugin::Rdio::Queue)
    end

  end

  describe "#rdio" do

    it "should return access to the Rdio service" do
      subject.rdio.should be_kind_of(Rdio)
    end

  end

  describe "#handle" do

    let(:time) { Time.now }
    let(:sender) { "sender" }
    let(:message) { "message" }
    
    it "should establish the server callbacks" do
      subject.should_receive(:establish_server_callbacks!)
      subject.handle(time,sender,message)
    end

    context "when the message is sent to the plugin" do

      let(:message) { "@dj meaningful part of the message" }
      
      let(:meaningful_message) { "meaningful part of the message" }

      let(:action) do
        action = double()
        action.stub(:handle)
        action
      end
      
      let(:actions) do
        actions = double()
        actions.should_receive(:action_for).with(meaningful_message).and_return(action)
        actions
      end

      it "should check to see if any actions apply to the message" do
        
        subject.stub(:sent_to_me?).and_return(true)
        subject.stub(:actions).and_return(actions)
        subject.handle(time,sender,message)
        
      end

    end

  end
  
end
