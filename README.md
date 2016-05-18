# wts
web-testing sandbox project

## Requirements
* Ruby 2.3.0
* gemset wts
* phantomsjs

## Phantomjs
* download (http://phantomjs.org/download.html)
* extract and move to PATH (`sudo mv phantomjs /usr/local/bin/phantomjs` for Ubuntu)

## Install
* clone repo
* cd to repo's directory
* exec `bundle install`
* exec `rake db:create`

## After each update
* cd to repo's directory
* exec `bundle install`
* exec `rake db:migrate`
* exec `RAILS_ENV=test rake db:reset`

## Run app
* cd to repo's directory
* exec `rails c` for accessing to console
* exec `rails s` for starting server (http://localhost:3000)

## Run test
* cd to repo's directory
* exec `rspec` or `rspec path/to/file`
