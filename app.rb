require 'sinatra/base'
require 'sqlite3'

CONNECTION = SQLite3::Database.new("favorite_links.sqlite3")

CONNECTION.execute <<-SQL
  CREATE TABLE IF NOT EXISTS "links" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "name" VARCHAR,
    "url" VARCHAR,
    "desc" VARCHAR
  )
SQL

class FavoriteLinks < Sinatra::Base

  @detailed = false

  get "/" do
    @title = "Ten Most Recent "
    @results = CONNECTION.execute("SELECT name, id FROM links ORDER BY id DESC LIMIT 20")
    erb :links
  end

  get "/links" do
    @title = "All "
    @results = CONNECTION.execute("SELECT name, id FROM links")
    erb :links
  end

  post "/links" do
    name = params[:name]
    url = params[:url]
    desc = params[:desc]
    CONNECTION.execute("INSERT INTO links (name, url, desc) VALUES (?, ?, ?)", [name, url, desc])

    redirect "/links"
  end

  get "/links/:id" do
    @detailed = true
    id = params[:id]
    @title = "Details of Link ##{id} in "
    @results = CONNECTION.execute("SELECT name, url, desc FROM links WHERE id = (?)", [id])
    erb :links
  end

  get "/css/style.css" do
    File.read(File.join('public', 'css/style.css'))
  end

end
