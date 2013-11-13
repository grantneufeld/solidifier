require 'open-uri'
require_relative '../progress/progress_null'
require_relative 'document'
require_relative 'url_tool'

module Solidifier

  # Pull content from an url and save it locally.
  # Will mirror the directory structure of the url.
  class Solidifier
    attr_reader :root_url
    attr_reader :root_directory
    attr_reader :scraped_urls
    attr_reader :progress
    attr_reader :debug

    def initialize(params={})
      @root_url = params[:root_url]
      @root_directory ||= File.absolute_path(params[:root_directory])
      @scraped_urls = []
      @include_assets = params[:include_assets] || false
      @respect_robots = params[:respect_robots] || false
      @spread_requests = params[:spread_requests] || false
      @progress = params[:progress] || Progress::ProgressNull.new
      @debug = params[:debug] || false
    end

    def solidify
      solidify_page(url: root_url)
    end

    def include_assets?
      @include_assets
    end

    def respect_robots?
      @respect_robots
    end

    def spread_requests?
      @spread_requests
    end

    #protected

    def solidify_page(params={})
      url = params[:url]
      source_url = params[:source_url]
      url = url_to_be_scraped(url: url, source_url: source_url)
      if url
        scraped_urls << url
        document = download_document(url)
        if document
          document.save_in(root_directory)
          scrape_links_from_document(document: document, source_url: url)
        end
        url
      else
        nil
      end
    end

    def url_to_be_scraped(params={})
      url = params[:url]
      source_url = params[:source_url]
      if source_url
        url_tool = UrlTool.new(path: url, source_url: source_url)
        return false unless url_tool.contained_in?(root_url)
        url_noargs = url_tool.full_url_no_args
        return false if scraped_urls.include?(url_noargs)
        url_noargs
      else
        url
      end
    end

    def download_document(url)
      document = nil
      progress.puts "Downloading ‘#{url}’"
      open(url) do |io|
        content_type = io.content_type
        document = Document.new(url: url, content: io.read, content_type: content_type)
      end
      document
    rescue OpenURI::HTTPError
      progress.puts "ERROR: failed to download ‘#{url}’"
      nil
    end

    # scrape any linked urls that fall under the root
    # parameters: :document, :source_url
    def scrape_links_from_document(params={})
      document = params[:document]
      source_url = params[:source_url]
      paths = document.linked_paths
      paths.each do |path|
        solidify_page(url: path, source_url: source_url)
      end
    end

  end

end
