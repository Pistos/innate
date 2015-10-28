desc 'install dependencies from gemspec'
task :setup => [:gem_setup] do
  GemSetup.new :verbose => false do
    DEPENDENCIES.each do |name, options|
      use_gem(name, options)
    end

    DEVELOPMENT_DEPENDENCIES.each do |name, options|
      use_gem(name, options)
    end
  end
end
