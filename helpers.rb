helpers do

  def upload_to_vk(mp3_content, title='Title', artist='Artist')
    require "rest-client"
    mp3_file_tmp = "#{Time.now.strftime('file-%Y%m%d-%H%M%S')}.mp3"
    File.open(mp3_file_tmp, "wb") do |f|
      f << mp3_content
    end
    # upload file
    upload_server = @vk_client.audio.getUploadServer
    res = RestClient.post upload_server["upload_url"], :file => File.new(mp3_file_tmp, "rb")
    if res
      require "crack"
      upload_result = Crack::JSON.parse(res)
      res2 = @vk_client.audio.save(
        :server => upload_result["server"].to_s,
        :audio  => upload_result["audio"].to_s,
        :hash   => upload_result["hash"].to_s,
        :title  => title,
        :artist => artist
      )
    end
    File.delete(mp3_file_tmp)
  end

  def convert_wav2mp3(file_source)
    return nil unless File.exists?(file_source)

    require 'lib/client_convert.rb' 
    # config
    api_key = $config["wav2mp3"]["api_key"]
    service_url = $config["wav2mp3"]["url"]

    options = {}
    options[:api_key] = api_key
    options[:service_url] = service_url

    cc = ClientConverter.new options
    if cc.convert(file_source)
      return cc.result
    end
    nil
  end

  def save_track_from_sc(track, file_path_to)
    url = track.download_url + '?oauth_token='+session[:sc_token]

    require 'open-uri'

    content = nil
    uri = URI.parse(url)
    path = uri.path + '?oauth_token='+session[:sc_token]
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"
    http.start {
      http.request_get(path) {|res|
        if res.response['Location']!=nil
          new_url = res.response['Location']
          content = open(new_url).read
        else
          content = res.body
        end
      }
    }
      
    File.open(file_path_to, 'wb') do |f|
      f << content
    end
  end
end