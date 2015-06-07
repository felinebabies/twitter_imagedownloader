# coding: utf-8

require 'bundler'
Bundler.require

class TweetDataBase
  attr_reader :dbFilePath
  def initialize(dbFile = nil, logger = nil)
    #loggerインスタンスが無ければ作る
    @logger = logger || Logger.new(STDERR)

    # 当スクリプトファイルの所在
    @scriptdir = File.expand_path(File.dirname(__FILE__))

    # セーブファイル所在が無いなら作る
    @dbFilePath = dbFile || File.join(@scriptdir, '../savedata/tweetdb.db')
  end

  #データベースファイルが無ければ作り、テーブルを初期化する
  def initDataBase
    # テーブルが存在しない場合のみ新規作成
    unless tableExists? then
      @logger.info("tweetdataテーブルが存在しない為、新規作成します。")
      db = SQLite3::Database.new(@dbFilePath)
      sql = <<SQL
CREATE TABLE tweetdata (
  id integer PRIMARY KEY AUTOINCREMENT,
  tweet_id integer,
  tweetstr text,
  tweettime text,
  userid integer,
  username text,
  screenname text
);
SQL
      db.execute(sql)
      db.close
    end
  end

  #データベースファイルとテーブルが共に存在するかを返す
  def tableExists?
    unless File.exist?(@dbFilePath) then
      return false
    end

    sql = "SELECT * FROM sqlite_master WHERE type == 'table'"

    db = SQLite3::Database.new(@dbFilePath)
    tableExist = db.execute(sql).flatten.include?('tweetdata')

    db.close

    return(tableExist)
  end

  #ツイート情報を登録する
  def registerTweetData(userDataObj)
    sql = 'INSERT INTO tweetdata values (NULL, ?, ?, ?, ?, ?, ?);'

    db = SQLite3::Database.new(@dbFilePath)
    db.execute(sql, userDataObj[:tweetId], userDataObj[:tweetStr], userDataObj[:time], userDataObj[:userId], userDataObj[:userName], userDataObj[:screenName])
    db.close
  end
end
