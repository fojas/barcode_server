require 'barcode_server/middleware'
require 'rspec'

describe 'BarcodeServer::Middleware' do

  before :each do
    inner_app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['Howdy']] }
    @app = BarcodeServer::Middleware.new(inner_app, :path => "/foo")
  end

  context "Code 128 B" do
    context "default format" do
      before :each do
        @status, @headers, @body = @app.call(Rack::MockRequest.env_for('/foo/code_128_b?data=hello'))
      end

      it "should be ok" do
        @status.should be 200
      end

      it "should be in Code 128 B" do
        @body.hash.should == get_output(Barby::Code128B.new('hello'),2).hash
      end
    end

    context "png format" do
      before :each do
        @status, @headers, @body = @app.call(Rack::MockRequest.env_for('/foo/code_128_b.png?data=hello'))
      end

      it "should be ok" do
        @status.should be 200
      end

      it "should be in Code 128 B" do
        @body.hash.should == get_output(Barby::Code128B.new('hello'),2).hash
      end
    end

    context "svg format" do
      before :each do
        @status, @headers, @body = @app.call(Rack::MockRequest.env_for('/foo/code_128_b.svg?data=hello'))
      end

      it "should be ok" do
        @status.should be 200
      end

      it "should be in Code 128 B" do
        response = Nokogiri::XML @body.first
        expected = Nokogiri::XML get_output(Barby::Code128B.new('hello'),2,'svg').first
        response.css('path').first['d'].should_not be_nil
        response.css('path').first['d'].should == expected.css('path').first['d']
      end
    end
  end

  context "Qr Code" do
    before :each do
      @status, @headers, @body = @app.call(Rack::MockRequest.env_for('/foo/qr_code?data=hello'))
    end

    it "should be ok" do
      @status.should be 200
    end

    it "should be a QR Code" do
      @body.hash.should == get_output(Barby::QrCode.new('hello'),12).hash
    end
  end

  context "UPC A" do
    before :each do
      @status, @headers, @body = @app.call(Rack::MockRequest.env_for('/foo/upc_a?data=12345612345'))
    end

    it "should be ok" do
      @status.should be 200
    end

    it "should be a QR Code" do
      @body.hash.should == get_output(Barby::UPCA.new('12345612345'),2).hash
    end
  end

  context "EAN 13" do
    before :each do
      @status, @headers, @body = @app.call(Rack::MockRequest.env_for('/foo/ean_13?data=123456123456'))
    end

    it "should be ok" do
      @status.should be 200
    end

    it "should be a QR Code" do
      @body.hash.should == get_output(Barby::EAN13.new('123456123456'),2).hash
    end
  end

  context "invalid type" do
    before :each do
      @status, @headers, @body = @app.call(Rack::MockRequest.env_for('/foo/konami_code'))
    end

    it "should be 404" do
      @status.should == 404
    end
  end

  context "unmatched path" do

    before :each do
      @status, @headers, @body = @app.call(Rack::MockRequest.env_for('/food/konami_code'))
    end

    it "should be ok" do
      @status.should be 200
    end

    it "should pass through" do
      @body.should == ["Howdy"]
    end
  end
  def get_output(code, xdim, format = 'png')
    output = Barby::CairoOutputter.new(code)
    output.xdim = xdim
    ['svg' == format ? output.to_svg : output.to_png]
  end
end
