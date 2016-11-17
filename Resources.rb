# Gets resources from http://api.datosabiertos.chilecompra.cl/api/v2/resources/?auth_key=API_KEY
# Doesnt seem to be useful for this, its old data
require 'net/http'
require 'uri'
require 'json'


@filename = "resources.txt"
@API_key = ENV['CC_ALT_KEY']
@resources_uri = "http://api.datosabiertos.chilecompra.cl/api/v2/resources.json/?auth_key=" << @API_key


@result = Net::HTTP.get(URI(@resources_uri))


File.write(@filename, @result)





