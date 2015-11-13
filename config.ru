require 'bundler'
Bundler.require


require './app.rb'

DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://admin:admin@127.0.0.1:5432/test')
require './models.rb'
DB.disconnect

run ScoutingApp