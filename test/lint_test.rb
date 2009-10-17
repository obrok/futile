class LintTest < Test::Unit::TestCase
  ALL_FILES = Dir["**/*.rb"]

  def test_trailing_whitespace
    errors = {}
    each_line(ALL_FILES) do |filename, line, index|
      (errors[filename] ||= []) << index if line =~ /\ $/
    end
    assert_lint(errors, "Trailing whitespaces")
  end

  def test_no_tabs_in_files
    errors = {}
    each_line(ALL_FILES) do |filename, line, index|
      (errors[filename] ||= []) << index if line.include?("\t")
    end
    assert_lint(errors, "Tabs in files")
  end

  def test_no_windows_newlines
    errors = {}
    each_line(ALL_FILES) do |filename, line, index|
      (errors[filename] ||= []) << index if line.include?("\r")
    end
    assert_lint(errors, "Windows newline found")
  end

  private
  def each_line(list_of_paths, &block)
    list_of_paths.each do |path|
      File.readlines(path).each_with_index do |line, index|
        yield path, line, index + 1
      end
    end
  end

  def assert_lint(errors, msg)
    assert(errors.empty?, lint_message(errors, msg))
  end

  def lint_message(errors, msg)
    lint_msg = [msg + ":"]
    errors.each do |file, err|
      err.each do |index|
        lint_msg << "\t%s:%d" % [file, index]
      end
    end
    lint_msg.join("\n")
  end
end
