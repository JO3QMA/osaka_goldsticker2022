# frozen_string_literal: true

require './core/shop'
require './core/search'
require 'csv'

class Result
  def initialize; end

  def main
    si = SearchPage.new
    list = si.all_store_url
    store_list = []
    list.each do |url|
      store = ShopInfo.new(url)
      info = []
      info.push(store.name)
      info.push(store.addr)
      info.push(store.postcode)
      info.push(store.tel)
      info.push(store.bizhours)
      info.push(store.regholiday)
      info.push(store.info)
      info.push(store.category)
      info.push(store.url)

      store_list.push(info)
    end

    CSV.open('shop2.csv', 'w') do |csv|
      store_list.each do |store|
        csv << store
      end
    end
  end
end

main = Result.new
main.main
