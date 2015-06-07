# coding: utf-8
require 'pry'
require 'bundler'
Bundler.require

require 'date'
require_relative '../lib/tweetdatabase'

# 当スクリプトファイルの所在
SCRIPTDIR = File.expand_path(File.dirname(__FILE__))
TESTDATABASE = File.join(SCRIPTDIR, '../savedata/spectestdb.db')

describe TweetDataBase do
  before do
    #loggerの設定
    @logger = Logger.new(STDERR)
    @logger.level = Logger::INFO
  end

  subject { TweetDataBase.new(TESTDATABASE, @logger) }

  context 'データベース読み書き試験' do
    it 'ファイルが無い状態でテーブルの有無を調べると、falseが帰る' do
      expect(File.exist?(subject.dbFilePath)).to eq false

      expect(subject.tableExists?).to eq false
    end

    context 'ファイルがあるが、テーブルが無い状態ではfalseが帰る' do
      before do
        #ダミーデータベースを作る
        db = SQLite3::Database.new(subject.dbFilePath)
        sql = <<SQL
CREATE TABLE test (
  teststr text
);
SQL
        db.execute(sql)
        db.close
      end

      after do
        FileUtils.rm(subject.dbFilePath)
      end

      it 'ファイルがあるが、テーブルチェックではfalseが帰る' do
          expect(subject.tableExists?).to eq false
      end
    end

    context 'DBファイルもテーブルもある状態で、正常にtrueが帰る' do
      before do
        #ダミーデータベースを作る
        db = SQLite3::Database.new(subject.dbFilePath)
        sql = <<SQL
CREATE TABLE tweetdata (
  teststr text
);
SQL
        db.execute(sql)
        db.close
      end

      after do
        FileUtils.rm(subject.dbFilePath)
      end

      it 'ファイルもテーブルもあり、テーブルチェックではtrueが帰る' do
        expect(subject.tableExists?).to eq true
      end
    end

    context 'DBとテーブルを初期化する' do
      after do
        FileUtils.rm(subject.dbFilePath)
      end

      it 'テーブルチェックでtrueが帰る' do
        subject.initDataBase
        expect(subject.tableExists?).to eq true
      end
    end

    context 'ツイートをデータベースに登録する' do
      before do
        subject.initDataBase
      end
      after do
        FileUtils.rm(subject.dbFilePath)
      end

      it 'データベースに正常に登録できている' do
        tweetId = 1111
        tweetStr = 'テスト文字列あああああ'
        time = DateTime.now.to_s
        userId = 22222
        userName = 'hogefugapome'
        screenName = 'ほげふがぽめ'
        subject.registerTweetData(tweetId, tweetStr, time, userId, userName, screenName)

        db = SQLite3::Database.new(subject.dbFilePath)
        # binding.pry
        result = db.execute("select * from tweetdata;")

        db.close

        expect(result.count).to eq 1

        expect(result[0][0]).to eq 1
        expect(result[0][1]).to eq tweetId
        expect(result[0][2]).to eq tweetStr
        expect(result[0][3]).to eq time
        expect(result[0][4]).to eq userId
        expect(result[0][5]).to eq userName
        expect(result[0][6]).to eq screenName
      end
    end
  end

end
