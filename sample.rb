require 'net/http'
require 'uri'
require 'json'
require 'logger'
require 'pg'
require 'dotenv/load'


def getUsers(num)
  suceessLogger = Logger.new('./success.log')
  errorLogger = Logger.new('./error.log')

  begin
    # リクエスト
    uri = URI.parse(ENV['api'] + '/user/' + "#{num}")
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.get(uri.request_uri)
    end

    case response
    # success
    when Net::HTTPSuccess
      return JSON.parse(response.body)
    else
    # error
      logger.error("HTTP ERROR: code=#{response.code} message=#{response.message}")
    end

    # エラーハンドリング
    rescue IOError => e
      errorLogger.error(e.message)
    rescue TimeoutError => e
      errorLogger.error(e.message)
    rescue JSON::ParserError => e
      errorLogger.error(e.message)
    rescue => e
      errorLogger.error(e.message)
  end
end

def dropTables
  connect = PG::connect(host: ENV['hostname'], user: ENV['username'], password: ENV['password'], dbname: ENV['database'], port: ENV['port']) 
  connect.exec('delete from "friend"')
  connect.exec('delete from "user"')
  connect.finish
end

def saveUser(users)
  connect = PG::connect(host: ENV['hostname'], user: ENV['username'], password: ENV['password'], dbname: ENV['database'], port: ENV['port']) 
  users.each do |user| 
    insert = 'INSERT INTO "user" VALUES(' + user['id'].to_s + ', \'' + user['name'] + '\');'
    connect.exec("#{insert}")
  end
  connect.finish
end

def saveFriend(users)
  connect = PG::connect(host: ENV['hostname'], user: ENV['username'], password: ENV['password'], dbname: ENV['database'], port: ENV['port']) 
  users.each do |user| 
    user['friends'].each do |friendId|
      insert = 'INSERT INTO "friend" VALUES(' + user['id'].to_s + ', \'' + friendId.to_s + '\');'
      connect.exec("#{insert}")
    end
  end
  connect.finish
end

# main
def main
  users = Array.new
  userNum = 10
  userNum.times do |count|
    users[count] = getUsers("#{count+1}")
  end
  dropTables
  saveUser(users)
  saveFriend(users)
end

# 実行されたらmainを呼び出す
if __FILE__ == $0
  main
end