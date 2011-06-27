require 'rubygems'
require 'bundler/setup'

require 'omniauth'
require 'openid/store/filesystem'
  
require 'active_record'
require 'sinatra'
require "#{File.dirname(__FILE__)}/models/user"

  use Rack::Session::Cookie
  use OmniAuth::Builder do
    provider :open_id, OpenID::Store::Filesystem.new('/tmp')
    provider :facebook, '140124176062694', '3a58f182a8e0115df8814a1c63583960',
             { :client_options => {
                 :ssl => {
                   :ca_file => './config/ca-bundle.crt'
                 }
               }
             }
      
    provider :twitter, 'UUVVbEaBjm0GrRkG8Mesg', 'Qxi86s8op34KQDokQMOWvjYVJmvP72JDLXur91iiI'
    provider :github, '82e688018a15aff0c002', '38cfe0c37a1fbd4c30c02726fcd57fa0dab68c5f',
                { :client_options => {
                     :ssl => {
                       :ca_file => './config/ca-bundle.crt'
                     }
                   }
                 }
    provider :tsina, '92783654', 'b8e8af30acaec274d67b119030d9e881'
  end

  get '/' do
    <<-HTML
    "Service Oriented Design Implementation! It's #{Time.now} at the server. <br/><br/>
    <a href='./api/v1/users/tester'>API: tester information in JSON format</a>" <br/><br/>
    
    <a href='/auth/twitter'>Sign in with Twitter</a>&nbsp;&nbsp;
    <a href='/auth/facebook'>Sign in with Facebook</a><br/>
    <a href='/auth/tsina'>Sign in with Sina Weibo</a>&nbsp;&nbsp;
    <a href='/auth/github'>Sign in with Github</a>

    <form action='/auth/open_id' method='post'>
      <input type='text' name='identifier'/>
      <input type='submit' value='Sign in with OpenID'/>
    </form>
    HTML
  end
  
  get '/auth/:name/callback' do
  "Hellow World"
  
    auth = request.env['omniauth.auth']
    auth.to_json
  end

  post '/auth/:name/callback' do
    auth = request.env['omniauth.auth']
    # do whatever you want with the information!
  end

#setting up the environment
env_index = ARGV.index("-e")
env_arg = ARGV[env_index + 1] if env_index
env = env_arg || ENV["SINATRA_ENV"] || "production" || "development"
databases = YAML.load_file("config/database.yml")
ActiveRecord::Base.establish_connection(databases[env])


# puts "create a user to test" 
User.destroy_all 
User.create(:name => "tester", :email =>
"tester@example.net", :bio => "rubyist")


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

# update an existing user
put '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  if user
    begin
      if user.update_attributes(JSON.parse(request.body.read))
		user.to_json
	  else
		error 400, user.errors.to_json
	  end
	rescue => e
	  error 400, e.message.to_json
	end
  else
	error 404, {:error => "user not found"}.to_json
  end
end

# destroy an existing user
delete '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  if user
	user.destroy
	user.to_json
  else
	error 404, {:error => "user not found"}.to_json
  end
end

# verify a user name and password
post '/api/v1/users/:name/sessions' do
  begin
	attributes = JSON.parse(request.body.read)
 	user = User.find_by_name_and_password(
	  params[:name], attributes["password"])
    if user
	  user.to_json
	else
	  error 400, {:error => "invalid login credentials"}.to_json
	end
  rescue => e
	error 400, e.message.to_json
  end
end
