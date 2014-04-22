require 'pg'

class MovieDb

  TABLE_NAME = 'movies'

  def search(search_term)
    if search_term.length > 0
      dbexec do |connection|
#        connection.exec_params('select id, title, year from movies where title like $1', ['%' + search_term + '%'])
        connection.exec_params('SELECT id, title, year FROM movies WHERE to_tsvector(title || \' \' || plot) @@ to_tsquery($1)', ['%' + search_term + '%'])
     end
    else
      nil
    end
  end

  def find_by_id(id)
    res = dbexec do |connection|
      connection.exec_params('select id, title, plot, year from movies where id=$1', [id.to_i])
    end
    res[0]
  end


  def upsertMovie(title, year, plot)

    movie = dbexec do |connection|
      connection.exec_params('select id, title, year, plot from movies where title = $1', [title])
    end

    if movie.ntuples == 0
      dbexec do |connection|
        connection.exec_params('insert into movies (title, year, plot) VALUES ($1,$2,$3)', [title, year.to_i, plot])
      end
    end

  end



  def dbexec &block
    result = nil
    connection = PGconn.new(:host => "localhost", :dbname => TABLE_NAME)

    begin
      result = yield connection
    ensure
      connection.close
    end
    result
  end
  #
  #
  # def create_db
  #   dbexec do |connection|
  #     connection.exec %q{
  #     CREATE TABLE movies (
  #       id SERIAL PRIMARY KEY,
  #       title varchar(255),
  #       year varchar(255),
  #       plot text,
  #       genre varchar(255)
  #     );
  #     }
  #   end
  # end
  #
  # def seed_db
  #   movies = [["Glitter", "2001"],
  #             ["Titanic", "1997"],
  #             ["Sharknado", "2013"],
  #             ["Jaws", "1975"]
  #   ]
  #
  #   dbexec do |connection|
  #     movies.each do |p|
  #       connection.exec_params("INSERT INTO movies (title, year) VALUES ($1, $2);", p)
  #     end
  #   end
  # end
end