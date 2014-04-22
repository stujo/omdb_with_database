require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'

require 'omdbgateway'


require_relative 'lib/movie_db'


movieDB = MovieDb.new

# A setup step to get rspec tests running.
configure do
  root = File.expand_path(File.dirname(__FILE__))
  set :views, File.join(root, 'views')
end

get '/' do
  @q = params[:q]
  if @q
    @movies = movieDB.search @q
  end
  erb :index
end

get '/movie/:movie_id' do
  @movie_id = params[:movie_id]
  if @movie_id
    @movie = movieDB.find_by_id @movie_id
  end
  erb :movie
end

get '/import' do
  redirect "/"
end

post '/import' do
  @q = params[:q]

  if @q
    movies = OMDBGateway.gateway.free_search(@q).body
    movies.each do |movie|
      full_movie = OMDBGateway.gateway.find_by_id(movie['imdbID'] ).body
      movieDB.upsertMovie(full_movie['Title'], full_movie['Year'], full_movie['Plot'])
    end
  end
  redirect "/?q=#{URI.escape(@q)}"
end
