require 'rubygems'
require 'prawn'
require 'multi_json'
require 'chronic'


# File IO
# img = File.read(hash['photos'][0]['path'].to_s)
# newimg = File.open("imagecopy.jpeg", "w")
# newimg.write(img)
# newimg.close
# img.close

print "\nInput Filename (default = 'album.json'): "
infile = gets.chomp

print "\nOutput Filename (.pdf): "
outfile = gets.chomp


if infile == ''
  input = "album.json"
else
  input = infile
end


class Doc < Prawn::Document
  # def initialize(input)
  
  # end

  def go(input)
    @hash = MultiJson.load(File.read(input).sub(/^var al = /, '').chomp(";\r\n"))

    @hash['photos'].each_with_index do |photo, i|
      puts "Generating Page #{i.to_s}..."
      makepage(i)
    end
  end

  def makepage(i)
    params = {
      offset:         0,
      caption:        @hash['photos'][i]['name'],
      filepath:       @hash['photos'][i]['path'],
      url:            @hash['photos'][i]['link'],
      date:           (Chronic.parse(@hash['photos'][i]['created_time'])).strftime("%m-%d-%Y"),
    }

    # validate
    if params[:caption] == nil
      params[:caption] = '(No caption)'
    end

    # puts params[:caption]
    # puts params[:filepath]
    # puts params[:url]
    # puts params[:date]


    # group do
      photoblock(i, params)
    # end
  end

  def photoblock(i, params)

    # photo
    image params[:filepath], :position => :center, :fit => [500,500]

    # caption
    move_down 20
    span(400, :position => :center) do
      text params[:caption]
    end

    # title
    pad(20) {
      text "Posted: #{params[:date]}    <u><link href='#{params[:url]}'>View Original</link></u>",
      :inline_format => true, :align => :right
    }

    # move_down 10
    stroke_horizontal_rule
    move_down 10

    start_new_page

  end
end


#input = "album.json"
mypdf = Doc.new
mypdf.go(input)


mypdf.render_file "#{outfile}.pdf"














