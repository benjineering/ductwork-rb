Client = Ductwork::Client 

RSpec.describe Client do
  let(:path) { '/Users/ben/Desktop/dw.fifo' }

  let(:server) { Server.new(path) }

  let(:timeout) { 500 }

  before(:each) { File.delete(path) if File.exist?(path) }

  it 'is a class' do
    expect(Client).to be_a Class
  end

  describe '.new' do
    # check string param is required

    it 'returns a client instance' do
      expect(Client.new('/Users/ben/Desktop/dw.fifo')).to be_a Client
    end
  end

  describe '#open' do
    # TODO: timeout context

    it 'returns an IO' do
      thread = Thread.new { IO.write(path, 'message') }
      expect(server.open).to be_a IO
      thread.join
    end
  end
end
