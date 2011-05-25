require File.dirname(__FILE__) + '/../client'

# NOTE: to run these specs you must have the service running locally. Do like this:
# ruby service.rb -e test -p 3000 

# Also note that after a single run of the tests the server must be restarted to reset
# the database. We could change this by deleting all users in the test setup.
describe "client" do
  before(:all) do
    User.base_uri = "http://localhost:3000"
    
    User.destroy("john")
    User.destroy("david")
    User.destroy("bruce")
    
    User.create(
      :name => "john",
      :email => "john@example.net",
      :password => "strongpass",
      :bio => "rubyist")
    User.create(
      :name => "david",
      :email => "david@sanjose.usa",
      :password => "strongpass",
      :bio => "rubyist")
  end

  it "should get a user" do
    user = User.find_by_name("john")
    user["name"].should  == "john"
    user["email"].should == "john@example.net"
    user["bio"].should   == "rubyist"
  end

  it "should return nil for a user not found" do
    User.find_by_name("gosling").should be_nil
  end

  it "should create a user" do
    user = User.create({
      :name => "bruce",
      :email => "bruce@sanjose.usa",
      :password => "whatev"})
    User.find_by_name("bruce")["email"].should == "bruce@sanjose.usa"
  end

  it "should update a user" do
    user = User.update("john", :bio => "rubyist and author")
    user["name"].should == "john"
    user["bio"].should  == "rubyist and author"
    User.find_by_name("john")["bio"] == "rubyist and author"
  end

  it "should destroy a user" do
    User.destroy("david").should == true
    User.find_by_name("david").should be_nil
  end

  it "should verify login credentials" do
    user = User.login("john", "strongpass")
    user["name"].should == "john"
  end

  it "should return nil with invalid credentials" do
    User.login("john", "wrongpassword").should be_nil
  end
end
