require 'rubygems'
require 'sinatra'

require 'yaml'

require 'omniauth-soundcloud'
require 'omniauth-vkontakte'

require 'soundcloud'
require 'vk-ruby'

enable :sessions

require 'helpers'

require 'init_config'
require 'init_omniauth'

require 'yajl/json_gem'

before do
  @sc_logged = true if session[:sc_token]
  @vk_logged = true if session[:vk_token]

  @sc_client = Soundcloud.new(:access_token => session[:sc_token]) if session[:sc_token]
  if session[:vk_token]
    @vk_client = VK::Serverside.new :app_id=>$config["vkontakte"]["api_key"], :app_secret=>$config["vkontakte"]["api_secret"], :access_token=>session[:vk_token]
  end

end


get "/auth/vkontakte" do
  session[:vk] = true
  redirect '/'
end

get "/logout" do
  session.delete(:sc_token)
  session.delete(:vk_token)
  redirect '/'
end

get '/' do
  @tracks = []
  if @sc_client
    @tracks = @sc_client.get('/me/tracks')
  end

  erb :index
end

get '/auth/:name/callback' do
  auth_hash = request.env['omniauth.auth']
  if params[:name] == 'soundcloud'
    session[:sc_token] = auth_hash[:credentials][:token]
  elsif params[:name] == 'vkontakte'
    auth_hash = request.env['omniauth.auth']
    session[:vk_token] = auth_hash[:credentials][:token]
    #session[:name] = auth_hash[:info][:name]
  end
  redirect '/'
end

get '/dl/:id' do
  track = @sc_client.get('/tracks/'+params[:id])
  if track && valid_to_vk_track?(track)
    file_name = params[:id].to_i.to_s + '.wav'
    wav_file_path_to = File.join("recs", file_name)

    save_track_from_sc(track, wav_file_path_to)
    mp3_content = convert_wav2mp3(wav_file_path_to)
    File.delete(wav_file_path_to) rescue nil

    upload_to_vk(mp3_content, 'title', 'artisto')
  else
    # track not found
  end
  redirect '/'
end
