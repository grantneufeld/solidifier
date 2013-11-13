require_relative '../spec_helper'
require_relative '../../lib/solidifier/solidifier'
require_relative '../../lib/solidifier/document'

describe 'Solidifier Integration' do

  describe 'creating a solidifier and calling solidify on it' do
    it 'should download the url and any linked sub-urls to the given directory' do
      # stub http access urls
      root_directory = '/tmp/solidifier/spec/integration/solidifier'
      url = 'http://integration.test/download/'
      content = '''<html>
        <head>
        <style>@font-face{src:url("assets/font");}</style>
        <script src="assets/script" />
        <link href="assets/css" rel="stylesheet" type="text/css">
        </head>
        <body>
        <a href="subdir/a.txt#ignore-anchor">A</a>
        <a href="/download/b.txt?ignore=params">B</a>
        <a href="http://integration.test/download/c/">C</a>
        <a href="d">D</a>
        <a href="e">E</a>
        <a href="../different/e.txt">e</a>
        <a href="http://other.test/f.txt">F</a>
        </body></html>
      '''
      content_type = 'text/html'
      stub_request(:get, url).to_return(body: content, headers: { 'Content-Type' => content_type } )
      stub_request(:get, url + 'assets/font').to_return(
        body: '#font', headers: { 'Content-Type' => 'application/font' }
      )
      stub_request(:get, url + 'assets/script').to_return(
        body: '//script', headers: { 'Content-Type' => 'text/javascript' }
      )
      stub_request(:get, url + 'assets/css').to_return(
        body: '/*css*/', headers: { 'Content-Type' => 'text/css' }
      )
      stub_request(:get, url + 'subdir/a.txt').to_return(
        body: 'A', headers: { 'Content-Type' => 'text/plain' }
      )
      stub_request(:get, url + 'b.txt').to_return(body: 'B', headers: { 'Content-Type' => 'text/plain' } )
      stub_request(:get, url + 'c/').to_return(body: 'C', headers: { 'Content-Type' => 'text/html' } )
      stub_request(:get, url + 'd').to_return(body: '<html>D', headers: { 'Content-Type' => 'text/html' } )
      stub_request(:get, url + 'e').to_return(body: 'E', headers: { 'Content-Type' => 'text/plain' } )
      begin
        # Actions
        solidifier = Solidifier::Solidifier.new(root_url: url, root_directory: root_directory)
        solidifier.solidify

        # Expectations
        # File index
        file = File.open( root_directory + '/download/index.html' )
        content = file.read
        file.close
        expect( content ).to eq content
        # File: font
        file = File.open( root_directory + '/download/assets/font' )
        content = file.read
        file.close
        expect( content ).to eq '#font'
        # File: script
        file = File.open( root_directory + '/download/assets/script' )
        content = file.read
        file.close
        expect( content ).to eq '//script'
        # File: css
        file = File.open( root_directory + '/download/assets/css' )
        content = file.read
        file.close
        expect( content ).to eq '/*css*/'
        # File A
        file = File.open( root_directory + '/download/subdir/a.txt' )
        content = file.read
        file.close
        expect( content ).to eq 'A'
        # File B
        file = File.open( root_directory + '/download/b.txt' )
        content = file.read
        file.close
        expect( content ).to eq 'B'
        # File C
        file = File.open( root_directory + '/download/c/index.html' )
        content = file.read
        file.close
        expect( content ).to eq 'C'
        # File D
        file = File.open( root_directory + '/download/d/index.html' )
        content = file.read
        file.close
        expect( content ).to eq '<html>D'
        # File C
        file = File.open( root_directory + '/download/e' )
        content = file.read
        file.close
        expect( content ).to eq 'E'

      ensure
        # Clean up
        FileUtils.remove_dir(root_directory) if File.exist?(root_directory)
      end
    end
  end

end
