# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.create(username: 'Speed', email: 'speed.the.bboy@gmail.com', password: 'test1234')
#user.skip_confirmation!
user.save!

User.create(username: 'IceDragon', email: 'mistdragon100@gmail.com', password: 'creampuff').save!