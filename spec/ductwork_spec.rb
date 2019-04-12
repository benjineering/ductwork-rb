RSpec.describe Ductwork::Server do
  it 'is a class' do
    expect(Ductwork::Server).to be_a Class
  end

  describe '.new' do
    it "doesn't raise an error" do
      expect { Ductwork::Server.new('/Users/ben/Desktop/dw.fifo') }.not_to raise_error
    end
  end
end
