# coding: UTF-8
class OsmController < ApplicationController

  def show    
    require "net/http"
    require "uri"
    #get parameter from request
    x_min=params[:x_min].to_f
    x_max=params[:x_max].to_f
    y_min=params[:y_min].to_f
    y_max=params[:y_max].to_f
    b=params[:b].to_f
    h=params[:h].to_f
    text=0
    if params[:iftext]=="true"
    then
      text=1
    end
    render_keys=params[:render_keys]

    #calculate mapwidth
    x_max=((b/h)*(y_max-y_min)/(Math.cos (y_min*(Math::PI/180)) ))+x_min

    #get data from overpass-api
    uri = URI.parse(URI.encode('http://overpass-api.de/api/interpreter?data=[out:json];(node('+y_min.to_s+','+x_min.to_s+','+y_max.to_s+','+x_max.to_s+');rel(bn)->.x;way('+y_min.to_s+','+x_min.to_s+','+y_max.to_s+','+x_max.to_s+');node(w)->.x;);out qt;'))
    #uri= URI.parse(URI.encode('http://localhost:3000/interpreter1.json'))
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    
    if params[:format]=="svg"
    then
      #parse json
      objArray = JSON.parse(response.body)

      #get ways and nodes
      nodes=objArray["elements"].select{|el| el["type"] =="node" }
      ways=objArray["elements"].select{|el| el["type"] =="way"&&el["tags"]!=nil }
      svg=""
      
      #parse renderkeys from array to string
      keys=""
      render_keys.each do |key|
        keys+=" "+key
      end

      #render svg from json
      t_start=Time.now
      IO.popen("./parse_map "+x_min.to_s+" "+x_max.to_s+" "+y_min.to_s+" "+y_max.to_s+" "+h.to_s+" "+b.to_s+" "+text.to_s+" "+keys, mode='r+') do |io|
        io.write (ways.to_json+"\n"+nodes.to_json)
        io.close_write
        svg=io.read
      end

      t=Time.now-t_start

      #make svg string clean
      svg.gsub!("\\223","ß")
      svg.gsub!("\\252","ü")
      svg.gsub!("\\228","ä")
      svg.gsub!("\\246","ö")
      svg.gsub!("\\214","Ö")
      svg.gsub!("\\220","Ü")
      svg.gsub!("\\246","Ä")
      svg+="<!--Time: "+t.to_s+" -->"
    end

    #response result
    respond_to do |format|
	    format.json { render json: response.body }
      format.svg { render text: svg.html_safe }
    end
  end

end
