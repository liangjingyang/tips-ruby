require "open-uri"
module Draft
  class ImageDownload
    def self.download(url, path)
      if url.present?
        download = open url
        bytes_expected = download.meta['content-length']
        bytes_copied = IO.copy_stream download, path
        if bytes_expected == bytes_copied.to_s
          return path
        end
      end
    end
  end
end
