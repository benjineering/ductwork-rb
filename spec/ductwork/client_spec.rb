Client = Ductwork::Client 

RSpec.describe Client do
  let(:path) { './tmp/dw.fifo' }

  let(:client) { Client.new(path) }

  let(:server) { Server.new(path) }

  let(:timeout) { 500 }

  before(:each) { File.delete(path) if File.exist?(path) }

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
      thread = Thread.new { IO.write(path, 'message') }
      expect(client.open).to be_a IO
      thread.join
    end
  end
end
