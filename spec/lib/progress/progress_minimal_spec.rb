require_relative '../../spec_helper'
require_relative '../../../lib/progress/progress_minimal'

describe Progress::ProgressMinimal do

  describe 'initialization' do
    it 'should accept a hash of parameters' do
      progress = Progress::ProgressMinimal.new(param: 1, etc: 'abc')
      expect( progress ).to be_kind_of(Progress::ProgressMinimal)
    end
    it 'should accept an :out parameter' do
      progress = Progress::ProgressMinimal.new(out: :test)
      expect( progress.instance_variable_get(:@out) ).to eq :test
    end
    it 'should default to $stdout for output' do
      progress = Progress::ProgressMinimal.new
      expect( progress.instance_variable_get(:@out) ).to eq $stdout
    end
  end

  describe '#puts' do
    it 'should accept a message' do
      out = double(:out)
      progress = Progress::ProgressMinimal.new(out: out)
      out.should_receive(:puts).with('test')
      progress.puts('test')
    end
  end

  describe '#print' do
    it 'should accept a message' do
      progress = Progress::ProgressMinimal.new
      expect( progress.print('message') ).to be_nil
    end
  end

end
