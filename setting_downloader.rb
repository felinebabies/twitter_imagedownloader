# coding: utf-8
require 'yaml'
require 'bundler'
Bundler.require

require_relative 'lib/twitterimgdownloader'

currentdir = File.expand_path(File.dirname(__FILE__))

# キーワードリストの読み込み
settingFile = File.join(currentdir, 'savedata/', 'keywordlist.yml')
keywordList = YAML.load_file(settingFile)

# loggerインスタンスの作成
logger = Logger.new(File.join(currentdir, 'log/', 'setting_downloader.txt'), 0, 5 * 1024 * 1024)

keywordList.each do |keywordset|
  keyword = keywordset['keyword']

  logger.info("Keyword :[#{keyword}]")

  # 画像の保存先
  imagedir = File.join(currentdir, keywordset['imgdir'])
  unless File.exist?(imagedir) then
    FileUtils.mkdir(imagedir)
  end

  downloader = TwitterImgDownloader.new(imagedir, logger)

  downloader.execSearch(keyword)
end
