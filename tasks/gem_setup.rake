task :gem_setup do
  class GemSetup
    def initialize(options = {}, &block)
      @gems = []
      @options = options.dup
      @verbose = @options.delete(:verbose)

      run(&block)
    end

    def run(&block)
      return unless block_given?
      instance_eval(&block)
      setup
    end

    def use_gem(name, version = nil, options = {})
      if version.respond_to?(:merge!)
        options = version
      else
        options[:version] = version
      end

      @gems << [name, options]
    end

    # all gems defined, let's try to load/install them
    def setup
      require 'rubygems/commands/install_command'

      @gems.each do |name, options|
        setup_gem(name, options)
      end
    end

    def setup_gemspec(gemspec)
      gemspec.dependencies.each do |dependency|
        dependency.version_requirements.as_list.each do |version|
          use_gem(dependency.name, version)
        end
      end

      setup
    end

    # First try to activate.
    # If activation fails, try to install and activate again.
    # If the second activation also fails, try to require as it may just as
    # well be in $LOAD_PATH.
    def setup_gem(name, options)
      try_require_gem(name, options)
    rescue Exception
      try_installing_gem(name, options)
    end

    def try_require_gem(name, options)
      lib_name = options[:lib] || name
      version = [options[:version]].compact
      gem name, version[0]
      require lib_name
    end

    def try_installing_gem(name, options)
      cmd = Gem::Commands::InstallCommand.new
      version = [options[:version]].compact

      if version.any?
        version.each do |v|
          cmd.handle_options(["--no-ri", "--no-rdoc", "--user-install", name, '--version', v])
          Process.waitpid fork{
            begin
              cmd.execute
            rescue Exception
            end
          }
        end
      else
        cmd.handle_options(["--no-ri", "--no-rdoc", "--user-install", name])
        Process.waitpid fork{
          begin
            cmd.execute
          rescue Exception
          end
        }
      end
    end

    private

    def log(msg)
      return unless @verbose

      if defined?(Log)
        Log.info(msg)
      else
        puts(msg)
      end
    end

    def github; 'http://gems.github.com/' end
  end
end
