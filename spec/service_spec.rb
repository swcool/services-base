require File.dirname(__FILE__) + '/../service'
require 'rspec'
require 'rack/test'

set :environment, :test

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Sinatra::Application
end

describe "service" do
  before(:each) do
    User.delete_all
  end
  
  describe "GET on /api/v1/users/:id" do
    before(:each) do
      User.create(
		:name => "guest",
	    :email => "guest@guest.com",
        :password => "strongpass",
		:bio => "rubyist")
	end

	it "should return a user by name" do
	  get '/api/v1/users/guest' do
	    last_response.should be_ok
	    attributes = JSON.parse(last_response.body)["user"]
	    attributes["name"].should == "guest"
      end
    end
    
    it "should return a user with an email" do
	  get '/api/v1/users/guest' do
	    last_response.should be_ok
        attributes = JSON.parse(last_response.body)["user"]
        attributes["email"].should == "guest@guest.com"
      end
    end

    it "should not return a user's password" do
      get '/api/v1/users/guest' do
        last_response.should be_ok
        attributes = JSON.parse(last_response.body)["user"]
        attributes.should_not have_key("password")
      end
    end

    it "should return a user with a bio" do
      get '/api/v1/users/guest' do
        last_response.should be_ok
        attributes = JSON.parse(last_response.body)["user"]
        attributes["bio"].should == "rubyist"
      end
    end

    it "should return a 404 for a user that doesn't exist" do
	  get '/api/v1/users/foo' do
        last_response.status.should == 404
      end
    end
  end

  describe "POST on /api/v1/users" do
	it "should create a user" do
	  post '/api/v1/users', {
		:name => "visitor",
		:email => "no spam",
		:password => "whatever",
		:bio 	  => "rails player"
      }.to_json
      last_response.should be_ok
      get '/api/v1/users/visitor' do
		attributes = JSON.parse(last_response.body)["user"]
		attributes["name"].should == "visitor"
	    attributes["email"].should == "no spam"
		attributes["bio"].should == "rails player"
      end
    end
  end
end
