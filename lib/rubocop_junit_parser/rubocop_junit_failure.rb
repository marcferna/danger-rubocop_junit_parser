class RubocopJunitFailure
  attr_accessor :line, :severity, :message, :file_path

  def initialize(failure:, path: Dir.pwd)
    file_matches = failure.children.first.text.strip.match(file_path_regex)
    self.file_path = file_matches[1].gsub("#{path}/", '')
    self.message = failure.attributes['message'].value
    self.line = file_matches[2].to_i
  end

private

  def file_path_regex
    /(.*):(\d+):(\d+)/
  end

end
