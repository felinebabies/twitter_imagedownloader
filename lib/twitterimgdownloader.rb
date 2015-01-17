# coding: utf-8

require 'logger'
require 'uri'
require 'open-uri'
require 'bundler'
Bundler.require

require_relative 'twitterclient'
require_relative 'valid_url'

# Twitterの検索結果から画像をダウンロードする
class TwitterImgDownloader
  SAVEINTERVAL = 2
  RETRYINTERVAL = 5

  def initialize(imageDir = nil, logger = nil)
    #loggerインスタンスが無ければ作る
    @logger = logger || Logger.new(STDERR)

    # 当スクリプトファイルの所在
    @scriptdir = File.expand_path(File.dirname(__FILE__))

    # 画像の保存先を設定する
    @imageDir = imageDir || File.join(@scriptdir, '..', 'images')
  end

  # HTML中から画像のURLを取得する
  def getImageUrl(url)
    begin
      html = open(url, :allow_redirections => :all).read

      @logger.info("画像掲載ページURL:[#{url}]")

      # 3回までのリダイレクト先を取得する
      validUrl = valid_url(url, 3)
      @logger.info("画像取得対象URL:[#{validUrl}]")

      # urlを解析する
      pageUri = URI(validUrl)

      dom = Nokogiri::HTML.parse(html)
      if pageUri.host == 'twitter.com' then
        # twitterのメディアページ
        node = dom.search('a.media-thumbnail')

        img_url = node.search('img').first.attributes['src'].value

        # オリジナルサイズの画像を取得
        img_url += ':orig'
      else
        # 全ての画像中から最も大きいもののURLを返す
        imagexpath = '//img'
        nodes = dom.xpath(imagexpath)

        @logger.info("imgタグは#{nodes.length}個あります")

        if !nodes.empty? then
          @logger.info("最大サイズの画像を探索します")
          sizeArray = nodes.map do |imgnode|
            width = imgnode.attributes['width'].try(:value).try(:to_i) || 0
            height = imgnode.attributes['height'].try(:value).try(:to_i) || 0

            @logger.info("imgタグの 幅:[#{width}] 高さ:[#{height}]")

            width * height
          end

          # 最大のサイズとなる要素の位置を得る
          maxIndex = sizeArray.index(sizeArray.max)
          img_url = nodes[maxIndex].attribute('src').value
        else
          img_url = nil
        end
      end
    rescue => ex
      puts ex.message
      @logger.error("画像URL探索のエラー[#{ex.message}] [#{ex.backtrace}]")
      return nil
    end

    return img_url
  end

  # 指定したキーワードでダウンロードを実行する
  def execSearch(keyword)
    # twitterクライアントの生成
    client = getTwitterClient

    statuses = client.search(keyword + ' -rt', lang: "ja")

    # ダウンロード実行
    downloadFromStatuses(statuses)
  end

  # ステータスの配列を元に画像をダウンロードする
  def downloadFromStatuses(statuses)
    statuses.each do |status|
      puts "#{status.user.screen_name}: #{status.text}"

      # ツイート中のURL一覧を取得する
      urls = URI.extract(status.text, ['http'])

      urls.each_with_index do |url, index|
        imgFileName = "#{status.id}_#{index}"
        saveFileName = File.join(@imageDir, imgFileName)
        imgDownload(url, saveFileName)
      end
    end
  end

  # 指定のURLから画像をダウンロードする
  def imgDownload(url, saveFileName)
    begin
      img_url = getImageUrl(url)
      if img_url.try(:include?, '?') then
        querypos = img_url.index('?')
        img_url = img_url[0...querypos]
      end

      if img_url then
        # 拡張子があれば抽出する
        ext = File.extname(img_url)

        # 画像を保存する
        puts img_url
        File.open(saveFileName + ext, 'wb') do |file|
          open(img_url) do |data|
            file.write(data.read)
          end
        end
      end
      sleep SAVEINTERVAL
    rescue => ex
      puts ex.message

      # 失敗時は指定秒数待った後やり直す
      puts '画像の取得/保存に失敗しました。retryします'
      sleep RETRYINTERVAL
      retry
    end
  end
end
