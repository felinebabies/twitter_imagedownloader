# coding: utf-8

require_relative 'lib/twitterimgdownloader'

# 画像の保存先
currentdir = File.expand_path(File.dirname(__FILE__))
imagedir = File.join(currentdir, 'images/')

downloader = TwitterImgDownloader.new(imagedir, nil)

KEYWORD = '#幼女版深夜の真剣お絵かき60分一本勝負'
#KEYWORD = '#艦これ版深夜の真剣お絵描き60分一本勝負'

downloader.execSearch(KEYWORD)
