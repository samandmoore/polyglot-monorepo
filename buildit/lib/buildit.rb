module Buildit
end

require 'yaml'
require 'tilt/erubi'
require 'pp'

module Buildit::Configs
  class RubyApp
    attr_reader :app_name

    def initialize(app_name:, config: {})
      @app_name = app_name
      @config = config
    end

    def ruby_version
      @config.fetch 'ruby'
    end
  end

  class RubyGem
    attr_reader :app_name

    def initialize(app_name:, config: {})
      @app_name = app_name
      @config = config
    end
  end
end

class Buildit::Runner
  def perform
    find_configs.each do |path|
      Logger.info path
      raw_config = YAML.load_file(File.join(path, 'buildit.yml'))
      Logger.info raw_config
      app_type = raw_config['type']
      app_name = File.basename(path)
      config = constantize(app_type).new(app_name: app_name, config: raw_config)
      template_name = "#{app_type}.circleci.yml.erb"
      template_path = File.expand_path("templates/#{template_name}", __dir__)
      Logger.info template_path
      template = Tilt::ErubiTemplate.new(template_path)
      Logger.info template.render(config)
    end

    # we will wanna do this process for each config file in the repo
    # and then we will need to do some sort of higher level config
    # processing because we need to generate the workflows based
    # on the cross-project dependencies
  end

  private

  def constantize(value)
    Buildit::Configs.const_get(
      value.split('_').map(&:capitalize).join
    )
  end

  def find_configs(dir: Dir.pwd)
    if File.exists?(File.join(dir, 'buildit.yml'))
      [dir]
    else
      # Find ./some_project/rocket.yml and extract some_project
      Dir.glob(File.join(dir, '*', 'buildit.yml'))
        .map { |f| File.dirname(f) }
    end
  end
end

module Logger
  def self.info(message, pretty: false)
    if pretty
      pp message
    else
      puts message
    end
  end

  def self.debug(message, pretty: false)
    log(message, pretty: pretty) if verbose?
  end

  private

  def self.verbose?
    ENV.key? 'VERBOSE'
  end
end
