configure :development do
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end

use OmniAuth::Builder do
  if $config["soundcloud"]
    provider :soundcloud, 
      $config["soundcloud"]["client_id"], 
      $config["soundcloud"]["secret"]
  end

  if $config["vkontakte"]
    provider :vkontakte, 
      $config["vkontakte"]["api_key"], 
      $config["vkontakte"]["api_secret"],
      :scope => 'friends,audio,photos', 
      :display => 'popup'
    end
end

