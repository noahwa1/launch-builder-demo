puts "Seeding Creators Portal..."

# Publisher
publisher = Publisher.find_or_create_by!(name: 'Launch Publishing') do |p|
  p.label = 'launch'
end
puts "  Publisher: #{publisher.name}"

# Author
author = Author.find_or_create_by!(first_name: 'Sarah', last_name: 'Mitchell') do |a|
  a.description = 'Bestselling author of contemporary fiction and memoir.'
  a.status = :active
end
puts "  Author: #{author.full_name}"

# Admin user
admin = User.find_or_create_by!(email: 'admin@launch.com') do |u|
  u.password = 'password'
  u.password_confirmation = 'password'
  u.first_name = 'Admin'
  u.last_name = 'User'
  u.role = :admin
end
puts "  Admin: #{admin.email}"

# Creator user (linked to author)
creator = User.find_or_create_by!(email: 'creator@launch.com') do |u|
  u.password = 'password'
  u.password_confirmation = 'password'
  u.first_name = 'Sarah'
  u.last_name = 'Mitchell'
  u.role = :creator
  u.account = author
end
puts "  Creator: #{creator.email}"

# Books
book1 = Book.find_or_create_by!(isbn: '978-1-234567-01-0') do |b|
  b.title = 'The Last Garden'
  b.description = 'A sweeping novel about family, legacy, and the gardens that bind us across generations.'
  b.release_date = Date.new(2024, 3, 15)
  b.author = author
  b.publisher = publisher
end

book2 = Book.find_or_create_by!(isbn: '978-1-234567-02-7') do |b|
  b.title = 'Rivers of Light'
  b.description = 'A luminous memoir tracing a journey through loss and rediscovery.'
  b.release_date = Date.new(2025, 9, 1)
  b.author = author
  b.publisher = publisher
end
puts "  Books: #{Book.count}"

# Submissions
Submission.find_or_create_by!(isbn: '978-1-234567-03-4') do |s|
  s.author = author
  s.submitted_by = creator.id
  s.title = 'Echoes of Tomorrow'
  s.description = 'A speculative novel about time, memory, and second chances.'
  s.genre = 'Fiction'
  s.release_date = Date.new(2026, 6, 1)
  s.status = :draft
end

Submission.find_or_create_by!(isbn: '978-1-234567-04-1') do |s|
  s.author = author
  s.submitted_by = creator.id
  s.title = "The Baker's Daughter"
  s.description = 'Historical fiction set in 1940s Paris, following a young woman who uses her family bakery as a front for the Resistance.'
  s.genre = 'Fiction'
  s.release_date = Date.new(2026, 9, 15)
  s.status = :submitted
  s.submitted_at = 3.days.ago
end

Submission.find_or_create_by!(title: 'Finding Home', author: author) do |s|
  s.submitted_by = creator.id
  s.description = 'A collection of essays about belonging, displacement, and building a life in unexpected places.'
  s.genre = 'Non-Fiction'
  s.release_date = Date.new(2025, 11, 1)
  s.status = :approved
  s.submitted_at = 2.weeks.ago
  s.reviewed_at = 1.week.ago
  s.reviewed_by = admin.id
end
puts "  Submissions: #{Submission.count}"

# Royalty rate
rate = RoyaltyRate.find_or_create_by!(author: author, effective_from: Date.new(2024, 1, 1)) do |r|
  r.rate = 0.15
end
puts "  Royalty rate: #{rate.percentage}%"

# Royalty payments
payment = RoyaltyPayment.find_or_create_by!(reference: 'CHK-2026-0142') do |p|
  p.author = author
  p.amount = 4250.00
  p.currency = 'USD'
  p.status = :paid
  p.period_start = Date.new(2025, 7, 1)
  p.period_end = Date.new(2025, 12, 31)
  p.paid_at = 2.weeks.ago
  p.notes = 'H2 2025 royalty payment'
end

RoyaltyStatement.find_or_create_by!(royalty_payment: payment, book: book1) do |s|
  s.units_sold = 1840
  s.gross_revenue = 22080.00
  s.royalty_rate = 0.15
  s.royalty_amount = 3312.00
end

RoyaltyStatement.find_or_create_by!(royalty_payment: payment, book: book2) do |s|
  s.units_sold = 520
  s.gross_revenue = 6253.00
  s.royalty_rate = 0.15
  s.royalty_amount = 938.00
end

RoyaltyPayment.find_or_create_by!(author: author, period_start: Date.new(2026, 1, 1), period_end: Date.new(2026, 3, 31)) do |p|
  p.amount = 1875.50
  p.currency = 'USD'
  p.status = :pending
  p.notes = 'Q1 2026 royalty payment — pending review'
end
puts "  Royalty payments: #{RoyaltyPayment.count}, statements: #{RoyaltyStatement.count}"

# Messages
PortalMessage.find_or_create_by!(sender: creator, thread_owner: creator, created_at: 5.days.ago) do |m|
  m.body = 'Hi! I have a question about the timeline for my next submission. When would be the ideal window to submit for a Fall 2026 release?'
end

PortalMessage.find_or_create_by!(sender: admin, thread_owner: creator, created_at: 4.days.ago) do |m|
  m.body = "Great question, Sarah! For a Fall 2026 release, we'd want the manuscript submitted by June 2026 at the latest. That gives us time for editorial review, design, and production. Feel free to submit your draft anytime before then."
  m.read_at = 3.days.ago
end
puts "  Messages: #{PortalMessage.count}"

puts "\nDone!"
