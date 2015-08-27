require 'pry'
require 'sinatra'
require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: "beer_reviews")
    yield connection
  ensure
    connection.close
  end
end

class Beer
  attr_accessor :id, :name
  def initialize(id=nil, name)
    @id = id
    @name = name
  end

  def self.all
    beers = nil
    db_connection do |conn|
      sql_query = "SELECT * FROM beers"
      beers = conn.exec(sql_query)
    end
    beers.map { |beer| Beer.new(beer["id"], beer["name"]) }
  end

  def self.find(id)
    beer = nil
    db_connection do |conn|
      sql_query = "SELECT * FROM beers WHERE id = $1"
      data = [id]
      beer = conn.exec_params(sql_query, data).first
    end
    Beer.new(beer["id"], beer["name"])
  end

  def save
    unless name.empty?
      db_connection do |conn|
        sql_query = "INSERT INTO beers (name) VALUES ($1)"
        data = [name]
        conn.exec_params(sql_query, data)
      end
    end
  end

  def reviews
    reviews = nil
    db_connection do |conn|
      sql_query = "SELECT beers.*, reviews.* FROM beers
      JOIN reviews ON beers.id = reviews.beer_id
      WHERE beers.id = $1"
      data = [id]
      reviews = conn.exec_params(sql_query, data)
    end
    reviews.map { |review| Review.new(review["id"], review["body"], review["beer_id"]) }
  end
end

class Review
  attr_accessor :id, :body, :beer_id
  def initialize(id=nil, body, beer_id)
    @id = id
    @body = body
    @beer_id = beer_id
  end

  def save
    db_connection do |conn|
      sql_query = "INSERT INTO reviews (body, beer_id) VALUES ($1, $2)"
      data = [body, beer_id]
      conn.exec_params(sql_query, data)
    end
  end
end

get "/" do
  redirect "/beers"
end

get "/beers" do
  beers = Beer.all
  erb :'beers/index', locals: { beers: beers }
end

post "/beers" do
  beer = Beer.new(params[:name])
  beer.save
  redirect "/beers"
end

get "/beers/:id" do
  beer = Beer.find(params[:id])
  reviews = beer.reviews
  erb :'beers/show', locals: { beer: beer, reviews: reviews}
end

post "/beers/:beer_id/reviews" do
  review = Review.new(params[:body], params[:beer_id])
  review.save
  redirect "/beers/" + review.beer_id
end
