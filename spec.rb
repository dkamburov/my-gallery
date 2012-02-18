require File.expand_path(File.dirname(__FILE__)) + "/main.rb"

require "rspec"
require "rack/test"

set :environment, :test

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Sinatra::Application
end

describe "Tests: " do
    before(:each) do
      @first = Image.first
	  @last = Image.last
	  @random = Image.get(rand(1..@last.id))
	  @count = Dir["public/files/*"].count
    end
	
	
	it "should get /" do 
	  get "/"
      last_response.should be_ok
	  last_response.should_not be_empty
    end
	
	it "should accept uploaded files and save them into the `files` directory" do
	  post "/upload", :file => Rack::Test::UploadedFile.new("testfile/test_file.jpg", "image/jpg")
      @count.should_not == Dir["public/files/*"].count
    end
	
	it "should not upload emprty files into the `files` directory" do
	  post "/upload", :file => Rack::Test::UploadedFile.new("testfile/empty_file.jpg", "image/jpg")
      @count.should == Dir["public/files/*"].count
    end
	
	it "should not be able to upload nothing" do
	  post "/upload", {}
      @count.should == Dir["public/files/*"].count
    end
    
	it "should get first picture" do
      get "/pic/#{@first.id}"
	  last_response.should be_ok
	  last_response.should_not be_empty
    end
	
	it "should get last picture" do
      get "/pic/#{@last.id}"
	  last_response.should be_ok
	  last_response.should_not be_empty
    end
	
	it "should get random picture" do
      get "/pic/#{@random.id}"
	  last_response.should be_ok
	  last_response.should_not be_empty
    end
	
	
	it "should bind comment with images" do
      Comment.new.should_not be_valid
	end
	
	
	it "should not create comments without author and content" do
      Image.get(1).comments.create.should_not be_valid
	end
	
	it "should create normal comment" do
	  Image.get(1).comments.create({:author => "he",
                                    :content => "this is a testcomment"}).should be_valid
	  
	end
	
	it "should not create comment with one argument" do
      Image.get(1).comments.create({:author => "John"}).should_not be_valid    
      Image.get(1).comments.create({:content => "Nice!"}).should_not be_valid
    end

    it "should not reply files with same names the `files` directory" do
	  post "/upload", :file => Rack::Test::UploadedFile.new("testfile/test_file.jpg", "image/jpg")
      @count.should_not == Dir["public/files/*"].count
	  @count = Dir["public/files/*"].count
	  post "/upload", :file => Rack::Test::UploadedFile.new("testfile/test_file.jpg", "image/jpg")
      @count.should_not == Dir["public/files/*"].count
    end	
		
	it "should be valid creating new Image" do
      Image.new.should be_valid
    end
	
	it "should be valid creating Image with arguments" do
      Image.new(:file => "test_file.jpg").should be_valid
	end
	
end
	