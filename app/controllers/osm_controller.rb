# coding: UTF-8
class OsmController < ApplicationController

  def show
    require "net/http"
    require "uri"
    #paar sachen definieren
    x_min=params[:x_min].to_f#13.34#Koordinaten Längengrad(linker rand)
    x_max=params[:x_max].to_f#13.35#Koordinaten Längengrad(rechter rand)
    y_min=params[:y_min].to_f#50.9#Koordinaten Breitengrad(unterer Rand)
    y_max=params[:y_max].to_f#50.91#Koordinaten Breitengrad(oberer Rand)
    b=params[:b].to_f#600#Bildbreite
    h=params[:h].to_f#700#Bildhöhe
    
    x_max=((b/h)*(y_max-y_min)/(Math.cos (y_min*(Math::PI/180)) ))+x_min
    render_keys=["landuse","leisure","natural","building","amenity","highway","railway","waterway","historic"]
    uri = URI.parse(URI.encode('http://overpass-api.de/api/interpreter?data=[out:json];(node('+y_min.to_s+','+x_min.to_s+','+y_max.to_s+','+x_max.to_s+');rel(bn)->.x;way('+y_min.to_s+','+x_min.to_s+','+y_max.to_s+','+x_max.to_s+');node(w)->.x;);out qt;'))
    #uri= URI.parse(URI.encode('http://localhost:3000/interpreter1.json'))
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    objArray = JSON.parse(response.body)
    nodes=objArray["elements"].select{|el| el["type"] =="node" }
    ways=objArray["elements"].select{|el| el["type"] =="way"&&el["tags"]!=nil }
    @svg=""
    keys=""
    render_keys.each do |key|
      keys+=" "+key
    end
    IO.popen("./parse_map "+x_min.to_s+" "+x_max.to_s+" "+y_min.to_s+" "+y_max.to_s+" "+h.to_s+" "+b.to_s+keys, mode='r+') do |io|
      io.write (ways.to_json+"\n"+nodes.to_json)
      io.close_write
      @svg=io.read
    end
    @svg.gsub!("\\223","ß")
    @svg.gsub!("\\252","ü")
    @svg.gsub!("\\228","ä")
    @svg.gsub!("\\246","ö")
    @svg.gsub!("\\214","Ö")
    @svg.gsub!("\\220","Ü")
    @svg.gsub!("\\246","Ä")
    File.open("aus.svg", 'w') { |file| file.write(@svg) }
    respond_to do |format|
	    format.html # show.html.erb
	    format.json { render json: response.body }
      format.svg 
    end
  end

end
