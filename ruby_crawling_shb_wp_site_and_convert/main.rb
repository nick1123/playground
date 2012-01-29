require 'open-uri'

# Crawls a url and returns its html contents
def crawl(url)
  content = ""
  open(url) do |s| content = s.read end
  return content
end

def run
  menu = []
  url = "http://stophairbreakage.org/category/stop-hair-loss/"
  contents = crawl(url)
  chunks = contents.scan(/<h2 class=\"entry-title\">.*?<\/h2>/)
  chunks[0..100].each do |chunk|
    title = chunk.scan(/\<a.*?>(.*?)<\/a>/).to_s.gsub("&#8211;", "-")
    p title
    new_file_name = title.downcase.gsub(/[^a-z]+/, ' ').strip.gsub(' ', '_') + ".php"
    p new_file_name
    url = chunk.scan(/(http.*?)\"/).to_s
    p url
    url_contents = crawl(url)
    file_output = url_contents.scan(/<div class=\"format_text entry-content\">(.*?)<\/div>/m).to_s
    file_output = file_output.gsub(/<script.*?<\/script>/m, '')
    file_output = file_output.gsub(/<!--.*?-->/m, '')
    file_output = file_output.gsub(/<h3  class=\"related_post_title.*/m, '')
    file_output = file_output.gsub(/<div id=\"body\">/, '')



    file_output = "<?php\n\n$page_title = \"#{title}\";\n\n$page_content = <<<END\n#{file_output.strip}\nEND;\n\ninclude \"layout.php\";\n?>"
    puts file_output
    File.open("output/" + new_file_name, 'w') {|file| file.write(file_output)}
    
    menu << "<li><a href=\"#{new_file_name}\">#{title}</a></li>"
    puts ""
    sleep 2
  end

  puts menu
end

run
