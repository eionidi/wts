# wts
web-testing sandbox project

## Requirements
* Ruby 2.3.0
* gemset wts

## Install
* clone repo
* cd to repo's directory
* exec `bundle install`
* exec `rake db:create`

## After update
* cd to repo's directory
* exec `bundle install`
* exec `rake db:migrate`

## Run app
* cd to repo's directory
* exec `rails c` for accessing to console
* exec `rails s` for starting server (http://localhost:3000)

## Run test
* cd to repo's directory
* exec `RAILS_ENV=test rake db:reset`
* exec `rspec` or `rspec path/to/file`
