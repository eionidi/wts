class ParserController < ApplicationController

	# для получения контента через http
  require 'open-uri'

  # подключаем Nokogiri
  require 'nokogiri'
  
  
  def yandex
  	source = 'http://catalog.yandex.ru/'

    # получаем содержимое веб-страницы в объект
    page = Nokogiri::HTML(open(source.to_s + page))

	# производим поиск по элементам с помощью css-выборки
    page.css('a.b-rubric__list__item__link').each do |link|

      data = Hash.new
      
      data['text'] = link.content

      data['href'] = link['href']
  end
  
end
