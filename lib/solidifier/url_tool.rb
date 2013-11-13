module Solidifier

  # URL utility methods.
  class UrlTool
    attr_reader :path
    attr_reader :source_url
    attr_reader :path_args

    def initialize(params={})
      @path = params[:path]
      # strip any args from the source url
      match = params[:source_url].match /\A([^#\?]+)/
      @source_url = match[1]
      # split the path into the part without args, and the args (if any)
      match = @path.match /\A([^#\?]*)([#\?].*)?\z/
      @path_noargs = match[1]
      @path_args = match[2].to_s
    end

    # Convert a given path to the full url, based on a source url.
    # E.g., path: '/d/e', source_url: 'http://a.b/c.html' converts to 'http://a.b/d/e'
    # path: 'e/f', source_url: 'http://a.b/c/d.html' converts to 'http://a.b/c/e/f'
    # path: '/d/e', source_url: 'http://a.b/c.html' converts to 'http://a.b/d/e'
    def full_url
      if path.match /\A\//
        flatten_root_relative
      elsif path.match /\A[a-z0-9]+:/
        path # it’s already a full url
      else
        flatten_subpath_relative
      end
    end

    # Strip away any “?” arguments or “#” anchors.
    def full_url_no_args
      url = full_url
      match = url.match /\A([^#\?]+)[#\?]/
      if match
        match[1]
      else
        url
      end
    end

    # Is this url a sub-url of the given parent url?
    def contained_in?(parent_url)
      full_url.match /\A#{parent_url}/
    end

    #protected

    # Merge the path (which must be relative to the root) with the root url.
    def flatten_root_relative
      source_root_url + path[1..-1] # strip the leading “/” from the path
    end

    # Merge the path (which is assumed to be relative to the source url’s directory) with the directory url.
    def flatten_subpath_relative
      source_root_url_noslash + resolved_path + path_args
    end

    # The root url of the source url.
    def source_root_url
      match = source_url.match /\A([^:\/]+:[\/]*[^\/]+)/
      match[1] + '/'
    end

    # The root url of the source url.
    def source_root_url_noslash
      match = source_url.match /\A([^:\/]+:[\/]*[^\/]+)/
      match[1]
    end

    # The result of merging the path and the source url’s path.
    # Will handle “../” directory reversal.
    def resolved_path
      File.absolute_path path_noargs, source_directory_path
    end

    # The path part of the source url.
    # E.g., “http://a.b/c/d.html” would return “/c/”
    def source_directory_path
      match = source_url.match /\A[^:]+:\/*[^\/]*(\/.*\/?)[^\/]*\z/
      match = match[1].match /\A(.*\/)[^\/]*\z/
      match[1]
    end

    def path_noargs
      match = path.match /\A([^#\?]*)([#\?].*)?\z/
      match[1]
    end

  end

end
