def full_title(page_title)
  base_name = 'Ruby on Rails Tutorial Sample App'
  if page_title.empty?
  	base_name
  else
  	"#{base_name} | #{page_title}"
  end
end