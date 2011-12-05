# require_relative '../spec_helper'
# 
# # Wherein we test legacy code, and hopefully refactor and remove this file
# describe "RobutRdio Super Integration Test" do
#  
#   let(:plugin) do 
#     plugin = Robut::Plugin::Rdio.new(nil) 
# 
#     def plugin.nick
#       "dj"
#     end
#     
#     plugin.stub(:store){ Hash.new }
#     
#     plugin.stub(:reply){ |msg| @reply = msg }
# 
#     plugin
#   end
# 
#   def say(msg)
#     plugin.handle(Time.now, 'foo bar', msg)
#   end
# 
#   it 'should set up a callback for the Server on startup' do
#     say('boo')
#     Robut::Plugin::Rdio::Server.reply_callback.should_not be_nil
#   end
# 
#   describe "searching for tracks" do
# 
#     it 'should make an rdio search' do
#       stub_search('neil young', ['harvest', 'after the gold rush'])
#       say '@dj find neil young'
#       @reply.should == "@foo I found the following:\n0: harvest\n1: after the gold rush"
#     end
# 
#     def stub_search(mock_query, results)
#       plugin.stub(:search).with(mock_query) do 
#         Robut::Plugin::Rdio::SearchResult.new "rdio", "foo", results, "neil young", "Artist"
#       end
#       results.each do |result|
#         plugin.stub(:format_result).with(result) { result }
#       end
#     end
# 
#     
#   end
# 
#   describe 'queuing tracks' do
# 
#     describe 'when there is a search result' do
#       before do
#         plugin.stub(:results) { [ 0000, 1111, 2222, 3333, 4444, 5555, 6666, 7777 ] }
#         plugin.stub(:queue) { |result| @queued = result }
#         # plugin.stub(:has_results?) { true }
#         # plugin.stub(:has_result?) { true }
#       end
# 
#       it 'should queue the track at the given position with "play <number>"' do
#         say '@dj play 1'
#         @queued.should == [1111]
# 
#         say '@dj 4'
#         @queued.should == [4444]
#       end
# 
#     end
# 
#     describe 'when there are no search results' do
#       before do
#         plugin.stub(:results) { nil }
#       end
# 
#       it 'should say there are no results' do
#         say '@dj play 9'
#         @reply.should == "I don't have any search results"
#       end
#     end
# 
#   end
# 
#   describe 'running commands' do
#     before do
#       plugin.stub(:send_server_command) { |command| @command = command }
#     end
# 
#     %w{play unpause pause next restart back clear}.each do |command|
#       it "should run #{command}" do
#         say("@dj #{command}")
#         @command.should == command
#       end
#     end
#   end
# 
#   describe 'skipping an album' do
#     before do
#       plugin.stub(:send_server_command) { |command| @command = command }
#     end
#     it "should run next_album for `next album`" do
#       say("@dj next album")
#       @command.should == "next_album"
#     end
# 
#     it "should run next_album for `skip album`" do
#       say("@dj skip album")
#       @command.should == "next_album"
#     end
#   end
# 
# end
