require_relative 'spec_helper'

describe FindAndPlayAction do
  
  describe "#match?" do

    subject { FindAndPlayAction.new nil, nil, nil }
    

    it_should_behave_like "a matching method"
    
    let(:valid_messages) do
      [
        'play something',
        'play anything',
        'play something complicated'
      ]
    end

    let(:invalid_messages) do
      [
        'play'
      ]
    end

  end
  
end
