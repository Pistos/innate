# -*- encoding: utf-8 -*-
# stub: innate 2025.03.13 ruby lib

Gem::Specification.new do |s|
  s.name = "innate".freeze
  s.version = "2025.03.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael 'manveru' Fellinger".freeze]
  s.date = "2025-03-13"
  s.description = "Simple, straight-forward base for web-frameworks.".freeze
  s.email = "m.fellinger@gmail.com".freeze
  s.files = [".gems".freeze, ".gitignore".freeze, ".load_gemset".freeze, ".rvmrc".freeze, ".travis.yml".freeze, "AUTHORS".freeze, "CHANGELOG".freeze, "COPYING".freeze, "MANIFEST".freeze, "README.md".freeze, "Rakefile".freeze, "example/app/retro_games.rb".freeze, "example/app/todo/layout/default.xhtml".freeze, "example/app/todo/spec/todo.rb".freeze, "example/app/todo/start.rb".freeze, "example/app/todo/view/index.xhtml".freeze, "example/app/whywiki_erb/layout/wiki.html.erb".freeze, "example/app/whywiki_erb/spec/wiki.rb".freeze, "example/app/whywiki_erb/start.rb".freeze, "example/app/whywiki_erb/view/edit.erb".freeze, "example/app/whywiki_erb/view/index.erb".freeze, "example/custom_middleware.rb".freeze, "example/hello.rb".freeze, "example/howto_spec.rb".freeze, "example/link.rb".freeze, "example/provides.rb".freeze, "example/session.rb".freeze, "innate.gemspec".freeze, "lib/innate.rb".freeze, "lib/innate/action.rb".freeze, "lib/innate/adapter.rb".freeze, "lib/innate/cache.rb".freeze, "lib/innate/cache/api.rb".freeze, "lib/innate/cache/drb.rb".freeze, "lib/innate/cache/file_based.rb".freeze, "lib/innate/cache/marshal.rb".freeze, "lib/innate/cache/memory.rb".freeze, "lib/innate/cache/yaml.rb".freeze, "lib/innate/current.rb".freeze, "lib/innate/default_middleware.rb".freeze, "lib/innate/dynamap.rb".freeze, "lib/innate/helper.rb".freeze, "lib/innate/helper/aspect.rb".freeze, "lib/innate/helper/cgi.rb".freeze, "lib/innate/helper/flash.rb".freeze, "lib/innate/helper/link.rb".freeze, "lib/innate/helper/redirect.rb".freeze, "lib/innate/helper/render.rb".freeze, "lib/innate/log.rb".freeze, "lib/innate/log/color_formatter.rb".freeze, "lib/innate/log/hub.rb".freeze, "lib/innate/lru_hash.rb".freeze, "lib/innate/mock.rb".freeze, "lib/innate/node.rb".freeze, "lib/innate/options.rb".freeze, "lib/innate/options/dsl.rb".freeze, "lib/innate/options/stub.rb".freeze, "lib/innate/request.rb".freeze, "lib/innate/response.rb".freeze, "lib/innate/route.rb".freeze, "lib/innate/session.rb".freeze, "lib/innate/session/flash.rb".freeze, "lib/innate/spec.rb".freeze, "lib/innate/spec/bacon.rb".freeze, "lib/innate/state.rb".freeze, "lib/innate/state/accessor.rb".freeze, "lib/innate/traited.rb".freeze, "lib/innate/trinity.rb".freeze, "lib/innate/version.rb".freeze, "lib/innate/view.rb".freeze, "lib/innate/view/erb.rb".freeze, "lib/innate/view/etanni.rb".freeze, "lib/innate/view/none.rb".freeze, "spec/example/app/retro_games.rb".freeze, "spec/example/hello.rb".freeze, "spec/example/link.rb".freeze, "spec/example/provides.rb".freeze, "spec/example/session.rb".freeze, "spec/helper.rb".freeze, "spec/innate/action/layout.rb".freeze, "spec/innate/action/layout/file_layout.xhtml".freeze, "spec/innate/cache/common.rb".freeze, "spec/innate/cache/marshal.rb".freeze, "spec/innate/cache/memory.rb".freeze, "spec/innate/cache/yaml.rb".freeze, "spec/innate/dynamap.rb".freeze, "spec/innate/etanni.rb".freeze, "spec/innate/helper.rb".freeze, "spec/innate/helper/aspect.rb".freeze, "spec/innate/helper/cgi.rb".freeze, "spec/innate/helper/flash.rb".freeze, "spec/innate/helper/link.rb".freeze, "spec/innate/helper/redirect.rb".freeze, "spec/innate/helper/render.rb".freeze, "spec/innate/helper/view/aspect_hello.xhtml".freeze, "spec/innate/helper/view/locals.xhtml".freeze, "spec/innate/helper/view/loop.xhtml".freeze, "spec/innate/helper/view/num.xhtml".freeze, "spec/innate/helper/view/partial.xhtml".freeze, "spec/innate/helper/view/recursive.xhtml".freeze, "spec/innate/mock.rb".freeze, "spec/innate/modes.rb".freeze, "spec/innate/node/mapping.rb".freeze, "spec/innate/node/node.rb".freeze, "spec/innate/node/resolve.rb".freeze, "spec/innate/node/view/another_layout/another_layout.xhtml".freeze, "spec/innate/node/view/bar.xhtml".freeze, "spec/innate/node/view/cat2/cat22.xhtml".freeze, "spec/innate/node/view/cat3/cat33.xhtml".freeze, "spec/innate/node/view/foo.html.xhtml".freeze, "spec/innate/node/view/only_view.xhtml".freeze, "spec/innate/node/view/sub/baz.xhtml".freeze, "spec/innate/node/view/sub/foo/baz.xhtml".freeze, "spec/innate/node/view/with_layout.xhtml".freeze, "spec/innate/node/wrap_action_call.rb".freeze, "spec/innate/options.rb".freeze, "spec/innate/parameter.rb".freeze, "spec/innate/provides.rb".freeze, "spec/innate/provides/list.html.xhtml".freeze, "spec/innate/provides/list.txt.xhtml".freeze, "spec/innate/request.rb".freeze, "spec/innate/response.rb".freeze, "spec/innate/route.rb".freeze, "spec/innate/session.rb".freeze, "spec/innate/traited.rb".freeze, "tasks/authors.rake".freeze, "tasks/bacon.rake".freeze, "tasks/changelog.rake".freeze, "tasks/gem.rake".freeze, "tasks/gem_setup.rake".freeze, "tasks/grancher.rake".freeze, "tasks/manifest.rake".freeze, "tasks/rcov.rake".freeze, "tasks/release.rake".freeze, "tasks/reversion.rake".freeze, "tasks/setup.rake".freeze, "tasks/ycov.rake".freeze]
  s.homepage = "http://github.com/manveru/innate".freeze
  s.rubygems_version = "3.3.20".freeze
  s.summary = "Powerful web-framework wrapper for Rack.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rack>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<bacon>.freeze, ["~> 1.2.0"])
    s.add_development_dependency(%q<rack-test>.freeze, ["~> 0.6.3"])
  else
    s.add_dependency(%q<bacon>.freeze, ["~> 1.2.0"])
    s.add_dependency(%q<rack>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rack-test>.freeze, ["~> 0.6.3"])
    s.add_dependency(%q<rackup>.freeze, ["~> 2.2.1"])
    s.add_dependency(%q<scanf>.freeze, ["~> 1.0.0"])
    s.add_dependency(%q<sorted_set>.freeze, ["~> 1.0.0"])
  end
end
