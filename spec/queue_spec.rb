require_relative 'spec_helper'

describe Robut::Plugin::Rdio::Queue do
  
  class TestEnqueuingService
    
    attr_accessor :queued
    
    def call(value)
      (@queued ||= []) << value
    end
    
  end
  
  let(:enqueue_service) { TestEnqueuingService.new }
  
  let(:subject) { Robut::Plugin::Rdio::Queue.new(enqueue_service) }
  
  
  describe "#enqueue" do

    let(:results) do
      result = double()
      result.stub(:key).and_return(:results_key)
      [ result ]
    end
    
    it "should properly enqueue the results" do
      subject.enqueue(results)
      enqueue_service.queued.should include(:results_key)
    end
    
  end
  
  describe "queue" do
    
    let(:updated_queue) { { 1 => :firstitem, 2 => :seconditem } }
    
    before :each do
      subject.update updated_queue
    end
    
    it "should be accessible through enumerable" do
      subject.map {|key,value| value }.should == [ :firstitem, :seconditem ] 
    end
    
    it "should be accessible like a Hash" do
      subject[1].should == :firstitem
      subject[2].should == :seconditem
    end
    
  end
  
end
