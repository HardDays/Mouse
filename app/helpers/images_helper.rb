class ImagesHelper
    def self.download(url)
      if url != nil
          image = Image.new()
          image.base64 = Base64.encode64(open(url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}) { |io| io.read })
          if image.save
              return image
          else
              return nil
          end
      end
    end

end