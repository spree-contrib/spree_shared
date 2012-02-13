GraphicUploader.class_eval do
  def store_dir
    # Rails.root.join("app", "theme_assets", model.theme.guid)
    Rails.root.join("public", "spraycan", ENV['RAILS_CACHE_ID'])
  end
end
