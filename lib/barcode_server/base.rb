require 'uri'

require 'barby/outputter/png_outputter'
require 'barby/outputter/cairo_outputter'

module Barby
  autoload :QrCode, 'barby/barcode/qr_code'
  autoload :Code128A, 'barby/barcode/code_128'
  autoload :Code128B, 'barby/barcode/code_128'
  autoload :Code128C, 'barby/barcode/code_128'
  autoload :EAN13, 'barby/barcode/ean_13'
  autoload :UPCA, 'barby/barcode/ean_13'
end

module BarcodeServer

  class Base

    private

    def get_code env
      if env['PATH_INFO'].match(/^#{@path}\//)
        req = Rack::Request.new(env)
        begin
          pathname = unescape(env['PATH_INFO'].to_s.sub(/^#{@path}\//, ''))
          ext = File.extname(pathname)
          path = pathname.sub(/#{ext}$/,'').split('/')

          type = path[0]
          data = req.params['data']
          return ok_response get_outputter(type,data), ext.sub('.',''), env

        rescue NameError
          return not_found_response
        end
      end
      nil
    end

    def get_outputter type, data
      barcode = Barby.const_get("#{code_name(type)}").new(data)
      outputter = Barby::CairoOutputter.new(barcode)

      if 'qr_code' == type
        outputter.xdim = 12
      else
        outputter.xdim = 2
      end

      outputter
    end

    # Returns a 200 OK response tuple
    def ok_response asset, type, env
      asset = 'svg' == type ? asset.to_svg : asset.to_png
      [ 200, headers(env, asset, type, asset.length), [asset] ]
    end

    # Returns a 404 Not Found response tuple
    def not_found_response
      [ 404, { "Content-Type" => "text/plain", "Content-Length" => "9", "X-Cascade" => "pass" }, [ "Not found" ] ]
    end

    def headers env, asset, type, length
      Hash.new.tap do |headers|
        # Set content type and length headers
        headers["Content-Type"]   = type == 'svg' ? 'image/svg+xml' : 'image/png'
        headers["Content-Length"] = length.to_s
      end
    end

    def code_name term
      term = term.to_s.gsub(/(?:^|_)([a-z\d]*)/i) { $1.capitalize }
      return %w{UpcA Ean13}.include?( term )  ? term.upcase : term
    end

    # URI.unescape is deprecated on 1.9. We need to use URI::Parser
    # if its available.
    if defined? URI::DEFAULT_PARSER
      def unescape str
        str = URI::DEFAULT_PARSER.unescape(str)
        str.force_encoding(Encoding.default_internal) if Encoding.default_internal
        str
      end
    else
      def unescape str
        URI.unescape(str)
      end
    end
  end

end
