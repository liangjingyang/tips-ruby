module Draft
  class Qrcode
    def self.generate(str)
      return ::RQRCode::QRCode.new(str)
    end

    def self.generate_png(str, file=nil)
      qrcode = generate(str)
      return qrcode.as_png(
        resize_gte_to: false,
        resize_exactly_to: 256,
        fill: 'white',
        color: 'black',
        size: 224,
        border_modules: 1,
        module_px_size: 0,
        file: file # path to write
        ).to_s
    end
  end
end
