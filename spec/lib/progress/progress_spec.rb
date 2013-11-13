require_relative '../../spec_helper'
require_relative '../../../lib/progress/progress'

describe Progress::Progress do

  describe 'initialization' do
    it 'should accept a hash of parameters' do
      progress = Progress::Progress.new(param: 1, etc: 'abc')
      expect( progress ).to be_kind_of(Progress::Progress)
    end
    it 'should accept an :out parameter' do
      progress = Progress::Progress.new(out: :test)
      expect( progress.instance_variable_get(:@out) ).to eq :test
    end
    it 'should default to $stdout for output' do
      progress = Progress::Progress.new
      expect( progress.instance_variable_get(:@out) ).to eq $stdout
    end
  end

  describe '#puts' do
    it 'should output the message with a preceding blank line' do
      out = double(:out)
      progress = Progress::Progress.new(out: out)
      out.should_receive(:puts).with('')
      out.should_receive(:puts).with('test')
      progress.puts('test')
    end
  end

  describe '#print' do
    it 'should output a dot' do
      out = double(:out)
      progress = Progress::Progress.new(out: out)
      out.should_receive(:print).with('.')
      progress.print('test')
    end
  end

end
