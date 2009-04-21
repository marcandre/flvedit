# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{flvedit}
  s.version = "0.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marc-Andr\303\251 Lafortune"]
  s.date = %q{2009-04-21}
  s.description = %q{flvedit allows you to: * compute metadata for FLV files * merge, split or cut FLVs * insert / remote cue points or other events  flvedit is meant as a replacement for FLVTool2, FLVMeta, FLVTool++ It can be used as a command line tool or as a ruby library.}
  s.email = %q{github@marc-andre.ca}
  s.executables = ["flvedit", "flvedit"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "CHANGELOG.rdoc",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "bin/flvedit",
    "lib/flv.rb",
    "lib/flv/audio.rb",
    "lib/flv/base.rb",
    "lib/flv/body.rb",
    "lib/flv/edit.rb",
    "lib/flv/edit/options.rb",
    "lib/flv/edit/processor.rb",
    "lib/flv/edit/processor/add.rb",
    "lib/flv/edit/processor/base.rb",
    "lib/flv/edit/processor/command_line.rb",
    "lib/flv/edit/processor/cut.rb",
    "lib/flv/edit/processor/debug.rb",
    "lib/flv/edit/processor/head.rb",
    "lib/flv/edit/processor/join.rb",
    "lib/flv/edit/processor/meta_data_maker.rb",
    "lib/flv/edit/processor/print.rb",
    "lib/flv/edit/processor/printer.rb",
    "lib/flv/edit/processor/reader.rb",
    "lib/flv/edit/processor/save.rb",
    "lib/flv/edit/processor/update.rb",
    "lib/flv/edit/runner.rb",
    "lib/flv/edit/version.rb",
    "lib/flv/event.rb",
    "lib/flv/file.rb",
    "lib/flv/header.rb",
    "lib/flv/packing.rb",
    "lib/flv/tag.rb",
    "lib/flv/timestamp.rb",
    "lib/flv/util/double_check.rb",
    "lib/flv/video.rb",
    "test/fixtures/corrupted.flv",
    "test/fixtures/short.flv",
    "test/fixtures/tags.xml",
    "test/test_flv.rb",
    "test/test_flv_edit.rb",
    "test/test_flv_edit_results.rb",
    "test/test_helper.rb",
    "test/text_flv_edit_results/add_tags.txt",
    "test/text_flv_edit_results/cut_from.txt",
    "test/text_flv_edit_results/cut_key.txt",
    "test/text_flv_edit_results/debug.txt",
    "test/text_flv_edit_results/debug_limited.txt",
    "test/text_flv_edit_results/debug_range.txt",
    "test/text_flv_edit_results/join.txt",
    "test/text_flv_edit_results/print.txt",
    "test/text_flv_edit_results/stop.txt",
    "test/text_flv_edit_results/update.txt"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/marcandre/flvedit}
  s.rdoc_options = ["--charset=UTF-8", "--title", "FLV::Edit", "--main", "README.rdoc", "--line-numbers", "--inline-source"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{flvedit}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Command line tool & library to handle FLV files}
  s.test_files = [
    "test/test_flv.rb",
    "test/test_flv_edit.rb",
    "test/test_flv_edit_results.rb",
    "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<packable>, [">= 1.2"])
      s.add_runtime_dependency(%q<backports>, [">= 0"])
    else
      s.add_dependency(%q<packable>, [">= 1.2"])
      s.add_dependency(%q<backports>, [">= 0"])
    end
  else
    s.add_dependency(%q<packable>, [">= 1.2"])
    s.add_dependency(%q<backports>, [">= 0"])
  end
end
