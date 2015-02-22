class PictureUploader < BaseUploader

  VIEWS = {
    none: "",
    model0: "imageView2/0/w/%s/h/%s",
    model1: "imageView2/1/w/%s/h/%s",
    model1w: "imageView2/1/w/%s",
    model2: "imageView2/2/w/%s/h/%s",
    model2w: "imageView2/2/w/%s",
    model3: "imageView2/3/w/%s/h/%s",
    model4: "imageView2/4/w/%s/h/%s",
    model5: "imageView2/5/w/%s/h/%s"
  }

  WIDTHS = {
    nil => 100,
    thumb: 88,
    l: 640,
    xl: 750,
    xxl: 1242
  }

  def item_url
    image_view = VIEWS[:model1w] % [WIDTHS[nil]]
    [url, '?', image_view].join
  end


end
