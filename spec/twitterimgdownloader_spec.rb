# coding: utf-8

require_relative '../lib/twitterimgdownloader'

describe TwitterImgDownloader do
  before do
    #loggerの設定
    @logger = Logger.new(STDERR)
    @logger.level = Logger::INFO
  end

  subject { TwitterImgDownloader.new(nil, @logger) }

  context 'getImageUrl のドメイン別対応試験' do
    it '空のURLを渡すとnilを返す' do
      expect(subject.getImageUrl('')).to eq nil
    end

    it 'twitter公式画像URLを渡すと画像のURLを返す' do
      pageurl = 'https://twitter.com/twitter/status/542572692457541632'
      imageurl = 'https://pbs.twimg.com/media/B4ea_Q_CIAE0PUX.jpg:orig'
      expect(subject.getImageUrl(pageurl)).to eq imageurl
    end

    it 'tumblerのURLを渡すと画像のURLを返す' do
      pageurl = 'http://hakushikanosuke.tumblr.com/post/107161057367'
      imageurl = 'http://41.media.tumblr.com/6f25df927b0b3bb2a6421e86ff49c978/tumblr_nhoh6vqMh11shwpaao1_500.png'
      expect(subject.getImageUrl(pageurl)).to eq imageurl
    end
  end
end
