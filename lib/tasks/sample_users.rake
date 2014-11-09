namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    create_admin
    create_normal_users
    create_tasks        
  end
end

def create_admin
  User.create!( name: "Example User",
                email: "example@example.org",
                password: "foobar",
                password_confirmation: "foobar",
                admin: true,
                activated: true,
                activated_at: Time.zone.now)
end

def create_normal_users
  print "Creating users "
  39.times do |n|
    print "."
    name  = Faker::Name.name
    email = "example-#{n+1}@example.org"
    password  = "password"
    User.create!( name: name,
                  email: email,
                  password: password,
                  password_confirmation: password,
                  activated: true,
                  activated_at: Time.zone.now)
  end
  puts ""
end

def create_tasks
  print "Creating tasks "
  users = User.all.limit 6 
  4.times do
    content = Faker::Lorem.sentence 5 
    users.each do |user| 
      print "."
      list = user.add_task content: content 
      list.save!
      3.times do
        print "."
        task = list.add_task content: Faker::Lorem.sentence(10) 
        task.save!
      end
    end
  end
  puts ""
end