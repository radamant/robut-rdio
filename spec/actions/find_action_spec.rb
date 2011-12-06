require_relative 'spec_helper'

describe Robut::Plugin::Rdio::FindAction do
  
  describe "#find_result_for" do
    
    subject { Robut::Plugin::Rdio::FindAction.new nil, nil }
    
    let(:sender) { "sender" }
    
    context "when given a unspecified find query" do
      
      let(:query) { "justin beiber" }
      
      let(:expected_message) { "/me is searching for a track with 'justin beiber'..." }
      
      it "should search by the default type" do
        
        subject.should_receive(:reply).with(expected_message)
        subject.should_receive(:search_rdio).with("justin beiber","Track")
        subject.find_results_for(sender,query)
        
      end

    end
    
    context "when given an album" do

      let(:query) { "album radiohead" }
      
      let(:expected_message) { "/me is searching for an album with 'radiohead'..." }
      
      it "should search with the album type" do
        
        subject.should_receive(:reply).with(expected_message)
        subject.should_receive(:search_rdio).with("radiohead","Album")
        subject.find_results_for(sender,query)
        
      end

    end
    
    context "when given an artist" do

      let(:query) { "artist radiohead" }
      
      let(:expected_message) { "/me is searching for an artist with 'radiohead'..." }
      
      it "should search with the artist type" do
        
        subject.should_receive(:reply).with(expected_message)
        subject.should_receive(:search_rdio).with("radiohead","Artist")
        subject.find_results_for(sender,query)
        
      end

    end

  end
  
end
