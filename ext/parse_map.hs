{-# LANGUAGE OverloadedStrings #-}

import Data.Aeson
import Data.Aeson.Types
import Data.Maybe
import Control.Applicative ((<$>), (<*>))
import Control.Monad
import qualified Data.ByteString.Lazy.Char8 as BS
import qualified Data.HashMap.Strict as M
import qualified Data.Aeson.Encode as AE
import System.Environment
import System.Exit


data Node = Node { node_id  :: Integer
                 , node_typ      :: String
                 , node_lat      :: Float
                 , node_lon      :: Float
                 } deriving (Eq,Show)



data Way  =  Way { way_id   :: Integer
                 , way_typ      :: String
                 , way_nodes    :: [Integer]
                 , way_tags     :: Maybe Object
                 } deriving (Eq,Show)

instance FromJSON Node where
  parseJSON (Object v) =
    Node <$>
    (v .: "id")     <*>
    (v .: "type")   <*>
    (v .: "lat")    <*>
    (v .: "lon")  

instance FromJSON Way where
  parseJSON (Object v) =
    Way <$>
    (v .: "id")     <*>
    (v .: "type")   <*>
    (v .: "nodes")  <*>
    (v .:? "tags") 

parse_nodes src = do
    let x = fromMaybe [] (decode (BS.pack src) :: Maybe [Node])
    x
parse_ways src = do
    let x = fromMaybe [] (decode (BS.pack src) :: Maybe [Way])
    x

find_node a (x:xs) 
    | a == node_id x = x
    | a /= node_id x = find_node a xs

get_typ node_list 
    | head node_list==last node_list  =" Z"
    | otherwise                       =" "

get_tags tags
    | isJust tags=M.toList(fromJust tags)
    | otherwise=[]

get_name (x:xs)
    | show(fst x)==show("name")=(take ((length str)-6)(drop 3 str))
    | xs==[]=""
    | otherwise=""
    where 
       str=show(AE.fromValue(snd x))

get_text tags poly id
    |poly==" Z"=""
    | tags ==[]=""
    | name==""=""
    | otherwise="\n\t<text>\n\t\t<textPath xlink:href=\"#"++(show id)++"\" id=\""++(show id)++"_text\">\n\t\t\t<tspan >"++name++"</tspan>\n\t\t</textPath>\n\t</text>"
    where
      name=get_name tags
add_elem elem list n=
    (take n list)++[(head(drop n list))++[elem]]++(drop (n+1) list)


print_all nodes h w diff_x diff_y x_min y_max list keys (x:xs)=do
  let node_list=way_nodes x
  let tags= get_tags (way_tags x)
  let layer_typ=get_id 0 tags keys
  let typ=(get_typ node_list)
  let svg1="<path id=\""++(show(way_id x))++"\" class=\""++(fst layer_typ)++"\" d=\" " ++(print_nodes nodes x_min y_max h w diff_x diff_y "" node_list)++typ++"\"/>"++(get_text tags typ (way_id x))
  if xs/=[]
  then
      print_all nodes h w diff_x diff_y x_min y_max (add_elem (svg1++"\n\t") list (snd layer_typ)) keys xs
  else
      add_elem (svg1++"\n") list (snd layer_typ)

test key (x:xs)=do
    print( (show(fst x))==show key)
    if xs/=[]
    then
      test key xs
    else
      return()


get_svg str (x:xs)=do
    let str1=str++(get_svg_layer "" x)
    if xs/=[]
    then
        get_svg str1 xs
    else
        str1

get_svg_layer str (x:xs)=do
    let str1=str++x
    if xs/=[]
    then
        get_svg_layer str1 xs
    else
        str1

test_id key (x:xs)
    | show(fst x)==show key=key++"_"++(take ((length str)-6)(drop 3 str)) 
    | xs==[]=""
    | otherwise=test_id key xs
    where 
       str=show(AE.fromValue(snd x))

get_id n tags (x:xs)
    |tags==[]=("none",n)
    |(test_id x tags)/=""=((test_id x tags) , n)
    |xs==[]=("none",(n+1))
    |otherwise=get_id (n+1) tags xs

get_prefix ko
    | ko==[]="M "
    | otherwise="L "

get_empty_list stub n
    | n>=0=get_empty_list (stub++[[""]]) (n-1)
    | otherwise=stub

print_nodes nodes x_min y_max h w diff_x diff_y ko (x:xs)=do
  let node=(find_node x nodes)
  let lat= node_lat node
  let lon= node_lon node
  let x= (lon-x_min)/diff_x*w
  let y= -1*(lat-y_max)/diff_y*h
  let t=ko++(get_prefix ko)++(show x)++","++(show y)++" "
  let ko=t
  if xs/=[] 
  then
      print_nodes nodes x_min y_max h w diff_x diff_y ko  xs
  else
      ko

main=do
  args<-getArgs
  src_ways<-getLine
  src_nodes<-getLine
  let x_min=(read(args!!0))::Float--13.33
  let x_max=(read(args!!1))::Float--13.35643803570664
  let y_min=(read(args!!2))::Float--50.92
  let y_max=(read(args!!3))::Float--50.93
  let diff_x=x_max-x_min
  let diff_y=y_max-y_min
  let h=(read(args!!4))::Float--600
  let w=(read(args!!5))::Float--1000
  let nodes= parse_nodes src_nodes
  let ways= parse_ways src_ways
  let render_keys=drop 6 args--["landuse","leisure","natural","building","amenity","highway","railway","waterway","historic"]
  let svg="<?xml-stylesheet type=\"text/css\" href=\"/assets/test_osm.css?body=1\"?>\n<svg viewBox=\"0 0 "++(show w)++" "++(show h)++"\" xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xml:lang=\"de\">\n\t"
  -- <svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" width=\""++show w++"\" height=\""++show h++"\"><polygon points=\"0,0 "++show w++",0 "++show w++","++show h++" 0,"++show h++"\" style=\"fill:white;stroke:none\"/>\n\t"
  let list=get_empty_list [[""]] ((Prelude.length render_keys)+1)
  let svg1=print_all nodes h w diff_x diff_y x_min y_max list render_keys ways 
  let svg2=get_svg svg svg1
  let svg=svg2++"</svg>"
  putStrLn svg

