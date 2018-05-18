require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class TextcaptchaConfigTest < Minitest::Test

  CONFIG_PATH = './tmp/test/config/textcaptcha.yml'

  def setup
    FileUtils.rm_rf('./tmp/test')
  end

  def test_creates_yaml_config_file_and_path_to_it_from_example_config
    refute File.exists?(CONFIG_PATH)
    refute_nil ActsAsTextcaptcha::TextcaptchaConfig.create_yml_file(CONFIG_PATH)
    assert File.exists?(CONFIG_PATH)

    example_config = YAML.load(File.read(CONFIG_PATH))
    assert_equal example_config.keys, %w(development test production)
  end
end
