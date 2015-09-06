# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rankforce}
  s.version = "0.3.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["mapserver2007"]
  s.date = %q{2011-07-27}
  s.default_executable = %q{rankforce}
  s.description = %q{rankforce. The tool which social conditions from ikioi of 2ch}
  s.email = %q{mapserver2007@gmail.com}
  s.executables = ["rankforce"]
  s.extra_rdoc_files = ["README.rdoc", "ChangeLog"]
  s.files = ["README.rdoc", "ChangeLog", "Rakefile", "bin/rankforce", "lib/rankforce", "lib/rankforce/crawler.rb", "lib/rankforce/db.rb", "lib/rankforce/tweet.rb", "lib/rankforce/utils.rb", "lib/rankforce.rb", "spec/rankforce_helper.rb", "spec/rankforce_spec.rb"]
  s.homepage = %q{http://github.com/mapserver2007/rankforce3}
  s.rdoc_options = ["--title", "rankforce documentation", "--charset", "utf-8", "--line-numbers", "--main", "README.rdoc", "--inline-source", "--exclude", "^(examples|extras)/"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.rubyforge_project = %q{rankforce3}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{rankforce. The tool which social conditions from ikioi of 2ch}
  s.test_files = ["spec/rankforce_helper.rb", "spec/rankforce_spec.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<parallel_runner>, [">= 0.0.1"])
      s.add_runtime_dependency(%q<twitter>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<sequel>, [">= 3.0.0"])
      s.add_runtime_dependency(%q<sqlite3-ruby>, [">= 1.3.2"])
      s.add_runtime_dependency(%q<mechanize>, [">= 1.0.0"])
    else
      s.add_dependency(%q<parallel_runner>, [">= 0.0.1"])
      s.add_dependency(%q<twitter>, [">= 1.0.0"])
      s.add_dependency(%q<sequel>, [">= 3.0.0"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.2"])
      s.add_dependency(%q<mechanize>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<parallel_runner>, [">= 0.0.1"])
    s.add_dependency(%q<twitter>, [">= 1.0.0"])
    s.add_dependency(%q<sequel>, [">= 3.0.0"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.2"])
    s.add_dependency(%q<mechanize>, [">= 1.0.0"])
  end
end
