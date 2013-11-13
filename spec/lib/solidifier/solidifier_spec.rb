require_relative '../../spec_helper'
require_relative '../../../lib/solidifier/solidifier'
require_relative '../../../lib/solidifier/document'

describe Solidifier::Solidifier do

  let(:root_dir) { '/tmp/solidifier/spec/solidifier' }
  let(:root_url) { 'http://0.0.0.0/' }
  let(:solidifier) { Solidifier::Solidifier.new(root_url: root_url, root_directory: root_dir) }

  describe 'initialization' do
    it 'should accept root_url' do
      solidifier = Solidifier::Solidifier.new(root_url: root_url, root_directory: root_dir)
      expect( solidifier.root_url ).to eq root_url
    end
    it 'should accept root_directory' do
      solidifier = Solidifier::Solidifier.new(root_url: root_url, root_directory: root_dir)
      expect( solidifier.root_directory ).to eq root_dir
    end
    it 'should accept include_assets' do
      solidifier = Solidifier::Solidifier.new(
        root_url: root_url, root_directory: root_dir, include_assets: true
      )
      expect( solidifier.include_assets? ).to be_true
    end
    it 'should accept respect_robots' do
      solidifier = Solidifier::Solidifier.new(
        root_url: root_url, root_directory: root_dir, respect_robots: true
      )
      expect( solidifier.respect_robots? ).to be_true
    end
    it 'should accept spread_requests' do
      solidifier = Solidifier::Solidifier.new(
        root_url: root_url, root_directory: root_dir, spread_requests: true
      )
      expect( solidifier.spread_requests? ).to be_true
    end
    it 'should accept progress' do
      solidifier = Solidifier::Solidifier.new(
        root_url: root_url, root_directory: root_dir, progress: $stderr
      )
      expect( solidifier.progress ).to eq $stderr
    end
    it 'should accept respect_robots' do
      solidifier = Solidifier::Solidifier.new(
        root_url: root_url, root_directory: root_dir, debug: true
      )
      expect( solidifier.debug ).to be_true
    end
  end

  describe '#solidify' do
    it 'should just call through to solidify_page with the root_url' do
      solidifier.stub(:solidify_page)
      solidifier.should_receive(:solidify_page).with(url: root_url)
      solidifier.solidify
    end
  end

  # PROTECTED
  # The following are tests of internal methods that should not be relied on outside the class.

  describe '#solidify_page' do
    let(:root_url) { 'http://0.0.0.0/solidify/' }
    it 'should return the url retrieved' do
      page = double(:page)
      page.stub(:save_in)
      solidifier.stub(:download_document).and_return(page)
      solidifier.stub(:scrape_links_from_document)
      url = solidifier.solidify_page(url: 'page.html', source_url: root_url)
      expect( url ).to eq 'http://0.0.0.0/solidify/page.html'
    end
    it 'should add the url to the scraped_urls' do
      page = double(:page)
      page.stub(:save_in)
      solidifier.stub(:download_document).and_return(page)
      solidifier.stub(:scrape_links_from_document)
      url = solidifier.solidify_page(url: 'page.html', source_url: root_url)
      expect( solidifier.scraped_urls ).to eq ['http://0.0.0.0/solidify/page.html']
    end
  end

  describe '#url_to_be_scraped' do
    let(:root_url) { 'http://0.0.0.0/scrape/' }
    context 'with an url contained in the root' do
      it 'should strip arguments from the url' do
        url = solidifier.url_to_be_scraped(url: 'url.html?with=args#and_anchor', source_url: root_url)
        expect( url ).to eq 'http://0.0.0.0/scrape/url.html'
      end
    end
    context 'with an url outside the root' do
      it 'should return false for a root relative url in a different sub-directory than the source url' do
        url = solidifier.url_to_be_scraped(url: '/outside/root', source_url: root_url)
        expect( url ).to be_false
      end
      it 'should return false for an url on a different domain than the source url' do
        url = solidifier.url_to_be_scraped(url: 'http://different.domain/', source_url: root_url)
        expect( url ).to be_false
      end
    end
    context 'with no source url' do
      it 'should return the url' do
        url = solidifier.url_to_be_scraped(url: 'http://the.url/')
        expect( url ).to eq 'http://the.url/'
      end
    end
  end

  describe '#download_document' do
    let(:root_url) { 'http://solidifier.test/download/' }
    it 'should load the data from the url into a Document object' do
      url = 'http://solidifier.test/download/test.html'
      content = '<html><body><a href="http://solidifier.test/download/more.html"></body></html>'
      content_type = 'text/html'
      stub_request(:get, url).to_return(body: content, headers: { 'Content-Type' => content_type } )
      document = solidifier.download_document(url)
      expect( document.url ).to eq url
      expect( document.content_type ).to eq content_type
      expect( document.content ).to eq content
    end
    it 'should return nil when an HTTP error is encountered' do
      url = 'http://solidifier.test/download/test.html'
      stub_request(:get, url).to_return(status: 403 )
      document = solidifier.download_document(url)
      expect( document ).to be_nil
    end
  end

  describe '#scrape_links_from_document' do
    it 'should call “#solidify_page” for each path in the document' do
      doc = Solidifier::Document.new
      doc.stub(:linked_paths).and_return([:path1, :path2])
      solidifier.stub(:solidify_page)
      solidifier.should_receive(:solidify_page).with(url: :path1, source_url: :source_url)
      solidifier.should_receive(:solidify_page).with(url: :path2, source_url: :source_url)
      solidifier.scrape_links_from_document(document: doc, source_url: :source_url)
    end
  end

end
