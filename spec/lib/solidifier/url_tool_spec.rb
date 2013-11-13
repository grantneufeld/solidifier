require_relative '../../spec_helper'
require_relative '../../../lib/solidifier/url_tool'

describe Solidifier::UrlTool do

  let(:path) { $path ||= 'test/path' }
  let(:root_url) { $root_url ||= 'http://0.0.0.0/' }

  describe 'accessors' do
    it 'should accept path' do
      urltool = Solidifier::UrlTool.new(path: path, source_url: root_url)
      expect( urltool.path ).to eq path
    end
    it 'should accept source_url' do
      urltool = Solidifier::UrlTool.new(path: path, source_url: root_url)
      expect( urltool.source_url ).to eq root_url
    end
  end

  describe '#full_url' do
    let(:url) { $url = 'http://test.tld/abc/123.html' }
    it 'should return the path when it is already an url' do
      path = 'http://some.other.site/'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.full_url ).to eq path
    end
    it 'should return the url for the root-relative path' do
      path = '/root/relative.html'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.full_url ).to eq 'http://test.tld/root/relative.html'
    end
    it 'should return the url for the directory-relative path' do
      path = 'path/relative.html'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.full_url ).to eq 'http://test.tld/abc/path/relative.html'
    end
    it 'should return the url for the path with “../” in it' do
      path = '../updir/relative.html'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.full_url ).to eq 'http://test.tld/updir/relative.html'
    end
    it 'should return the url for the root-relative path with arguments and hash' do
      path = '/root/arguments.html?arg=1&arg2=two#with-hash'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.full_url ).to eq 'http://test.tld/root/arguments.html?arg=1&arg2=two#with-hash'
    end
    it 'should return the url for the path with arguments and hash' do
      path = 'with/arguments.html?arg=1&arg2=two#with-hash'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.full_url ).to eq 'http://test.tld/abc/with/arguments.html?arg=1&arg2=two#with-hash'
    end
  end

  describe '#full_url_no_args' do
    let(:url) { $url = 'http://test.tld/def/456.test' }
    it 'should return the full url if there are no arguments or hash' do
      path = 'path/without/args'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.full_url_no_args ).to eq 'http://test.tld/def/path/without/args'
    end
    it 'should return the full url without the arguments' do
      path = '/path/with/args?has=args'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.full_url_no_args ).to eq 'http://test.tld/path/with/args'
    end
    it 'should return the full url without the hash' do
      path = '/path/has/hash#a-hash'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.full_url_no_args ).to eq 'http://test.tld/path/has/hash'
    end
    it 'should return the full url without the arguments and hash' do
      path = 'http://full.url/with/both?args=and#hash'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.full_url_no_args ).to eq 'http://full.url/with/both'
    end
  end

  describe '#contained_in?' do
    it 'should return true when the path and url are under the given url' do
      path = '/path/subdir/'
      urltool = Solidifier::UrlTool.new(path: path, source_url: root_url)
      expect( urltool.contained_in?(root_url) ).to be_true
    end
    it 'should return false when the path uses “../” that take it out of the parent' do
      url = 'http://test.tld/subdir/'
      path = '../baddir/file.test'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      x = urltool.contained_in?(url)
      expect( urltool.contained_in?(url) ).to be_false
    end
    it 'should return true when the path uses “../” but is still under the parent' do
      url = 'http://test.tld/subdir/'
      path = '../another/directory/file.test'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.contained_in?('http://test.tld/') ).to be_true
    end
    it 'should return false when the source url is different than the given url' do
      url = 'https://another.server/'
      path = '/path/file.name'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.contained_in?(root_url) ).to be_false
    end
  end

  # PROTECTED
  # The following are tests of internal methods that should not be relied on outside the class.

  describe '#flatten_root_relative' do
    it 'should append the path to the root of the url' do
      url = 'http://test.tld/subdir/source.file'
      path = '/path/file.name'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.flatten_root_relative ).to eq 'http://test.tld/path/file.name'
    end
  end

  describe '#flatten_subpath_relative' do
    it 'should append the path to the subdirectory of the url' do
      url = 'http://test.tld/subdir/source.file'
      path = 'path/file.name'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.flatten_subpath_relative ).to eq 'http://test.tld/subdir/path/file.name'
    end
    it 'should append the path containing “../” to the url resolved' do
      url = 'http://test.tld/subdir/source.file'
      path = '../path/file.name'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.flatten_subpath_relative ).to eq 'http://test.tld/path/file.name'
    end
  end

  describe '#source_root_url' do
    it 'should return the url when given a site root url' do
      url = 'http://example.root/'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.source_root_url ).to eq url
    end
    it 'should return the root url when given an url with a filename' do
      url = 'https://test.root/with.file'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.source_root_url ).to eq 'https://test.root/'
    end
    it 'should return the root url when given an url with a sub-directory' do
      url = 'https://test.url/with/directory/'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.source_root_url ).to eq 'https://test.url/'
    end
    it 'should return the root url when given an url with a sub-directory and filename' do
      url = 'http://example.url/with/sub/directory/with.file'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.source_root_url ).to eq 'http://example.url/'
    end
  end

  describe '#source_root_url_noslash' do
    it 'should return the root url without trailing slash' do
      url = 'http://a.b/c/d.html'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.source_root_url_noslash ).to eq 'http://a.b'
    end
  end

  describe '#resolved_path' do
    it 'should return “/” when the source url is root and the path is empty' do
      path = ''
      urltool = Solidifier::UrlTool.new(path: path, source_url: root_url)
      expect( urltool.resolved_path ).to eq '/'
    end
    it 'should upshift a path containing “../”' do
      path = '../../upshifted/file.path'
      url = 'http://test.tld/abc/123/url.file'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.resolved_path ).to eq '/upshifted/file.path'
    end
  end

  describe '#source_directory_path' do
    it 'should return the directory path from the url' do
      url = 'http://abc.def/ghi/jkl.html'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.source_directory_path ).to eq '/ghi/'
    end
    it 'should return “/” when given a root url' do
      url = 'http://abc.def/'
      urltool = Solidifier::UrlTool.new(path: path, source_url: url)
      expect( urltool.source_directory_path ).to eq '/'
    end
  end

  describe '#path_noargs' do
    it 'should return the path when it has no args' do
      path = '/abc/123.html'
      urltool = Solidifier::UrlTool.new(path: path, source_url: root_url)
      expect( urltool.path_noargs ).to eq path
    end
    it 'should return the path without the args' do
      path = '/def/456.html?arg=something&arg2=other'
      urltool = Solidifier::UrlTool.new(path: path, source_url: root_url)
      expect( urltool.path_noargs ).to eq '/def/456.html'
    end
    it 'should return the path without the hash' do
      path = '/g/7.pic#some-anchor'
      urltool = Solidifier::UrlTool.new(path: path, source_url: root_url)
      expect( urltool.path_noargs ).to eq '/g/7.pic'
    end
    it 'should return the path without the args and hash' do
      path = '/hijk/8/9/10.etc?x=y&foo=bar#anchor-me-this'
      urltool = Solidifier::UrlTool.new(path: path, source_url: root_url)
      expect( urltool.path_noargs ).to eq '/hijk/8/9/10.etc'
    end
  end

end
