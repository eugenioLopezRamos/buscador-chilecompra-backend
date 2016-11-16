

#Transforma los datos devueltos por empresas/BuscarCompradores? de json a hash

require 'json'
require 'net/http'
require 'uri'


uri = URI("http://api.mercadopublico.cl/servicios/v1/publico/empresas/BuscarComprador?ticket=" << ENV['CC_TOKEN'])
receiver_file = File.open('compradores.json', 'w+')

File.write(receiver_file, Net::HTTP.get(uri))

file = receiver_file
read = File.read(file)

parsed = JSON.parse(read)
#returns {"Cantidad": 852, "FechaCreacion": "2016-11-15T09:50:44.25", "listaEmpresas": [{"CodigoEmpresa": 123123123,  "NombreEmpresa": "Municipalidad de Chuchunco"}]}

	File.open("ListaCompradores.txt", "w+") do |f|
		parsed["listaEmpresas"].each do |line| 
			f.write("\"#{line['CodigoEmpresa'].to_s}\": \"#{line['NombreEmpresa']}\", \n")
		end

	end
