module Buildit
end

require 'yaml'
require 'tilt/erubi'
require 'pp'

module Buildit::Configs
  class Base
    def render
      template_name = "#{app_type}.circleci.yml.erb"
      template_path = File.expand_path("templates/#{template_name}", __dir__)
      template = Tilt::ErubiTemplate.new(template_path)
      template.render(self)
    end

    def app_type
      config['type']
    end
  end

  class RubyApp < Base
    attr_reader :app_name, :config

    def initialize(app_name:, config: {})
      @app_name = app_name
      @config = config
    end

    def ruby_version
      @config.fetch 'ruby'
    end
  end

  class RubyGem < Base
    attr_reader :app_name, :config

    def initialize(app_name:, config: {})
      @app_name = app_name
      @config = config
    end

    def ruby_version
      @config.fetch 'ruby'
    end
  end
end

class AppConfig
  attr_reader :app_name, :path

  def initialize(path:)
    @path = path
    @app_name = File.basename(path)
  end

  def render
    config = Helper.constantize(app_type).new(app_name: app_name, config: raw_config)
    config.render
  end

  private

  def app_type
    raw_config['type']
  end

  def raw_config
    @raw_config ||= YAML.load_file(File.join(path, 'buildit.yml'))
  end
end

class Workflow
  attr_reader :app_configs

  def initialize(app_configs:)
    @app_configs = app_configs
  end

  def name
    "all"
  end
end

class WorkflowRenderer
  attr_reader :workflow

  def initialize(workflow)
    @workflow = workflow
  end

  def render
    template_name = "workflow.circleci.yml.erb"
    template_path = File.expand_path("templates/#{template_name}", __dir__)
    template = Tilt::ErubiTemplate.new(template_path)
    template.render(workflow)
  end
end

class Buildit::Runner
  def perform
    dir = ARGV.first || Dir.pwd
    workflow = Workflow.new(app_configs: find_configs(dir))
    Logger.debug workflow, pretty: true
    Logger.info WorkflowRenderer.new(workflow).render
  end

  private

  def find_configs(dir)
    if File.exists?(File.join(dir, 'buildit.yml'))
      [AppConfig.new(path: dir)]
    else
      # Find ./some_project/rocket.yml and extract some_project
      Dir.glob(File.join(dir, '*', 'buildit.yml'))
        .map { |f| File.dirname(f) }
        .map { |path| AppConfig.new(path: path) }
    end
  end
end

module Helper
  def self.constantize(value)
    Buildit::Configs.const_get(
      value.split('_').map(&:capitalize).join
    )
  end
end

module YamlHelper
  def self.indent(content, spaces: 2)
    content.split("\n").map { |l| " " * spaces + l }.join("\n")
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
