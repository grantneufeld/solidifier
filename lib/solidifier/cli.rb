require 'optparse'
require_relative 'solidifier'
require_relative '../progress/progress'
require_relative '../progress/progress_minimal'
require_relative '../progress/progress_null'

module Solidifier

  # Command-line interface to run Solidifier.
  class Cli

    # Takes an array of arguments; typically `ARGV` from a command-line call.
    def run(args)
      parse_arguments_to_options(args)

      if options[:help]
        puts parser
        exit
      end

      progress.puts "Solidifying “#{options[:source_url]}” into “#{options[:root_directory]}”..."
      progress.puts "- including assets" if options[:include_assets]
      progress.puts "- respecting robots.txt" if options[:respect_robots]
      progress.puts "- spreading requests" if options[:spread_requests]

      solidifier = Solidifier.new({
        root_url: options[:source_url],
        root_directory: options[:root_directory],
        include_assets: options[:include_assets],
        respect_robots: options[:respect_robots],
        spread_requests: options[:spread_requests],
        progress: progress,
        debug: options[:debug]
      })
      solidifier.solidify
    end

    private

    def parse_arguments_to_options(args)
      leftovers = parser.parse args
      if options[:source_url].nil? || options[:source_url] == ''
        # unless the -u/--url flag is explicitly set,
        # use the first un-flagged command line parameter as the source url
        options[:source_url] = leftovers[0]
      end
      if options[:quiet]
        options[:progress] = options[:debug] = false
      end
      options
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner += ' url'

        opts.separator ""
        opts.on '-h', '--help', '-?', 'Display this usage message' do
          options[:help] = true
        end

        opts.separator ""
        opts.separator "Processing options:"
        opts.on '-u URL', '--url URL', 'The source root url to scrape from' do |source_url|
          options[:source_url] = source_url
        end
        opts.on '-r', '--respect-robots', 'Respect robots restrictions' do
          options[:respect_robots] = true
        end
        opts.on '-s', '--spread', 'Spread out requests to not overload the server' do
          options[:spread_requests] = true
        end
        opts.on '-p', '--progress', 'Show significant progress information messages' do
          options[:progress] = :progress
        end
        opts.on '-v', '--verbose', 'Show all progress information messages (implies -p)' do
          options[:progress] = :verbose
        end
        opts.on '-b', '--debug', 'Show debugging information messages' do
          options[:debug] = true
        end
        opts.on '-q', '--quiet', 'Hide all information messages (overrides -p, -v, -d)' do
          options[:quiet] = true
        end

        opts.separator ""
        opts.separator "Output options:"
        opts.on '-d PATH', '--destination PATH', 'Destination directory (folder) path' do |root_directory|
          options[:root_directory] = root_directory
        end

        opts.separator ""
        opts.separator "Scanning options:"
        opts.on "--[no-]assets", "Include non-html assets" do |do_scan|
          options[:include_assets] = do_scan
        end
      end
    end

    def options
      @options ||= options_defaults
    end

    def options_defaults
      {
        source_url: nil,
        respect_robots: false, spread_requests: false,
        progress: false, debug: false, quiet: false,
        root_directory: '.',
        include_assets: true,
        help: false
      }
    end

    def progress
      unless @progress
        case options[:progress]
        when :progress
          @progress = Progress::ProgressMinimal.new(out: $stderr)
        when :verbose
          @progress = Progress::Progress.new(out: $stderr)
        else
          @progress = Progress::ProgressNull.new
        end
      end
      @progress
    end

  end

end
