# coding: utf-8

require_relative 'lib/twitterimgdownloader'

downloader = TwitterImgDownloader.new

KEYWORD = '#幼女版深夜の真剣お絵かき60分一本勝負'

downloader.execSearch(KEYWORD)
