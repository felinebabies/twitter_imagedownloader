#! ruby -E Windows-31J:utf-8
# coding: utf-8
require 'bundler'
Bundler.require

require_relative 'lib/twitterimgdownloader'

# 画像の保存先
currentdir = File.expand_path(File.dirname(__FILE__))
imagedir = File.join(currentdir, 'images/')

# loggerインスタンスの作成
logger = Logger.new(STDERR)

downloader = TwitterImgDownloader.new(imagedir, logger)

hl = HighLine.new

keyword = hl.ask('Search keyword:')

logger.info("Keyword :[#{keyword}]")

downloader.execSearch(keyword)
