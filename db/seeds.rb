# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'


# Normál felhasználók létrehozása
5.times do |i|
  user = User.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: "user#{i+1}@example.com",
    password: 'password123',
    password_confirmation: 'password123'
  )
  puts "Normál felhasználó létrehozva: #{user.email}"
end

5.times do |i|
  org = Organization.create!(
    name: Faker::Company.name,
    owner_id: 1
  )
  puts "Szervezet létrehozva: #{org.name}"
end

5.times do |i|
  membership = Membership.create!(
    user_id: 1,
    organization_id: i+1,
    role: "admin"
  )
  puts "Tagfelvétel létrehozva: #{membership.user_id} - #{membership.organization_id}"
end

4.times do |i|
  5.times do |j|
    membership = Membership.create!(
      user_id: 2+i,
      organization_id: j+1,
      role: "employee"
    )
    puts "Tagfelvétel létrehozva: #{membership.user_id} - #{membership.organization_id}"
  end
end

5.times do |i|
  project = Project.create!(
    name: "Projekt#{i+1}",
    description: Faker::Markdown.emphasis,
    organization_id: 1,
    project_manager_id: i+1
  )
  puts "Projekt létrehozva: #{project.name}"
end

500.times do |i|
  task = Task.create!(
    name: Faker::Lorem.sentence,
    organization_id: 1,
    project_id: rand(1..5),
    assignee_id: rand(1..5),
    reporter_id: rand(1..5),
    description: Faker::Markdown.emphasis,
    priority: ["low", "medium", "high"].sample,
    status: ["open", "closed"].sample
  )
  puts "Feladat létrehozva: #{task.name}"
end
