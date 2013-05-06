$root = Node.create(name: "ISG_root", description: "This is the root node")

def create_child(level=2, parent=$root)
  return if level <= 0
  2.times do |i|
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
# create_child(3, $root)
hardware = Node.create(name: "Hardware", parent: $root, description: "Got hardware problems?")
software = Node.create(name: "Software", parent: $root, description: "Got software problems?")
class_account = Node.create(name: "Class Account", parent: $root, description: "Class account info")
servers = Node.create(name: "Servers", parent: $root, description: "Server problems?")
labs = Node.create(name: "Labs", parent: $root, description: "Lab problems?")

licenses = Node.create(name: "Licenses", parent: software, description: "License info")
licenses.resources.create(name: "Eclipse", url: "http://inst.eecs.berkeley.edu/cgi-bin/pub.cgi?file=eclipse.help")
licenses.resources.create(name: "Microsoft", url: "http://msdnaa.eecs.berkeley.edu/")
os = Node.create(name: "Operating Systems", parent: software, description: "OS info")
os.resources.create(name: "Windows", url: "http://inst.eecs.berkeley.edu/cgi-bin/pub.cgi?file=microsoft.help")
os.resources.create(name: "UNIX", url: "http://inst.eecs.berkeley.edu/cgi-bin/pub.cgi?file=software.help")

keyboards = Node.create(name: "Keyboards", parent: hardware, description: "Keyboards problems")
mice = Node.create(name: "Mice", parent: hardware, description: "Mice problems")
monitors = Node.create(name: "Monitors", parent: hardware, description: "Monitors problems")
esg_equiments = Node.create(name: "ESG Equipments", parent: hardware, description: "Problems with ESG (lab) equiments?")

cs = Node.create(name: "CS classes", parent: class_account, description: "List of all CS classes")
ee = Node.create(name: "EE classes", parent: class_account, description: "List of all EE classes")
cs_classes = ["3S", "9A", "9B", "9C", "9D", "9E", "9F", "9G", "9H", "47A", "47B", "47C", "61A", "61B", "61C", 98, 150, 152, 160, 161, 162, 164, 169, 170, 172, 174, 184, 186, 188, 192, 194, 198]
ee_classes = ["20n", 40, 42, 43, 98, 100, 105, 117, 119, 120, 122, 126, 130, 134, "137B", 140, 141, 142, 143, "C145", 149, 192, 194, 197, 198]
cs_classes.each do |n|
  Node.create(name: "CS #{n}", parent: cs, description: "CS #{n} website")
end
ee_classes.each do |n|
  Node.create(name: "EE #{n}", parent: ee, description: "EE #{n} website")
end

iserver = Node.create(name: "iserver", parent: servers, description: "iserver info")
bcom = Node.create(name: "bcom", parent: servers, description: "bcom info")
icluster = Node.create(name: "icluster", parent: servers, description: "icluster info")
star = Node.create(name: "star", parent: servers, description: "star server info")
nova = Node.create(name: "nova", parent: servers, description: "nova server info")

power_failure = Node.create(name: "Power failure", parent: labs, description: "Power failure problems?")
projectors = Node.create(name: "Projectors", parent: labs, description: "Projectors problems?")
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



# Create announcements
print "[progress update] creating announcements............."
Admin.all.each do |admin|
  2.times do |i|
    admin.announcements.create(
      title: "#{admin.fullname} announcement ##{i+1}",
      description: "This is the announcement ##{i+1} of admin #{admin.fullname}",
      shown_on_homepage: i.odd?
    )
  end
end
puts "done"
