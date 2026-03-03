source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

gem 'rails', '~> 7.0'
gem 'puma', '~> 6.0'
gem 'sass-rails', '~> 6.0'
gem 'terser'
gem 'jbuilder', '~> 2.5'
gem 'sprockets-rails'

# Auth
gem 'devise', '~> 4.9'

# Forms
gem 'simple_form', '~> 5.3'

# File uploads
gem 'carrierwave', '~> 3.0'

# PDF generation
gem 'wicked_pdf', '~> 2.1'
gem 'wkhtmltopdf-binary'

# Pagination
gem 'kaminari', '~> 1.2'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'sqlite3', '~> 1.4'
end

group :development do
  gem 'web-console', '>= 4.2'
  gem 'listen'
  gem 'spring'
  gem 'letter_opener'
end

group :production do
  gem 'pg'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
