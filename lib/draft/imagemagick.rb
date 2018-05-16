module Draft
  class Imagemagick
    def self.generate_box_image(box)
      begin
        composite_dir = File.join(Rails.root, 'tmp', 'composite')
        Dir.mkdir(composite_dir) unless Dir.exists? composite_dir
        assets_dir = File.join(Rails.root, 'vendor', 'composite')
        box_composite_dir = File.join(composite_dir, box.number)
        Dir.mkdir(box_composite_dir) unless Dir.exists? box_composite_dir
        font_path = File.join(assets_dir, 'simhei.ttf')

        qrcode_png = File.join(box_composite_dir, 'qrcode.png')
        icon_png = File.join(box_composite_dir, 'icon.png')
        post_png = File.join(box_composite_dir, 'post.png')
        result_png = File.join(box_composite_dir, 'result.png')


        # Draft::ImageDownload.download(box.qrcode_image, qrcode_png)
        Draft::ImageDownload.download(box.image, qrcode_png)
        Draft::ImageDownload.download(box.user.image, icon_png)
        username = box.user.name
        price = box.price.to_f
        title = box.title
        
        post_image_url = box.posts.first.maybe.images.first.just
        post_image = nil
        if post_image_url
          post_image_png = File.join(box_composite_dir, 'post_image.png')
          post_image = Draft::ImageDownload.download(post_image_url, post_image_png)
          post_image_cmd = "convert -resize 892x412! #{post_image_png} #{post_png}"
          do_system post_image_cmd
        else
          post_content_cmd = """convert -size 892x412 -strip -colors 8 -depth 8 xc:none \\
          \\( -size 792x36 -background none -fill black -font #{font_path} label:'#{box.posts.first.content}' -trim -gravity west -extent 792x36 \\) \\
          -gravity northwest -geometry +50+50 -composite #{post_png}"""
          self.do_system post_content_cmd
        end
        post_cmd = "convert -resize 892x412! -spread 10 -blur 2 #{post_png} #{post_png}"
        self.do_system post_cmd

        icon_cmd = "convert -resize 150x150! #{icon_png} #{icon_png} && convert -size 150x150 xc:none -fill #{icon_png} -draw 'circle 75,75 75,1' #{icon_png}"
        self.do_system icon_cmd

        qrcode_cmd = "convert #{qrcode_png} -resize 200x200 #{qrcode_png}"
        self.do_system qrcode_cmd

        composite_image_cmd = """convert -size 1000x800 -strip -colors 8 -depth 8 xc:none \\
        #{File.join(assets_dir, 'bg-1000-800.png')} -geometry +0+0 -composite \\
        #{File.join(assets_dir, 'head-bg-1000-160.png')} -geometry +0+0 -composite \\
        #{File.join(assets_dir, '50-263-900-420.png')} -geometry +50+263 -composite \\
        #{post_png} -geometry +54+267 -composite \
        #{File.join(assets_dir, 'cover-50-263-900-420.png')} -geometry +50+263 -composite \\
        #{icon_png} -geometry +50+5 -composite \\
        #{qrcode_png} -geometry +400+366 -composite \\
        #{result_png}"""
        self.do_system composite_image_cmd

        composite_text_cmd = "convert #{result_png} \\
        \\( -size 900x70 -background none -fill white -font #{font_path} label:'#{title}' -trim -gravity center -extent 900x70 \\) -gravity northwest -geometry +50+175 -composite \\
        \\( -size 320x36 -background none -fill white -font #{font_path} label:'#{username}' -trim -gravity west -extent 320x36 \\) -gravity northwest -geometry +220+66 -composite \\
        \\( -size 310x72 -background none -fill white label:'#{price}' -trim -gravity east -extent 310x72 \\) -gravity northwest -geometry +570+45 -composite \\
        \\( -size 44x44 -background none -fill white -font #{font_path} label:'元' -trim -gravity west -extent 44x44 \\) -gravity northwest -geometry +896+64 -composite \\
        #{result_png}"
        self.do_system composite_text_cmd

        return result_png
      rescue Exception => e
        LOG_DEBUG("imagemagick composite images error: #{e}")
        return
      end
    end

    def self.do_system(cmd)
      LOG_DEBUG(cmd)
      system cmd
    end
  end

  
end
