module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Process the rubocop results sending inline comments to the Githup PR
  #
  #          rubocop_junit_parser.results_path = 'path/to/results'
  #          rubocop_junit_parser.process
  #
  # @see  Marc Fernandez/danger-rubocop_junit_parser
  # @tags rubocop, inline, javascript
  #
  class DangerRubocopJunitParser < Plugin

    # Path to your json formatted rubocop results
    #
    # @return   [String]
    attr_accessor :results_path

    # Process the rubocop results from the path specified and sends inline
    # comments to the Github PR
    #
    # @return  [void]
    #
    def process
      return if results_path.nil?
      failures.each { |result| send_comment(result) }
    end

  private

    def modified_files
      @modified_files ||= (
        git.modified_files - git.deleted_files
      ) + git.added_files
    end

    def failures
      ::Nokogiri.XML(open(results_path).read).xpath('//failure')
        .map { |failure| RubocopJunitFailure.new(failure: failure) }
        .select { |failure| modified_files.include?(failure.file_path) }
    end

    def send_comment(failure)
      fail(failure.message, file: failure.file_path, line: failure.line)
    end
  end
end
