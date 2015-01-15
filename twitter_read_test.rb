# coding: utf-8

require 'uri'
require 'open-uri'
require 'bundler'
Bundler.require

require_relative 'twitterclient'

# 当スクリプトファイルの所在
$scriptdir = File.expand_path(File.dirname(__FILE__))

# twitterクライアントの生成
client = getTwitterClient

KEYWORD = '#幼女版深夜の真剣お絵かき60分一本勝負'

def getUrlsFromTweet(tweetStr)
  urls = URI.extract(tweetStr, ['http'])
end

# HTML中から画像のURLを取得する
def getImageUrl(html)
  # twitterのメディアページ
  begin
    dom = Nokogiri::HTML.parse(html)

    node = dom.search('a.media-thumbnail')

    img_url = node.search('img').first.attributes['src'].value
  rescue
    return nil
  end

  return img_url
end

client.search(KEYWORD + ' -rt', lang: "ja").each do |status|
  puts "#{status.user.screen_name}: #{status.text}"

  # ツイート中のURL一覧を取得する
  urls = getUrlsFromTweet(status.text)

  urls.each_with_index do |url, index|
    begin
      html = open(url, :allow_redirections => :all).read
      img_url = getImageUrl(html)

      if img_url then
        # 拡張子があれば抽出する
        ext = File.extname(img_url)

        # 画像を保存する
        p img_url
        imgFileName = "#{status.id}_#{index}#{ext}"
        File.open(File.join($scriptdir, "images/", imgFileName), 'wb') do |file|
          open(img_url) do |data|
            file.write(data.read)
          end
        end
      end
      sleep 2
    rescue => ex
      puts ex.message

      # 画像の取得/保存に失敗した場合はやり直す
      p '画像の取得/保存に失敗しました、retryします'
      sleep 5
      retry
    end

  end
end
