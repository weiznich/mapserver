class OsmController < ApplicationController
  #after_filter :set_content_type

  #def set_content_type
    #headers["Content-Type"] = "image/svg+xml"
  #end
  def show
    require "net/http"
    require "uri"
    #paar sachen definieren
    @x_min=params[:x_min].to_f#13.34#Koordinaten Längengrad(linker rand)
    @x_max=params[:x_max].to_f#13.35#Koordinaten Längengrad(rechter rand)
    @y_min=params[:y_min].to_f#50.9#Koordinaten Breitengrad(unterer Rand)
    @y_max=params[:y_max].to_f#50.91#Koordinaten Breitengrad(oberer Rand)
    @b=params[:b].to_f#600#Bildbreite
    @h=params[:h].to_f#700#Bildhöhe
    
    @x_max=((@b/@h)*(@y_max-@y_min)/(Math.cos (@y_min*(Math::PI/180)) ))+@x_min
    @keys_poly=["natural","landuse","building"]#Was als Polygon
    @keys_line=["highway","railway","waterway","historic","leisure","amenity"]#Was als Linie
    @render_keys=["landuse","leisure","natural","building","amenity","highway","railway","waterway","historic"]
    uri = URI.parse(URI.encode('http://overpass-api.de/api/interpreter?data=[out:json];(node('+@y_min.to_s+','+@x_min.to_s+','+@y_max.to_s+','+@x_max.to_s+');rel(bn)->.x;way('+@y_min.to_s+','+@x_min.to_s+','+@y_max.to_s+','+@x_max.to_s+');node(w)->.x;);out qt;'))
    #uri= URI.parse(URI.encode('http://localhost:3000/interpreter1.json'))
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    objArray = JSON.parse(response.body)
    @nodes=objArray["elements"].select{|el| el["type"] =="node" }
    @ways=objArray["elements"].select{|el| el["type"] =="way"&&el["tags"]!=nil }
    respond_to do |format|
	    format.html # show.html.erb
	    format.json { render json: response.body }
      format.svg
    end
  end

end
