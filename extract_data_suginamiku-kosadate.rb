require 'nokogiri'
require 'open-uri'

BASE_URL = "https://www.city.suginami.tokyo.jp/"
POSTAL_CODE_PATTERN_1 = /〒\d{3}-\d{4}/
POSTAL_CODE_PATTERN_2 = /^\d{3}-\d{4}/

URL_LIST = ["https://www.city.suginami.tokyo.jp/kosodate/ouenken/jigyousya/a/index.html",
"https://www.city.suginami.tokyo.jp/kosodate/ouenken/jigyousya/ka/index.html",
"https://www.city.suginami.tokyo.jp/kosodate/ouenken/jigyousya/sa/index.html",
"https://www.city.suginami.tokyo.jp/kosodate/ouenken/jigyousya/ta/index.html",
"https://www.city.suginami.tokyo.jp/kosodate/ouenken/jigyousya/na/index.html",
"https://www.city.suginami.tokyo.jp/kosodate/ouenken/jigyousya/ha/index.html",
"https://www.city.suginami.tokyo.jp/kosodate/ouenken/jigyousya/ma/index.html",
"https://www.city.suginami.tokyo.jp/kosodate/ouenken/jigyousya/ya/index.html",
"https://www.city.suginami.tokyo.jp/kosodate/ouenken/jigyousya/ra/index.html",
"https://www.city.suginami.tokyo.jp/kosodate/ouenken/jigyousya/wa/index.html"]

#URL_LIST = ["https://www.city.suginami.tokyo.jp/kosodate/ouenken/jigyousya/ya/index.html"]

# 指定されたURL

def printTable(doc)
  begin
    # tableの情報をすべて抽出
    tables = doc.xpath('//table')
  
    # 各tableの内容を表示
    tables.each_with_index do |table, index|
      puts "Table #{index + 1}:"
      rows = table.xpath('.//tr')
      rows.each do |row|
        columns = row.xpath('.//th|td')
        row_data = columns.map { |col| col.text.strip }
        # puts row_data.join("\t")
        puts row_data[1]
      end
      puts "\n"
    end
  rescue StandardError => e
    puts "エラーが発生しました: #{e.message}"
  end
end

def getShop(shopTitleUrl)
  
  # URLからページのHTMLを取得
  html = open(shopTitleUrl[1])
  doc = Nokogiri::HTML(html)

  #戻り地のshops
  shop = {}
  
  begin
    line = ""
    shop = {"title" => shopTitleUrl[0]}
    shop.store("URL",shopTitleUrl[1])
    # dlタグの情報を抽出
    dl_tags = doc.xpath('//dl')
    header = ""
  
    # 各dlタグの内容を表示
    dl_tags.each_with_index do |dl_tag, index|
      #puts "DL Tag #{index + 1}:"
      dt_tags = dl_tag.xpath('.//dt')
      dd_tags = dl_tag.xpath('.//dd')
      dt_tags.each_with_index do |dt_tag, i|
        dd_tag = dd_tags[i]
        #puts "#{dt_tag.text.strip}: #{dd_tag.text.strip}"
        #puts "#{dd_tag.text.strip}"
        line = line + ",#{dd_tag.text.strip}"
        header = header + ",#{dt_tag.text.strip}"
        shop.store(dt_tag.text.strip,dd_tag.text.strip)
      end
      
      #puts header
      #puts line
     # pp shop
      #exit
    end
  rescue StandardError => e
    puts "エラーが発生しました: #{e.message}"
  end
  
  return shop
end


def getShopTitleUrls(url)
  begin
    # URLからページのHTMLを取得
    html = open(url)
    doc = Nokogiri::HTML(html)
    
    shopList = Array.new
  
    # class属性が"listlink"のulタグを取得
    ul_listlink = doc.css('ul.listlink')
  
    # ulタグ内のliタグの内容を抽出
    ul_listlink.css('li').each_with_index do |li_tag, index|
      
      a_tag = li_tag.at_css('a')
      if a_tag
        attribute = a_tag.attribute('href').value.gsub("../../../../", BASE_URL)
        value = a_tag.text
        #puts "List Item #{index + 1}: #{attribute}=\"#{value}\""
        shopList <<  [value,attribute]
      end
      
    end
  rescue StandardError => e
    puts "エラーが発生しました: #{e.message}"
  end
  
  return shopList
end

def correct_address(original_address)
  
  address = original_address
  
  #郵便番号があれば取り除く
  address.gsub!(POSTAL_CODE_PATTERN_1,"")
  address.gsub!(POSTAL_CODE_PATTERN_2,"")
  
  #先頭が杉並区から始まる場合は東京都を入れる
  
  
  return address
  
end


#main

shopTitleUrls = []

URL_LIST.each do |kana_url|
  shopTitleUrls = shopTitleUrls + getShopTitleUrls(kana_url)
end


#pp shopList.size

shops = []

shopTitleUrls.each do |shopTitleUrl|
    shops << getShop(shopTitleUrl)
end

puts "title,事業者名,住所,URLl"
shops.each do |shop|
  puts "#{shop["title"]},#{shop["事業者名"]},#{shop["住所"]},#{shop["URL"]},#{correct_address(shop["住所"])}"
end


