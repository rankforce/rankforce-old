# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rankforce}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["mapserver2007"]
  s.date = %q{2010-08-31}
  s.description = %q{rankforce. The tool which social conditions from ikioi of 2ch}
  s.email = %q{mapserver2007@gmail.com}
  s.executables = ["rankforce", "rankforce-migrate", "rankforce-oauth"]
  s.extra_rdoc_files = ["README.rdoc", "ChangeLog"]
  s.files = ["README.rdoc", "ChangeLog", "Rakefile", "bin/rankforce", "bin/rankforce-migrate", "bin/rankforce-oauth", "test/rankforce_test.rb", "test/test_helper.rb", "lib/rankforce", "lib/rankforce/db.rb", "lib/rankforce/log.rb", "lib/rankforce/migrate.rb", "lib/rankforce/register.rb", "lib/rankforce.rb"]
  s.homepage = %q{http://github.com/mapserver2007/rankforce}
  s.rdoc_options = ["--title", "rankforce documentation", "--charset", "utf-8", "--opname", "index.html", "--line-numbers", "--main", "README.rdoc", "--inline-source", "--exclude", "^(examples|extras)/"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{rankforce. The tool which social conditions from ikioi of 2ch}
  s.test_files = ["test/rankforce_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<haml>, [">= 2.2.13"])
      s.add_runtime_dependency(%q<hpricot>, [">= 0.6.164"])
      s.add_runtime_dependency(%q<json>, [">= 1.2.0"])
      s.add_runtime_dependency(%q<rack>, [">= 1.0.1"])
      s.add_runtime_dependency(%q<sequel>, [">= 3.6.0"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0.9.4"])
      s.add_runtime_dependency(%q<twitter>, [">= 0.9.4"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.5"])
    else
      s.add_dependency(%q<haml>, [">= 2.2.13"])
      s.add_dependency(%q<hpricot>, [">= 0.6.164"])
      s.add_dependency(%q<json>, [">= 1.2.0"])
      s.add_dependency(%q<rack>, [">= 1.0.1"])
      s.add_dependency(%q<sequel>, [">= 3.6.0"])
      s.add_dependency(%q<sinatra>, [">= 0.9.4"])
      s.add_dependency(%q<twitter>, [">= 0.9.4"])
      s.add_dependency(%q<activesupport>, [">= 2.3.5"])
    end
  else
    s.add_dependency(%q<haml>, [">= 2.2.13"])
    s.add_dependency(%q<hpricot>, [">= 0.6.164"])
    s.add_dependency(%q<json>, [">= 1.2.0"])
    s.add_dependency(%q<rack>, [">= 1.0.1"])
    s.add_dependency(%q<sequel>, [">= 3.6.0"])
    s.add_dependency(%q<sinatra>, [">= 0.9.4"])
    s.add_dependency(%q<twitter>, [">= 0.9.4"])
    s.add_dependency(%q<activesupport>, [">= 2.3.5"])
  end
end
