RSpec.describe Client do
  subject { Client.new(FIFO_PATH) }

  before(:each) do
    File.delete(FIFO_PATH) if File.exist?(FIFO_PATH)
    Server.new(FIFO_PATH).create(LONG_TIMEOUT)
  end

  after(:each) do
    subject.close if subject.open?
  end

  describe '.new' do
    skip 'when no path is passed'

    it 'returns a client instance' do
      is_expected.to be_a Client
    end
  end

  describe '#path' do
    it 'returns the full path to the FIFO' do
      expect(subject.path).to eq FIFO_PATH
    end
  end

  describe '#open' do
    context "when the pipe isn't opened for writing" do
      it 'raises a timeout error' do
        expect { subject.open(SHORT_TIMEOUT) }.to raise_error TimeoutError
      end

      skip "doesn't open the pipe"
    end

    context 'when the pipe is opened for reading first' do
      it 'returns a pipe' do
        pipe = nil
        thread = Thread.new { pipe = subject.open(LONG_TIMEOUT) }
        `echo p00t >> #{FIFO_PATH}`
        thread.join
        expect(pipe).to be_a Pipe
      end
    end

    context 'when the pipe is opened for writing first' do
      it 'returns a pipe' do
        thread = Thread.new { `echo p00t >> #{FIFO_PATH}` }
        pipe = subject.open(LONG_TIMEOUT)
        thread.join
        expect(pipe).to be_a Pipe
      end
    end

    context 'when a block is passed' do
      skip 'yields an open pipe'

      skip 'closes the pipe when the block closes'
    end
  end

  describe '#open?' do
    context 'when client is open' do
      it 'returns true' do
        thread = Thread.new { subject.open(LONG_TIMEOUT) }
        `echo p00t >> #{FIFO_PATH}`
        thread.join
        expect(subject.open?).to be true
      end
    end

    context "when client isn't open" do
      it 'returns false' do
        expect(subject.open?).to be false
      end
    end
  end

  skip '#close'

  skip '#read'
end
