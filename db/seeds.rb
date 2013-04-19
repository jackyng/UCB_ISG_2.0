$root = Node.create(name: "ISG_root", description: "This is the root node")

def create_child(level=2, parent=$root)
  return if level <= 0
  3.times do |i|
    name = parent == $root ? "t#{i}" : "#{parent.name}.#{i}"
    child = Node.create(name: name, description: "This is node '#{name}'", parent: parent)
    create_resources(child)
    create_child(level-1, child)
  end
end

def create_resources(node)
  3.times do |i|
    node.resources.create(
      :name => "r#{node.name[1..-1]}.#{i}",
      :url => "https://r#{node.name[1..-1]}.#{i}.com/"
    )
  end
end

print "[progress update] creating nodes and resources......."
create_child(5, $root)
puts "done"

print "[progress update] creating admins...................."
# Creating admins
Admin.create(calnetID: 192881, email: "pathma@eecs.berkeley.edu")
Admin.create(calnetID: 869195, email: "JackyDNg@gmail.com")
Admin.create(calnetID: 765055, email: "minh.luong@berkeley.edu")
Admin.create(calnetID: 968746, email: "bennyhuynh311@berkeley.edu")
Admin.create(calnetID: 948976, email: "jimmywu126@gmail.com")
puts "done"

# Create normal users from the test calnet id's
print "[progress update] creating normal users.............."
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
  ).first(30).each do |entry|
    calnetID = entry.uid.first.to_i
    User.create(calnetID: calnetID)
    # `echo #{calnetID} >> calnet_test_ids.txt` # If you want to see the whole list of test id's
  end
else
  puts "Can't connect to LDAP to get user's name"
end
puts "done"

# Create complaints and first messages
print "[progress update] creating complaints................"
User.first(10).each do |user|
  complaint = user.complaints.create(
    user: user,
    ip_address: 4.times.map { rand(255) }.join("."),
    user_email: user.fullname.split(" ").join("_") + "@berkeley.edu",
    title: "This is complaint of '#{user.fullname}'"
  )
  complaint.messages.create(
    user: user,
    content: "This is the details of my (#{user.fullname}) problem. Please help!"
  )
end
puts "done"