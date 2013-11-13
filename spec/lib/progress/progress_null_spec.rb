require_relative '../../spec_helper'
require_relative '../../../lib/progress/progress_null'

describe Progress::ProgressNull do

  describe 'initialization' do
    it 'should accept a hash of parameters' do
      progress = Progress::ProgressNull.new(param: 1, etc: 'abc')
      expect( progress ).to be_kind_of(Progress::ProgressNull)
    end
  end

  describe '#puts' do
    it 'should accept a message' do
      progress = Progress::ProgressNull.new
      expect( progress.puts('message') ).to be_nil
    end
  end

  describe '#print' do
    it 'should accept a message' do
      progress = Progress::ProgressNull.new
      expect( progress.print('message') ).to be_nil
    end
  end

  describe '#nil?' do
    it 'should return true' do
      progress = Progress::ProgressNull.new
      expect( progress.nil? ).to be_true
    end
  end

end
