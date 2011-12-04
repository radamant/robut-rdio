require_relative '../spec_helper'

describe NoAction do
  
  subject { NoAction }
  
  describe "#handle" do

    it "should respond to this method" do
      
      subject.should respond_to(:handle)
      expect { subject.handle "time", "sender", "message" }.not_to raise_error
      
    end

  end
  
end
