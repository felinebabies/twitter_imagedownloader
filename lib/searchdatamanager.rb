# coding: utf-8

require 'logger'
require 'digest/md5'
require 'yaml/store'

# 検索情報セーブデータ管理
class SearchDataManager
  def initialize(saveFile = nil, logger = nil)
    #loggerインスタンスが無ければ作る
    @logger = logger || Logger.new(STDERR)

    # 当スクリプトファイルの所在
    @scriptdir = File.expand_path(File.dirname(__FILE__))

    # セーブファイル所在が無いなら作る
    saveFile = saveFile || File.join(@scriptdir, '../savedata/searchdata.yaml')
    @db = YAML::Store.new(saveFile)
  end

  # 指定キーワードで最後に検索した日時を得る
  def getLastSearchTime(keyword)
    md5 = Digest::MD5.hexdigest(keyword)
    @db.transaction(true) do
      if @db.root?(md5) then
        lastSearchTime = @db[md5]
      else
        lastSearchTime = nil
      end

      return lastSearchTime
    end
  end

  # 指定キーワードで最後に検索した日時を記録する
  def saveLastSearchTime(keyword, searchTime = nil)
    md5 = Digest::MD5.hexdigest(keyword)
    saveTime = searchTime || DateTime.now

    @db.transaction do
      @db[md5] = saveTime
    end
  end
end
