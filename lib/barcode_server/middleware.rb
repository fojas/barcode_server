require 'barcode_server/base'

module BarcodeServer
  class Middleware < Base

    def initialize app, opts
      @app = app
      @path = opts[:path]
    end

    def call env
      get_code(env) || @app.call( env )
    end

  end
end
