puts "Seeding Creators Portal..."

# Publisher
publisher = Publisher.create!(name: 'Launch Publishing', label: 'launch')
puts "  Created publisher: #{publisher.name}"

# Author
author = Author.create!(
  first_name: 'Sarah',
  last_name: 'Mitchell',
  description: 'Bestselling author of contemporary fiction and memoir.',
  status: :active
)
puts "  Created author: #{author.full_name}"

# Admin user
admin = User.create!(
  email: 'admin@launch.com',
  password: 'password',
  password_confirmation: 'password',
  first_name: 'Admin',
  last_name: 'User',
  role: :admin
)
puts "  Created admin: #{admin.email}"

# Creator user (linked to author)
creator = User.create!(
  email: 'creator@launch.com',
  password: 'password',
  password_confirmation: 'password',
  first_name: 'Sarah',
  last_name: 'Mitchell',
  role: :creator,
  account: author
)
puts "  Created creator: #{creator.email} (linked to #{author.full_name})"

# Books
book1 = Book.create!(
  title: 'The Last Garden',
  isbn: '978-1-234567-01-0',
  description: 'A sweeping novel about family, legacy, and the gardens that bind us across generations.',
  release_date: Date.new(2024, 3, 15),
  author: author,
  publisher: publisher
)

book2 = Book.create!(
  title: 'Rivers of Light',
  isbn: '978-1-234567-02-7',
  description: 'A luminous memoir tracing a journey through loss and rediscovery.',
  release_date: Date.new(2025, 9, 1),
  author: author,
  publisher: publisher
)
puts "  Created #{Book.count} books"

# Submissions
sub_draft = Submission.create!(
  author: author,
  submitted_by: creator.id,
  title: 'Echoes of Tomorrow',
  isbn: '978-1-234567-03-4',
  description: 'A speculative novel about time, memory, and second chances.',
  genre: 'Fiction',
  release_date: Date.new(2026, 6, 1),
  status: :draft
)

sub_submitted = Submission.create!(
  author: author,
  submitted_by: creator.id,
  title: 'The Baker\'s Daughter',
  isbn: '978-1-234567-04-1',
  description: 'Historical fiction set in 1940s Paris, following a young woman who uses her family bakery as a front for the Resistance.',
  genre: 'Fiction',
  release_date: Date.new(2026, 9, 15),
  status: :submitted,
  submitted_at: 3.days.ago
)

sub_approved = Submission.create!(
  author: author,
  submitted_by: creator.id,
  title: 'Finding Home',
  description: 'A collection of essays about belonging, displacement, and building a life in unexpected places.',
  genre: 'Non-Fiction',
  release_date: Date.new(2025, 11, 1),
  status: :approved,
  submitted_at: 2.weeks.ago,
  reviewed_at: 1.week.ago,
  reviewed_by: admin.id
)
puts "  Created #{Submission.count} submissions (draft, submitted, approved)"

# Royalty rate
rate = RoyaltyRate.create!(
  author: author,
  rate: 0.15,
  effective_from: Date.new(2024, 1, 1)
)
puts "  Created royalty rate: #{rate.percentage}%"

# Royalty payment with statements
payment = RoyaltyPayment.create!(
  author: author,
  amount: 4250.00,
  currency: 'USD',
  status: :paid,
  period_start: Date.new(2025, 7, 1),
  period_end: Date.new(2025, 12, 31),
  reference: 'CHK-2026-0142',
  paid_at: 2.weeks.ago,
  notes: 'H2 2025 royalty payment'
)

RoyaltyStatement.create!(
  royalty_payment: payment,
  book: book1,
  units_sold: 1840,
  gross_revenue: 22080.00,
  royalty_rate: 0.15,
  royalty_amount: 3312.00
)

RoyaltyStatement.create!(
  royalty_payment: payment,
  book: book2,
  units_sold: 520,
  gross_revenue: 6253.00,
  royalty_rate: 0.15,
  royalty_amount: 938.00
)

# Pending payment
RoyaltyPayment.create!(
  author: author,
  amount: 1875.50,
  currency: 'USD',
  status: :pending,
  period_start: Date.new(2026, 1, 1),
  period_end: Date.new(2026, 3, 31),
  notes: 'Q1 2026 royalty payment — pending review'
)
puts "  Created #{RoyaltyPayment.count} royalty payments with #{RoyaltyStatement.count} statements"

# Messages
PortalMessage.create!(
  sender: creator,
  thread_owner: creator,
  body: 'Hi! I have a question about the timeline for my next submission. When would be the ideal window to submit for a Fall 2026 release?',
  created_at: 5.days.ago
)

PortalMessage.create!(
  sender: admin,
  thread_owner: creator,
  body: 'Great question, Sarah! For a Fall 2026 release, we\'d want the manuscript submitted by June 2026 at the latest. That gives us time for editorial review, design, and production. Feel free to submit your draft anytime before then.',
  created_at: 4.days.ago,
  read_at: 3.days.ago
)
puts "  Created #{PortalMessage.count} messages"

puts "\nDone! Login at:"
puts "  Creator: http://localhost:3000/users/sign_in (creator@launch.com / password)"
puts "  Admin:   http://localhost:3000/users/sign_in (admin@launch.com / password)"
