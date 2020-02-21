require 'logger'
require './repository.rb'
require './adaptor.rb'

# main
class Main
  Logger = Logger.new('./batch.log','daily')
  Adaptor = Adaptor.new
  Repository = Repository.new
  def main
    Logger.info("start: Replication Users and Friends")

    # 10人のユーザ情報を取得
    begin
      users = Array.new
      userNum = 10
      userNum.times do |count|
        users[count] = Adaptor.getUsers("#{count+1}")
      end
    rescue => e
      Logger.error("faild: cannot get Users and Friends")
      Logger.error(e.message)
      exit
    else
      Logger.info("success: get Users and Friends")
    end


    # dbにレプリケーション
    begin
      conn = Repository.connect
      # 一度ユーザ、フレンド情報を削除
      Repository.dropTables(conn)
      # 再登録
      Repository.saveUser(conn,users)
      Repository.saveFriend(conn,users)
    rescue => e
      Repository.rollback(conn)
      Logger.error("faild: cannot save Users and Friends")
      Logger.error(e.message)
      exit
    else
      Repository.commit(conn)
      Logger.info("success: save Users and Friends")
      exit
    end
  end
end
