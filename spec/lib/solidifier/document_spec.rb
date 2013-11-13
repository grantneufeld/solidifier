require_relative '../../spec_helper'
require_relative '../../../lib/solidifier/document'
require 'fileutils'

describe Solidifier::Document do

  let(:url) { $url = 'http://document.tld/' }
  let(:content) { $content = '<html><head><title>Document</title></head><body>Content.</body></html>' }
  let(:html_content_type) { $html_content_type = 'text/html' }

  describe 'initialization' do
    it 'should accept an url parameter' do
      url = 'http://initialization.param/'
      doc = Solidifier::Document.new(url: url)
      expect( doc.url ).to eq url
    end
    it 'should accept a content parameter' do
      content = 'initialization parameter'
      doc = Solidifier::Document.new(content: content)
      expect( doc.content ).to eq content
    end
    it 'should accept a content_type parameter' do
      content_type = 'test/init'
      doc = Solidifier::Document.new(content_type: content_type)
      expect( doc.content_type ).to eq content_type
    end
  end

  describe '#linked_paths' do
    it 'should return the “paths_from_content”' do
      doc = Solidifier::Document.new(content: content)
      doc.stub(:paths_from_content).and_return(:expected_paths)
      expect( doc.linked_paths ).to eq :expected_paths
    end
  end

  describe '#save_in' do
    let(:root_directory) { $root_directory = '/tmp/solidifier/spec/document/save_in/' }
    after(:each) do
      FileUtils.remove_dir(root_directory) if File.exist?(root_directory)
    end
    let(:url) { $url = 'http://doc.tld/dir/save.txt' }
    let(:doc) do
      $doc = Solidifier::Document.new(url: url, content: 'This is a test.', content_type: 'text/plain')
    end
    context 'with a valid path in the url' do
      it 'should return the filepath' do
        FileUtils.stub(:mkdir_p)
        File.stub(:open)
        filepath = doc.save_in(root_directory)
        expect( filepath ).to eq '/tmp/solidifier/spec/document/save_in/dir/save.txt'
      end
      it 'should create a file with a name that matches the url’s filename' do
        filepath = doc.save_in(root_directory)
        expect( File.exist?('/tmp/solidifier/spec/document/save_in/dir/save.txt') ).to be_true
      end
      it 'should create a file with the given content' do
        filepath = doc.save_in(root_directory)
        file_content = nil
        File.open('/tmp/solidifier/spec/document/save_in/dir/save.txt', 'r') do |file|
          file_content = file.read
        end
        expect( file_content ).to eq 'This is a test.'
      end
    end
    context 'with an invalid path in the url' do
      let(:url) { $url = 'http://doc.tld/../bad-dir/save.txt' }
      it 'should return the filepath' do
        FileUtils.stub(:mkdir_p)
        File.stub(:open)
        expect{ doc.save_in(root_directory) }.to raise_error
      end
    end
  end

  describe '#url_file_path' do
    it 'should extract the path from the url' do
      doc = Solidifier::Document.new(url: 'http://doc.tld/directory/path.file')
      expect( doc.url_file_path ).to eq 'directory/path.file'
    end
    it 'should extract the path from the root-relative url' do
      doc = Solidifier::Document.new(url: '/directory/path.file')
      expect( doc.url_file_path ).to eq 'directory/path.file'
    end
    it 'should extract the path from the relative url' do
      doc = Solidifier::Document.new(url: 'directory/path.file')
      expect( doc.url_file_path ).to eq 'directory/path.file'
    end
    it 'should return a blank string when given a root url' do
      doc = Solidifier::Document.new(url: 'http://doc.tld/')
      expect( doc.url_file_path ).to eq ''
    end
    it 'should return a blank string when given a blank url' do
      doc = Solidifier::Document.new(url: 'http://doc.tld/')
      expect( doc.url_file_path ).to eq ''
    end
    it 'should return a blank string when given a blank url' do
      doc = Solidifier::Document.new(url: '')
      expect( doc.url_file_path ).to eq ''
    end
  end

  describe '#directory_path' do
    it 'should return the directory portion of the path from the url' do
      doc = Solidifier::Document.new(url: 'http://doc.tld/directory/path.file')
      expect( doc.directory_path ).to eq 'directory/'
    end
  end

  describe '#filename' do
    context 'with a directory url' do
      it 'should return “index.html”' do
        doc = Solidifier::Document.new(url: 'http://doc.tld/directory/')
        expect( doc.filename ).to eq 'index.html'
      end
    end
    context 'with a filename without extension' do
      context 'with html content_type' do
        
      end
      context 'with non-html content_type' do
      end
    end
    context 'with a filename with extension' do
      it 'should return the filename from the url' do
        url = 'http://doc.tld/file.name'
        doc = Solidifier::Document.new(url: url)
        expect( doc.filename ).to eq 'file.name'
      end
    end
  end

  # PROTECTED
  # The following are tests of internal methods that should not be relied on outside the class.

  describe '#filename_for_directory' do
    it 'should return “index.html”' do
      doc = Solidifier::Document.new
      expect( doc.filename_for_directory ).to eq 'index.html'
    end
  end

  describe '#filename_for_file' do
    it 'should return the filename from the url' do
      url = 'http://document.tld/subdir/filename.test'
      doc = Solidifier::Document.new(url: url)
      expect( doc.filename_for_file ).to eq 'filename.test'
    end
    it 'should treat it as a directory if there is no filename extension and the content is html' do
      url = 'http://document.tld/subdir/filename'
      doc = Solidifier::Document.new(url: url, content_type: html_content_type)
      expect( doc.filename_for_file ).to eq 'filename/index.html'
    end
    it 'should return the filename if there is no filename extension and the content is not html' do
      url = 'http://document.tld/subdir/filename'
      doc = Solidifier::Document.new(url: url, content_type: 'text/not-html')
      expect( doc.filename_for_file ).to eq 'filename'
    end
  end

  describe '#guess_content_type' do
    it 'should raise an exception if the content is nil' do
      doc = Solidifier::Document.new
      expect{ doc.guess_content_type }.to raise_error
    end
    it 'should return nil if the content is blank' do
      doc = Solidifier::Document.new(content: '')
      expect( doc.guess_content_type ).to be_nil
    end
    it 'should guess html if the first character of the content is “<”' do
      doc = Solidifier::Document.new(content: '<!doctype html>')
      expect( doc.guess_content_type ).to eq 'text/html'
    end
    it 'should return nil if the content does not start with “<”' do
      doc = Solidifier::Document.new(content: 'not html')
      expect( doc.guess_content_type ).to be_nil
    end
  end

  describe '#paths_from_content' do
    it 'should return an empty array when content is empty' do
      doc = Solidifier::Document.new(content: '')
      expect( doc.paths_from_content ).to eq []
    end
    it 'should return an empty array when content does not have any links' do
      doc = Solidifier::Document.new(content: '<a name="not a link">Nope</a><img alt="has no src" />')
      expect( doc.paths_from_content ).to eq []
    end
    it 'should return an array of links when content has links' do
      doc = Solidifier::Document.new(content: '<a href="A">Eh</a><img src="B" />')
      expect( doc.paths_from_content ).to eq ['A', 'B']
    end
    it 'should find CSS url links' do
      content = '<style>@font-face{src:url("assets/font");}</style>'
      doc = Solidifier::Document.new(content: content)
      expect( doc.paths_from_content ).to eq ['assets/font']
    end
  end

end
