require 'uri'
require 'open-uri'
require 'bundler'
Bundler.require

require_relative 'streamclient'

# 当スクリプトファイルの所在
$scriptdir = File.expand_path(File.dirname(__FILE__))

# twitterクライアントの生成
client = getStreamClient

MAX_TWEET = 10
KEYWORD = '#幼女版深夜の真剣お絵かき60分一本勝負'

def getUrlsFromTweet(tweetStr)
  urls = URI.extract(tweetStr, ['http'])
end

@statuses = []
client.filter(track: KEYWORD, lang: "ja") do |status|
  if status.is_a?(Twitter::Tweet) &&  !status.text.index("RT") then
    puts "#{status.user.screen_name}: #{status.text}"
    @statuses << status

    # ツイート中のURL一覧を取得する
    urls = getUrlsFromTweet(status.text)

    urls.each_with_index do |url, index|
      begin
        html = open(url, :allow_redirections => :safe).read
        img_url = Nokogiri::HTML.parse(html)
          .search('a.media-thumbnail')
          .search('img')
          .first
          .attributes['src']
          .value

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

        sleep 2
      rescue
        # 画像の取得/保存に失敗した場合はやり直す
        p '画像の取得/保存に失敗しました、retryします'
        sleep 5
        retry
      end

    end

    break if @statuses.size >= MAX_TWEET
  end
end
