require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'sinatra'
require "#{File.dirname(__FILE__)}/models/user"
get '/' do
    'Hello world!'
end

=begin

#setting up the environment
env_index = ARGV.index("-e")
env_arg = ARGV[env_index + 1] if env_index
env = env_arg || ENV["SINATRA_ENV"] || "production" || "development"
databases = YAML.load_file("config/database.yml")
ActiveRecord::Base.establish_connection(databases[env])

get '/' do
    'Hello world!'
end

# HTTP entry points
# get a user by name
get '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  if user
    user.to_json
  else
	error 404, {:error => "user not found"}.to_json
  end
end

# create a new user
post '/api/v1/users' do 
  begin
	user = User.create(JSON.parse(request.body.read))
	if user.valid?
	  user.to_json
    else
	  error 400, ""
	end
  rescue => e
	error 400, e.message.to_json
  end
end
=end
