RSpec.describe Server do
  subject { Server.new(FIFO_PATH) }

  before(:each) do
    File.delete(FIFO_PATH) if File.exist?(FIFO_PATH)
  end

  after(:each) do
    subject.close if subject.open?
  end

  describe '.new' do
    skip 'when no path is passed'

    it 'returns a Server' do
      is_expected.to be_a Server
    end
  end

  describe '#path' do
    it 'returns the full path to the FIFO' do
      expect(subject.path).to eq FIFO_PATH
    end
  end

  describe '#create' do
    it 'creates a FIFO pipe' do
      expect { 
        subject.create(LONG_TIMEOUT) 
      }.to change { 
        File.exist?(FIFO_PATH) 
      }.from(false).to(true)
    end
  end

  describe '#open' do
    before(:each) { subject.create(LONG_TIMEOUT) }

    context "when the pipe isn't opened for reading" do
      it 'raises a timeout error' do
        expect { subject.open(SHORT_TIMEOUT) }.to raise_error TimeoutError
      end

      skip "doesn't open the pipe"
    end

    context 'when the pipe is opened for reading first' do
      it 'returns an open pipe' do
        pipe = nil
        Thread.new { `cat #{FIFO_PATH}` }
        Thread.new { pipe = subject.open }.join
        expect(pipe).to be_a Pipe
      end

      context 'when the pipe is opened for writing first' do
        it 'returns an open pipe', :focus do
          pipe = nil
          thread = Thread.new { pipe = subject.open }
          Thread.new { `cat #{FIFO_PATH}` }          
          thread.join
          expect(pipe).to be_a Pipe
        end
      end

      context 'when a block is passed' do
        skip 'yields an open pipe'

        skip 'closes the pipe when the block closes'
      end
    end
  end

  skip '#open?'

  skip '#close'

  describe '#read' do
    skip 'reads all of the content and closes'
  end

  skip '#write'
end
