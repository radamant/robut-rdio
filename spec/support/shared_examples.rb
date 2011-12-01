#
# A routing method has valid/invalid input. This shared example is used by
# all of ther routing methods. 
# 
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
