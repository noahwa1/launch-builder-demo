class SetupController < ApplicationController
  def create_demo_accounts
    if User.exists?(email: 'admin@launch.com')
      redirect_to new_user_session_path, notice: 'Demo accounts already exist.'
      return
    end

    publisher = Publisher.find_or_create_by!(name: 'Launch Publishing') { |p| p.label = 'launch' }

    author = Author.find_or_create_by!(first_name: 'Sarah', last_name: 'Mitchell') do |a|
      a.description = 'Bestselling author of contemporary fiction and memoir.'
      a.status = :active
    end

    User.create!(
      email: 'admin@launch.com',
      password: 'password',
      password_confirmation: 'password',
      first_name: 'Admin',
      last_name: 'User',
      role: :admin
    )

    User.find_or_create_by!(email: 'creator@launch.com') do |u|
      u.password = 'password'
      u.password_confirmation = 'password'
      u.first_name = 'Sarah'
      u.last_name = 'Mitchell'
      u.role = :creator
      u.account = author
    end

    Book.find_or_create_by!(isbn: '978-1-234567-01-0') do |b|
      b.title = 'The Last Garden'
      b.description = 'A sweeping novel about family, legacy, and the gardens that bind us across generations.'
      b.release_date = Date.new(2024, 3, 15)
      b.author = author
      b.publisher = publisher
    end

    Book.find_or_create_by!(isbn: '978-1-234567-02-7') do |b|
      b.title = 'Rivers of Light'
      b.description = 'A luminous memoir tracing a journey through loss and rediscovery.'
      b.release_date = Date.new(2025, 9, 1)
      b.author = author
      b.publisher = publisher
    end

    redirect_to new_user_session_path, notice: 'Demo accounts created! Admin: admin@launch.com / password, Creator: creator@launch.com / password'
  end

  def seed_buyers
    campaign = Campaign.first
    unless campaign
      redirect_to root_path, alert: 'No campaigns found. Run /setup first and create a campaign.'
      return
    end

    landing_page = campaign.landing_page
    unless landing_page
      redirect_to root_path, alert: 'Campaign has no landing page.'
      return
    end

    # Enable personal videos on this campaign
    campaign.update!(personal_videos_enabled: true)

    buyers = [
      { name: 'Sarah Johnson',     city: 'Portland',      state: 'OR', email: 'sarah.johnson@example.com' },
      { name: 'Mike Chen',         city: 'San Francisco',  state: 'CA', email: 'mike.chen@example.com' },
      { name: 'Lisa Rodriguez',    city: 'Austin',         state: 'TX', email: 'lisa.rodriguez@example.com' },
      { name: 'David Park',        city: 'Seattle',        state: 'WA', email: 'david.park@example.com' },
      { name: 'Amy Wilson',        city: 'Denver',         state: 'CO', email: 'amy.wilson@example.com' },
      { name: 'Tom Brown',         city: 'Nashville',      state: 'TN', email: 'tom.brown@example.com' },
      { name: 'Rachel Kim',        city: 'Chicago',        state: 'IL', email: 'rachel.kim@example.com' },
      { name: 'James Martinez',    city: 'Miami',          state: 'FL', email: 'james.martinez@example.com' },
      { name: 'Emily Davis',       city: 'Brooklyn',       state: 'NY', email: 'emily.davis@example.com' },
      { name: 'Chris Taylor',      city: 'Los Angeles',    state: 'CA', email: 'chris.taylor@example.com' },
      { name: 'Jennifer White',    city: 'Phoenix',        state: 'AZ', email: 'jennifer.white@example.com' },
      { name: 'Robert Garcia',     city: 'Houston',        state: 'TX', email: 'robert.garcia@example.com' },
      { name: 'Nicole Thompson',   city: 'Philadelphia',   state: 'PA', email: 'nicole.thompson@example.com' },
      { name: 'Kevin Lee',         city: 'Boston',         state: 'MA', email: 'kevin.lee@example.com' },
      { name: 'Amanda Clark',      city: 'Atlanta',        state: 'GA', email: 'amanda.clark@example.com' },
      { name: 'Brian Hall',        city: 'Minneapolis',    state: 'MN', email: 'brian.hall@example.com' },
      { name: 'Megan Wright',      city: 'Charlotte',      state: 'NC', email: 'megan.wright@example.com' },
      { name: 'Daniel Scott',      city: 'Salt Lake City', state: 'UT', email: 'daniel.scott@example.com' },
      { name: 'Samantha Green',    city: 'San Diego',      state: 'CA', email: 'samantha.green@example.com' },
      { name: 'Matthew Adams',     city: 'Columbus',       state: 'OH', email: 'matthew.adams@example.com' },
    ]

    created = 0
    buyers.each do |buyer|
      next if landing_page.page_submissions.exists?(email: buyer[:email])
      landing_page.page_submissions.create!(
        form_type: 'receipt',
        email: buyer[:email],
        data: { 'name' => buyer[:name], 'city' => buyer[:city], 'state' => buyer[:state] },
        status: :new_submission
      )
      created += 1
    end

    redirect_to manage_campaign_path(campaign), notice: "Seeded #{created} test buyers. Personal Videos enabled. Open the recorder and switch to Queue mode to test."
  end
end
