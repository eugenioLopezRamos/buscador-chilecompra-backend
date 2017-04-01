# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
* install Redis (ubuntu -> sudo apt-get install redis-server)



** TODO **

- Need to return error messages in case of missing params or w/e when querying the API (ex. failed validation would return "Invalid parameter(s)")
- Need to translate error messages from devise_token_auth (and rails)
- I can probably delete most of the application_helper by moving that to simple json files (since right now that looks weird to me)
- Need to make the user confirmable, so adding confirm_success_url