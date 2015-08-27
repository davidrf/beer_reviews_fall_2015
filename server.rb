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

def beer_all
  db_connection do |conn|
    sql_query = "SELECT * FROM beers"
    conn.exec(sql_query)
  end
end

def beer_save(params)
  unless params["name"].empty?
    db_connection do |conn|
      sql_query = "INSERT INTO beers (name) VALUES ($1)"
      data = [params["name"]]
      conn.exec_params(sql_query, data)
    end
  end
end

def beer_find(id)
  db_connection do |conn|
    sql_query = "SELECT * FROM beers WHERE id = $1"
    data = [id]
    conn.exec_params(sql_query, data).first
  end
end

def beer_reviews(id)
  db_connection do |conn|
    sql_query = "SELECT beers.*, reviews.* FROM beers
    JOIN reviews ON beers.id = reviews.beer_id
    WHERE beers.id = $1"
    data = [id]
    conn.exec_params(sql_query, data)
  end
end

def review_save(params)
  db_connection do |conn|
    sql_query = "INSERT INTO reviews (body, beer_id) VALUES ($1, $2)"
    data = [params["body"], params["id"]]
    conn.exec_params(sql_query, data)
  end
end

get "/" do
  redirect "/beers"
end

get "/beers" do
  beers = beer_all
  erb :'beers/index', locals: { beers: beers }
end

post "/beers" do
  beer_save(params)
  redirect "/beers"
end

get "/beers/:id" do
  beer = beer_find(params[:id])
  reviews = beer_reviews(params[:id])
  erb :'beers/show', locals: { beer: beer, reviews: reviews}
end

post "/beers/:id/reviews" do
  review_save(params)
  redirect "/beers/" + params[:id]
end
