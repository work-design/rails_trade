class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :qiniu

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}"
  end

  def cache_dir
    '/tmp/event_cache'
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    if original_filename
      @name ||= Time.now.getlocal.strftime("%Y%m%d%H%M%S") + SecureRandom.hex(5)
      "#{@name}.#{file.extension}"
    end
  end

end
