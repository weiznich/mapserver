# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(->
  $(document).on "click","#btn_load", ->
    #get mapparams
    lon_min=parseFloat($('#lon_min').val())
    lon_max=parseFloat($('#lon_max').val())
    lat_min=parseFloat($('#lat_min').val())
    lat_max=parseFloat($('#lat_max').val())

    w=parseFloat($('#image_w').val())
    h=parseFloat($('#image_h').val())

    if $('#street_label').is(':checked')
      text=true
    else
      text=false
    if $('#format_json').is(':checked')
      format='json'
    else
      format='svg'
    keys =[]
    $("input:checkbox").each ->
      keys.push $(this).attr("id")  if $(this).attr("id") isnt "format_json" and $(this).attr("id") isnt "street_label"  if $(this).is(":checked")
    
    #check mapsize
    if !(lon_min>=-180&&lon_max>lon_min&&lon_max<=180&&lat_min>=-90&&lat_max>lat_min&&lat_max<=90&&w>0&&h>0)
      alert 'Eingabe ungültig'
      return
    
    #make request and show result
    path='osm/show/'+lon_min+'/'+lon_max+'/'+lat_min+'/'+lat_max+'/'+w+'/'+h+'/'+format
    $('#image').html('<p>Loading Map</p>')
    console.log "Start Post"
    $.ajax {
      url: path,
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

  #change maplayout
  $(".layout").change ->   
    css=$(".layout :selected").val()
    $('#map_css').attr('href',"/assets/"+css+".css?body=1")
)
