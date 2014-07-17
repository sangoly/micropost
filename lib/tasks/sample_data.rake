namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
	 User.create!(name: "sangoly",
                  email: "sangoly@aliyun.com",
                  password: "123456",
                  password_confirmation: "123456",
                  admin: true)
	 99.times do |n|
	   name = Faker::Name.name
	   email = "example-#{n}@example.com"
	   password = "foobar"
	   User.create!(name: name,
	   	            email: email,
	   	            password: password,
	   	            password_confirmation: password)
	 end
	 
	 users = User.limit(6)
	 50.times do
	   content = Faker::Lorem.sentence(5)
	   users.each { |user| user.microposts.create!(content: content) }
	 end
  end
end