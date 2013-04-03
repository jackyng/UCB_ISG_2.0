# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)
$root = Node.create(:name => "ISG_root")

def create_child(level=2, parent=$root)
  return if level <= 0
  5.times do |i|
    name = parent == $root ? "t#{i}" : "#{parent.name}.#{i}"
    child = Node.create(:name => name, :parent => parent)
    create_resources(child)
    create_child(level-1, child)
  end
end

def create_resources(node)
  3.times do |i|
    node.resources.create(:name => "r#{node.name[1..-1]}.#{i}", :url => "https://r#{node.name[1..-1]}.#{i}.com/")
  end
end

create_child(3, $root)

# Creating admins
User.create(:isAdmin => true, :calnetID => 192881, :email => "pathma@eecs.berkeley.edu")
User.create(:isAdmin => true, :calnetID => 869195, :email => "JackyDNg@gmail.com")
User.create(:isAdmin => true, :calnetID => 765055, :email => "minh.luong@berkeley.edu")
User.create(:isAdmin => true, :calnetID => 968746, :email => "bennyhuynh311@berkeley.edu")
User.create(:isAdmin => true, :calnetID => 948976, :email => "jimmywu126@gmail.com")

# Create normal users from the test calnet id's
ldap = Net::LDAP.new(
  host: 'ldap.berkeley.edu',
  port: 389
)
if ldap.bind
  ldap.search(
    base:          "ou=people,dc=berkeley,dc=edu",
    filter:        Net::LDAP::Filter.eq( "berkeleyEduTestIDFlag", "true" ),
    attributes:    %w[ uid ],
    return_result: true
  ).each do |entry|
    calnetID = entry.uid.first.to_i
    User.create(:calnetID => calnetID)
    # `echo #{calnetID} >> calnet_test_ids.txt` # If you want to see the whole list of test id's
  end
else
  puts "Can't connect to LDAP to get user's name"
end