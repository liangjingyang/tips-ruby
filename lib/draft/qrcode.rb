module Draft
  class Qrcode
    def self.generate(str)
      return ::RQRCode::QRCode.new(str)
    end

    def self.generate_png(str)
      qrcode = generate(str)
      return qrcode.as_png(
        resize_gte_to: false,
        resize_exactly_to: false,
        fill: 'white',
        color: 'black',
        size: 256,
        border_modules: 1,
        module_px_size: 6,
        file: nil # path to write
        ).to_s
    end
  end
end
