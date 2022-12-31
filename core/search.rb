# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

class SearchPage
  def initialize
    @site_url = 'https://goto-eat.weare.osaka-info.jp/gotoeat/'
    @num_prefix = 'page/'
    @param = '/?search_element_0_0=2&search_element_0_1=3&search_element_0_2=4&search_element_0_3=5&search_element_0_4=6&search_element_0_5=7&search_element_0_6=8&search_element_0_7=9&search_element_0_8=10&search_element_0_9=11&search_element_0_cnt=10&search_element_1_0=12&search_element_1_1=13&search_element_1_2=14&search_element_1_3=15&search_element_1_4=16&search_element_1_5=17&search_element_1_6=18&search_element_1_7=19&search_element_1_8=20&search_element_1_9=21&search_element_1_10=22&search_element_1_11=23&search_element_1_12=24&search_element_1_13=25&search_element_1_14=26&search_element_1_15=27&search_element_1_16=28&search_element_1_cnt=17&s_keyword_3&cf_specify_key_3_0=gotoeat_shop_address01&cf_specify_key_3_1=gotoeat_shop_address02&cf_specify_key_3_2=gotoeat_shop_address03&cf_specify_key_length_3=2&searchbutton=%E5%8A%A0%E7%9B%9F%E5%BA%97%E8%88%97%E3%82%92%E6%A4%9C%E7%B4%A2%E3%81%99%E3%82%8B&csp=search_add&feadvns_max_line_0=4&fe_form_no=0'
  end

  def gen_url(num)
    page_num = if num.zero?
                 ''
               else
                 @num_prefix + num.to_s
               end
    @site_url + page_num + @param
  end

  def get_max_page
    charset = nil
    html = URI.open(gen_url(0)) do |f|
      charset = f.charset
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
    doc.css('div.wp-pagenavi span.pages').text.split[2].to_i
    # return 100
  end

  def page_list
    pages = []
    max = get_max_page
    (0..max).each do |i|
      pages.push(gen_url(i))
    end
    pages
  end

  def resultpage_store_urls(url)
    charset = nil
    html = URI.open(url) do |f|
      charset = f.charset
      f.read
    end

    anchor_list = []
    doc = Nokogiri::HTML.parse(html, nil, charset)
    doc.css('.search_result_box ul li a').each do |anchor|
      anchor_list.push(anchor[:href])
    end
    anchor_list
  end

  def all_store_url
    list = page_list
    store_urls = []
    list.each do |url|
      store_urls |= resultpage_store_urls(url)
    end
    store_urls
  end
end
