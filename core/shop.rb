# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

# 店舗情報
class ShopInfo
  attr_reader :addr, :postcode, :tel, :bizhours, :regholiday, :info

  # Init
  def initialize(url)
    puts url
    charset = nil
    begin
      html = URI.open(url) do |f|
        charset = f.charset
        f.read
      end
    rescue StandardError => e
      puts e
      sleep 10
      retry
    end
    @doc = Nokogiri::HTML.parse(html, nil, charset)

    # 詳細情報だけはTableでClassもIDもついていないので、
    # 一度にパースする方が都合良い
    parse_info
  end

  # 店舗名
  def name
    normalize(@doc.css('.name').text)
  end

  # 詳細情報
  def parse_info
    @doc.css('div.inbox table tr').each do |tr|
      th = tr.css('th').text
      td = tr.css('td').text
      case th
      when '住所'
        @postcode = normalize(td.slice(/[0-9]{3}-?[0-9]{4}/), 'postcode')
        @addr = normalize(td.sub(/[0-9]{3}-?[0-9]{4}/, ''), 'addr') # 最初の郵便番号を消せば残りは住所だろう多分。
      when 'TEL'
        @tel = normalize(td)
      when '営業時間'
        @bizhours = normalize(td).gsub(/(から|ー|-)/, '〜').gsub(/：/, ':').gsub('時', ':').gsub('半', '30').gsub(
          /:(?![0-9])/, ':00'
        )
      when '定休日'
        @regholiday = normalize(td)
      when '利用お知らせ'
        @info = normalize(td.to_s)
      end
    end
  end

  # Webサイトへのリンク
  def url
    @doc.css('a.weblink').each do |anchor|
      @url = anchor[:href].to_s.gsub(/(\r|\r\n|\n|^ )/, ' ')
    end
    @url
  end

  # カテゴリー分け 場所の情報はクソの役にも立たないので消します。
  # 大阪市内の区分はともかく、その他が・・・。中河内ってなんやねん。東大阪市と八尾含むし絞り込めてへんわ。
  def category
    @doc.css('.tag_list li').first.text
  end

  # 正規化 表記ゆれや誤字脱字をここで吸収する
  def normalize(str, mode = '')
    puts str
    str = str.to_s
    case mode
    when "name"
    when "postcode"
        str = str.gsub(/([0-9]{3})([0-9]{4})/, '\\1-\\2') # 郵便番号を7桁の数字だけで記述する狂気の店があったため
    when "addr"
        str = str.sub(/([0-9]?[0-9])階/, " \\1F")
        str = "大阪府 " + str
        str = str.sub(/(.+[市町村郡])/,"\\1 ").sub(/(.+区)/, "\\1 ")
    when "tel"
    when "bizhours"
    when "regholiday"
    when "info"
    when "url"
    end
    str = str.gsub(/(\r|\r\n|\n|^ )/, ' ').gsub(/　/, ' ').gsub(/ +/, ' ').gsub(/^ /, '')
    str = str.tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z').gsub('~', '〜').gsub(',', '、').gsub(/([0-9])[ー－]/, '\\1-')
  end
end
