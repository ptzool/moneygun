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
    description: Faker::Lorem.sentence(word_count: 10, random_words_to_add: 3),
    organization_id: 1,
    project_manager_id: i+1
  )
  puts "Projekt létrehozva: #{project.name}"
end

# Default task categories for each organization
Organization.all.each do |org|
  default_categories = [
    { name: "Fejlesztés", description: "Szoftverfejlesztési feladatok", color: "#3B82F6" },
    { name: "Tesztelés", description: "Tesztelési és QA feladatok", color: "#10B981" },
    { name: "Dokumentáció", description: "Dokumentációs feladatok", color: "#F59E0B" },
    { name: "Hibajavítás", description: "Bug fix és hibakeresési feladatok", color: "#EF4444" },
    { name: "Karbantartás", description: "Rendszerkarbantartási feladatok", color: "#8B5CF6" },
    { name: "Kutatás", description: "Kutatási és elemzési feladatok", color: "#06B6D4" }
  ]
  
  default_categories.each do |category_data|
    category = org.task_categories.find_or_create_by!(name: category_data[:name]) do |cat|
      cat.description = category_data[:description]
      cat.color = category_data[:color]
      cat.active = true
    end
    puts "Task kategória létrehozva: #{category.name} - #{org.name}"
  end
end

500.times do |i|
  # Get random category from organization
  org_categories = Organization.find(1).task_categories.active
  random_category = org_categories.sample
  
  task = Task.create!(
    name: Faker::Lorem.sentence,
    organization_id: 1,
    project_id: rand(1..5),
    assignee_id: rand(1..5),
    reporter_id: rand(1..5),
    task_category_id: random_category&.id,
    description: Faker::Lorem.sentence(word_count: 60, random_words_to_add: 3),
    planned_start_date: Faker::Date.between(from: 1.year.ago, to: 1.year.from_now),
    planned_end_date: Faker::Date.between(from: 1.year.ago, to: 1.year.from_now),
    priority: [ "low", "medium", "high" ].sample,
    status: [ "open", "closed" ].sample,
  )
  puts "Feladat létrehozva: #{task.name}"
end
