RSpec.describe Client do
  let(:path) { './tmp/dw.fifo' }

  let(:client) { Client.new(path) }

  let(:server) { Server.new(path) }

  let(:short_timeout) { 50 }

  let(:timeout) { 2000 }

  before(:each) do
    File.delete(path) if File.exist?(path)
    server.create(timeout)
  end

  it 'is a class' do
    expect(Client).to be_a Class
  end

  describe '.new' do
    # check string param is required

    it 'returns a client instance' do
      expect(client).to be_a Client
    end
  end

  describe '#path' do
    it 'returns the full path to the FIFO' do
      expect(client.path).to eq path
    end
  end

  describe '#open' do
    context "when the pipe isn't opened for reading" do
      it 'raises a timeout error' do
        expect { 
          client.open(short_timeout) 
        }.to raise_error Ductwork::TimeoutError
      end
    end

    context 'when the pipe is already open for reading' do
      it 'returns a pipe' do
        pipe = nil
        Thread.new { `echo p00ts >> #{path}` }
        Thread.new { pipe = client.open(timeout) }.join
        expect(pipe).to be_a Pipe
      end
    end

    context 'when a block is passed' do
      skip 'yields an open pipe'

      skip 'closes the pipe when the block closes'
    end
  end
end
