# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(->
  $(document).on "click","#btn_load", ->
    #Länge
    lon_min=parseFloat($('#lon_min').val())#13.33
    lon_max=parseFloat($('#lon_max').val())#13.34
    #console.log lon_min
    #Breite
    lat_min=parseFloat($('#lat_min').val())#50.92
    lat_max=parseFloat($('#lat_max').val())#50.93
    #
    w=$(window).width()-$('#controls').width()-50#parseFloat($('#image_w').val())#650
    h=$(window).height()#parseFloat($('#image_h').val())#700
    if $('#street_label').is(':checked')
      text=true
    else
      text=false
    if $('#format_json').is(':checked')
      format='json'
    else
      format='svg'
    keys =[]
    if $('#landuse').is(':checked')
      keys.push "landuse"
    if $('#leisure').is(':checked')
      keys.push "leisure"
    if $('#natural').is(':checked')
      keys.push "natural"
    if $('#building').is(':checked')
      keys.push "building"
    if $('#amenity').is(':checked')
      keys.push "amenity"
    if $('#highway').is(':checked')
      keys.push "highway"
    if $('#railway').is(':checked')
      keys.push "railway"
    if $('#waterway').is(':checked')
      keys.push "waterway"
    if $('#historic').is(':checked')
      keys.push "historic"
    
    if !(lon_min>=-180&&lon_max>lon_min&&lon_max<=180&&lat_min>=-90&&lat_max>lat_min&&lat_max<=90&&w>0&&h>0)
      alert 'Eingabe ungültig'
      return
    path='osm/show/'+lon_min+'/'+lon_max+'/'+lat_min+'/'+lat_max+'/'+w+'/'+h+'/'+format
    $('#image').html('<p>Loading Map</p>')
    console.log "Start Post"
    $.ajax {
      url: path,
      #type: 'get'
      type: 'post'
      data: { iftext: text,render_keys:keys }
      success:(data) ->
        if format=='svg'
          console.log 'svg'
          $('#image').html(data.activeElement)
        else
          $('#image').html(JSON.stringify data , null)
        $('#image').width(w)
        $('#image').height(h)
    }
   
  $(".layout").change ->   
    css=$(".layout :selected").val()
    $('#map_css').attr('href',"/assets/"+css+".css?body=1")
    #alert "/assets/"+css+".css?body=1"
  #$(document).on "click","#show_controlls", ->
    #$("#controls").animate width: "25%"
    #$('#controls').slideToggle("fast")
)
