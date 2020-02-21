require 'pg'
require 'dotenv/load'


class Repository

  def connect
    conn = PG::connect(host: ENV['hostname'], user: ENV['username'], password: ENV['password'], dbname: ENV['database'], port: ENV['port']) 
    conn.exec("BEGIN")
    return conn
  end

  def rollback(conn)
    conn.exec("ROLLBACK")
    conn.close
  end

  def commit(conn)
    conn.exec("COMMIT")
    conn.close
  end

  def dropTables(conn)
    conn.exec('delete from "friend"')
    conn.exec('delete from "user"')
  end

  def saveUser(conn,users)
    users.each do |user| 
      insert = 'INSERT INTO "user" VALUES(' + user['id'].to_s + ', \'' + user['name'] + '\');'
      conn.exec("#{insert}")
    end
  end

  def saveFriend(conn,users)
    users.each do |user| 
      user['friends'].each do |friendId|
        insert = 'INSERT INTO "friend" VALUES(' + user['id'].to_s + ', \'' + friendId.to_s + '\');'
        conn.exec("#{insert}")
      end
    end
  end

end