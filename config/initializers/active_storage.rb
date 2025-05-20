# Configure ActiveStorage for proper image processing
Rails.application.config.active_storage.variant_processor = :mini_magick

# Set content types that should be analyzed
Rails.application.config.active_storage.content_types_to_serve_as_binary = %w[
  image/svg+xml
  image/svg
]

# Set reasonable limits for variants
Rails.application.config.active_storage.variable_content_types = %w[
  image/png
  image/gif
  image/jpeg
  image/jpg
  image/tiff
]

# Force creation of variants only when requested explicitly, not on attach
Rails.application.config.active_storage.previewers = []

# Limit the size of previews
Rails.application.config.active_storage.track_variants = true

# Define acceptable content types for direct uploads
Rails.application.config.active_storage.direct_upload_sanitized_content_types = %w[
  image/png
  image/jpeg
  image/jpg
  image/gif
  application/pdf
]
