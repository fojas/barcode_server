require 'barcode_server/base'
require 'barcode_server/middleware'

module BarcodeServer
  class Server < Base

    def initialize opts = {}
      @path = opts[:path] || ''
    end

    def call env
      get_code(env) || not_found_response
    end

  end
end
