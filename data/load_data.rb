require "redis"
require "json"
require 'csv'

redis = Redis.new
companies = CSV.read('./data/companylist.csv');

companies.each do |company|
  hash = {symbol: company[0], name: company[1]}
  redis.hset "companies", company[0], hash.to_json
  word = company[1].strip.downcase.tr(" ", "_")
  length = word.length - 1
  for i in 0..length do
    redis.zadd("companies:index:#{word[0..i]}", 0, company[0])
  end
end


