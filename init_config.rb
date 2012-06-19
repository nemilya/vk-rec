config_path = File.join("config", "conf.yml")

configure :development do
  config_dev_path = File.join("config", "conf.local.yml")
  config_path = config_dev_path if File.exists?(config_dev_path)
end

$config= nil
if File.exists?(config_path)
  $config = YAML.load(File.read(config_path))
end
