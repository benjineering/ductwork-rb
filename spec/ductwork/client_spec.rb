RSpec.describe Client do
  let(:path) { './tmp/dw.fifo' }

  let(:client) { Client.new(path) }

  let(:server) { Server.new(path) }

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
    # TODO: timeout context

    it 'returns an IO' do
      pipe = nil
      Thread.new { `echo message >> #{path}` }
      client_thread = Thread.new { pipe = client.open(timeout) }
      client_thread.join
      expect(pipe).to be_a Pipe
    end
  end
end
