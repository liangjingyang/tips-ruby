module Draft
  class Imagemagick2
    def self.generate_box_image(box)
      begin
        composite_dir = File.join(Rails.root, 'tmp', 'composite2')
        Dir.mkdir(composite_dir) unless Dir.exists? composite_dir
        assets_dir = File.join(Rails.root, 'vendor', 'composite2')
        box_composite_dir = File.join(composite_dir, box.number)
        Dir.mkdir(box_composite_dir) unless Dir.exists? box_composite_dir
        font_path = File.join(assets_dir, 'simhei.ttf')

        qrcode_png = File.join(box_composite_dir, 'qrcode.png')
        icon_png = File.join(box_composite_dir, 'icon.png')
        post_png = File.join(box_composite_dir, 'post.png')
        result_png = File.join(box_composite_dir, 'result.png')


        user_image = box.user.image
        user_image = 'http://cdn.tips.draftbox.cn/users/1/FoFoVVyi9v0F5-nBpoF7JoTu0VhW.jpg' if user_image.blank?
        Draft::ImageDownload.download(box.qrcode_image, qrcode_png)
        Draft::ImageDownload.download(user_image, icon_png)
        title = box.title.gsub(/"/, '\"')
        username = box.user.name || '小黄人'
        username = username.gsub(/"/, '\"')
        price = box.price.to_f
        
        post_image_url = box.posts.first.maybe.images.first.just
        if post_image_url.present?
          post_image_png = File.join(box_composite_dir, 'post_image.png')
          Draft::ImageDownload.download(post_image_url, post_image_png)
          post_image_cmd = "convert -resize 723x311! #{post_image_png} #{post_png}"
          do_system post_image_cmd
        else
          post_content_cmd = """convert -size 723x311 -strip -colors 256 -depth 8 xc:none \\
          \\( -size 792x36 -background none -fill black -font #{font_path} label:'#{box.posts.first.content}' -trim -gravity west -extent 792x36 \\) \\
          -gravity northwest -geometry +50+50 -composite #{post_png}"""
          self.do_system post_content_cmd
        end
        post_cmd = "convert -resize 723x311! -spread 10 -blur 30x30 #{post_png} #{post_png}"
        self.do_system post_cmd

        icon_cmd = "convert -resize 120x120! #{icon_png} #{icon_png} && convert -size 120x120 xc:none -fill #{icon_png} -draw 'circle 60,60 60,1' #{icon_png}"
        self.do_system icon_cmd

        qrcode_cmd = "convert #{qrcode_png} -resize 198x198 #{qrcode_png}"
        self.do_system qrcode_cmd

        if box.maybe.user.name.just =~ /rdgztest_/
          composite_image_cmd = """convert -size 1000x800 -strip -colors 256 -depth 8 xc:none \\
          #{File.join(assets_dir, 'bg-1000-800.jpg')} -geometry +0+0 -composite \\
          #{post_png} -geometry +140+233 -composite \\
          #{icon_png} -geometry +18+11 -composite \\
          #{result_png}"""
        else
          composite_image_cmd = """convert -size 1000x800 -strip -colors 256 -depth 8 xc:none \\
          #{File.join(assets_dir, 'bg-1000-800.jpg')} -geometry +0+0 -composite \\
          #{post_png} -geometry +140+233 -composite \\
          #{icon_png} -geometry +18+11 -composite \\
          #{File.join(assets_dir, 'qrcode-bg-220-220.png')} -geometry +392+502 -composite \\
          #{qrcode_png} -geometry +403+515 -composite \\
          #{result_png}"""
        end
        
        self.do_system composite_image_cmd

        if price > 0
          composite_text_cmd = """convert #{result_png} \\
          \\( -size 900x48 -background none -fill white -font #{font_path} label:\"#{title}\" -trim -gravity center -extent 900x48 \\) -gravity northwest -geometry +50+170 -composite \\
          \\( -size 320x38 -background none -fill white -font #{font_path} label:\"#{username}\" -trim -gravity west -extent 320x38 \\) -gravity northwest -geometry +160+50 -composite \\
          \\( -size 310x48 -background none -fill white -font #{font_path} label:\"#{price}\" -trim -gravity east -extent 310x48 \\) -gravity northwest -geometry +604+48 -composite \\
          \\( -size 44x44 -background none -fill white -font #{font_path} label:\"元\" -trim -gravity west -extent 44x44 \\) -gravity northwest -geometry +930+52 -composite \\
          #{result_png}"""
        else
          composite_text_cmd = """convert #{result_png} \\
          \\( -size 900x48 -background none -fill white -font #{font_path} label:\"#{title}\" -trim -gravity center -extent 900x48 \\) -gravity northwest -geometry +50+170 -composite \\
          \\( -size 320x38 -background none -fill white -font #{font_path} label:\"#{username}\" -trim -gravity west -extent 320x38 \\) -gravity northwest -geometry +160+50 -composite \\
          \\( -size 360x48 -background none -fill white -font #{font_path} label:\"免费\" -trim -gravity east -extent 360x48 \\) -gravity northwest -geometry +604+48 -composite \\
          #{result_png}"""
        end
        self.do_system composite_text_cmd

        return result_png
      rescue Exception => e
        LOG_DEBUG("imagemagick composite images error: #{e}")
        return
      end
    end

    def self.blur_post_images(box)
      images = box.posts.first.images.first(3)
      return if images.blank?
      composite_dir = File.join(Rails.root, 'tmp', 'composite')
      Dir.mkdir(composite_dir) unless Dir.exists? composite_dir
      box_composite_dir = File.join(composite_dir, box.number)
      Dir.mkdir(box_composite_dir) unless Dir.exists? box_composite_dir
      
      result = []
      index = 0
      images.map do |image_url|
        index = index + 1
        image_path = File.join(box_composite_dir, "post_image_#{index}.png")
        Draft::ImageDownload.download(image_url, image_path)
        cmd = "convert -spread 10 -blur 2 #{image_path} #{image_path}"
        system cmd
        result << image_path
      end
      return result
    end

    def self.do_system(cmd)
      LOG_DEBUG(cmd)
      system cmd
    end
  end

  
end
