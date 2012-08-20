require 'barcode_server/server'
require 'rspec'
require 'rack/test'
require 'nokogiri'

describe 'BarcodeServer::Server' do
  include Rack::Test::Methods

  def app
    Rack::Builder.new do
      map "/" do
        run BarcodeServer::Server.new
      end
    end
  end

  context "Code 128 B" do
    context "default format" do
      before :each do
        get '/code_128_b?data=hello'
      end

      it "should be ok" do
        last_response.should be_ok
      end

      it "should be in Code 128 B" do
        last_response.body.hash.should == get_output(Barby::Code128B.new('hello'),2).hash
      end
    end

    context "png format" do
      before :each do
        get '/code_128_b.png?data=hello'
      end

      it "should be ok" do
        last_response.should be_ok
      end

      it "should be in Code 128 B" do
        last_response.body.hash.should == get_output(Barby::Code128B.new('hello'),2).hash
      end
    end

    context "svg format" do
      before :each do
        get '/code_128_b.svg?data=hello'
      end

      it "should be ok" do
        last_response.should be_ok
      end

      it "should be in Code 128 B" do
        response = Nokogiri::XML last_response.body
        expected = Nokogiri::XML get_output(Barby::Code128B.new('hello'),2,'svg')
        response.css('path').first['d'].should_not be_nil
        response.css('path').first['d'].should == expected.css('path').first['d']
      end
    end
  end

  context "Qr Code" do
    before :each do
      get '/qr_code?data=hello'
    end

    it "should be ok" do
      last_response.should be_ok
    end

    it "should be a QR Code" do
      last_response.body.hash.should == get_output(Barby::QrCode.new('hello'),12).hash
    end
  end

  context "UPC A" do
    before :each do
      get '/upc_a?data=12345612345'
    end

    it "should be ok" do
      last_response.should be_ok
    end

    it "should be a QR Code" do
      last_response.body.hash.should == get_output(Barby::UPCA.new('12345612345'),2).hash
    end
  end

  context "EAN 13" do
    before :each do
      get '/ean_13?data=123456123456'
    end

    it "should be ok" do
      last_response.should be_ok
    end

    it "should be a QR Code" do
      last_response.body.hash.should == get_output(Barby::EAN13.new('123456123456'),2).hash
    end
  end

  context "invalid type" do
    before :each do
      get '/konami_code'
    end

    it "should be 404" do
      last_response.status.should == 404
    end
  end

  def get_output(code, xdim, format = 'png')
    output = Barby::CairoOutputter.new(code)
    output.xdim = xdim
    'svg' == format ? output.to_svg : output.to_png
  end
end
