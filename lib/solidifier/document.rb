require 'fileutils'

module Solidifier

  # Container for a retrieved document’s data.
  class Document
    attr_reader :url
    attr_reader :content
    attr_reader :content_type

    # expects :url to be stripped of arguments and anchors (everything after, and including, '?' or '#')
    def initialize(params={})
      @url = params[:url]
      @content = params[:content]
      @content_type = params[:content_type] || (@content ? guess_content_type : nil)
      @url_file_path = nil
      @directory_path = nil
      @filename = nil
    end

    def linked_paths
      @linked_paths ||= paths_from_content
    end

    # write out the content as a file under the given directory
    def save_in(root_directory)
      directory = File.absolute_path(directory_path, root_directory)
      path = File.absolute_path(filename, directory)
      # ensure that the file_path is within the root_directory, in case there are '../' portions in the path
      unless path.to_s.match /\A#{root_directory}/
        raise "destination file path “#{path}” does not match containing directory #{root_directory}"
      end
      # ensure the destination directory exists:
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'w') do |file|
        file.write(content)
      end
      path
    end

    # the path from the url, without the protocol and domain parts,
    # and without the leading `/`
    def url_file_path
      return @url_file_path if @url_file_path
      url_parts = url.match /\A[^:]+:\/*[^\/]+\/(?<path_portion>.*)/
      url_parts = url.match /\A\/?(?<path_portion>.*)/ unless url_parts
      @url_file_path = url_parts[:path_portion]
    end

    # the path from the url, without the filename
    def directory_path
      @directory_path ||= url_file_path.sub /([^\/]*)\z/, ''
    end

    # determine the filename based on the url and content_type
    def filename
      return @filename if @filename
      is_directory = url.match /\/\z/
      if is_directory
        @filename = filename_for_directory
      else
        @filename = filename_for_file
      end
      @filename
    end

    #protected

    # It’s a directory, so use an index.html file.
    def filename_for_directory
      # TODO: use different extensions for non-html files
      'index.html'
    end

    # Must be called with a string that does not end in “/”.
    def filename_for_file
      match = url.match /(?<name>[^\/]+)\z/
      name = match[:name]
      if name.match /\./
        # has an extension
        # TODO: maybe override with `.html` if type is text/html (so we don't end up with .php etc.)
      else
        # filename doesn’t have an extension
        if content_type == 'text/html'
          name += '/index.html'
        end
        # TODO: handle adding file extensions for non-html content types
      end
      name
    end

    def guess_content_type
      # FIXME: add more smarts about guessing the content type, check for a file extension
      # check for tag at the start of the content, assume html
      if content[0] == '<'
        'text/html'
      else
        nil
      end
    end

    def paths_from_content
      content_paths = []
      content.scan(/<[^>]+ (?:href|src)=["']([^"'>]+)["'][^>]*>/) do |path|
        content_paths += path
      end
      content.scan(/[^A-Za-z0-9_\-]src:[ \t\r\n]*url[ \t\r\n]*\([ \t\r\n]*['"]([^'"]+)['"]/) do |path|
        content_paths += path
      end
      content_paths
    end

  end

end
