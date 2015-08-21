require 'yahoo-finance'
require 'sinatra/json'
require 'redis'

module Routes
  class Company < Sinatra::Base
    redis = Redis.new

    before do
      content_type :json
    end

    get '/search' do
      result = []
      count = 0
      if params[:query]
        word = params[:query].strip.downcase.tr(" ", "_")
        symbols = redis.zrange("companies:index:#{word}", 0, 20)
        if symbols.any?
          companies = redis.hmget("companies", symbols)
          companies = redis.hmget("companies", symbols).map {|e| JSON.parse(e) }
          puts companies
          companies.sort_by { |company| company[:name] }.to_json
        else
          [].to_json
        end
      end

    end

    # todo: catch yahoo exceptions and return to client
    get '/history' do
      yahoo_client = YahooFinance::Client.new
      query = params[:query]
      if query
        data = yahoo_client.historical_quotes(query, { 
          start_date: Date.today - 30,
          end_date: Date.today
        })

        averaged = data.map do |datum|
          {
            trade_date: datum.trade_date,
            average: ((datum.low.to_f + datum.high.to_f + datum.open.to_f + datum.close.to_f) / 4).round(6)
          }
        end

        averaged.to_json
      end
    end



  end
end
