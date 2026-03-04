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
end
