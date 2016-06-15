# wts
web-testing sandbox project

## Requirements
* Ruby 2.3.0
* gemset wts
* phantomsjs
* ImageMagick (see https://github.com/thoughtbot/paperclip/tree/v4.3.6#image-processor)

## Phantomjs
* download (http://phantomjs.org/download.html)
* extract and move to PATH (`sudo mv phantomjs /usr/local/bin/phantomjs` for Ubuntu)

## Install
* clone repo
* cd to repo's directory
* exec `bundle install`
* exec `rake db:create`
* create directory `public/paperclip/post_image/` in repo's directory

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
