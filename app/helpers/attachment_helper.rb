module AttachmentHelper
  # Safely display an attached image with variant processing
  # Falls back to a default placeholder if the image is not attached or processing fails
  #
  # @param attachment [ActiveStorage::Attached] The attachment to display
  # @param options [Hash] Options for the image display
  # @option options [Array<Integer>] :resize_to_limit Resize dimensions [width, height]
  # @option options [String] :class CSS classes for the image tag
  # @option options [String] :alt Alt text for the image
  # @option options [String] :placeholder_class CSS classes for the placeholder
  # @option options [String] :placeholder_text Text to display in the placeholder
  # @option options [String] :placeholder_bg Background color class for the placeholder
  # @option options [String] :placeholder_text_color Text color class for the placeholder
  def safe_attachment_image(attachment, options = {})
    return placeholder_for(options) unless attachment&.attached?

    begin
      # Set default options
      resize = options.delete(:resize_to_limit) || [100, 100]
      css_class = options.delete(:class) || "object-cover"
      alt = options.delete(:alt) || "Attached image"
      
      # Generate the variant safely
      variant = attachment.representation(resize_to_limit: resize)
      image_tag(variant, class: css_class, alt: alt)
    rescue StandardError => e
      Rails.logger.error("Error displaying attachment: #{e.message}")
      placeholder_for(options)
    end
  end
  
  # Generate a placeholder for attachments
  def placeholder_for(options = {})
    text = options[:placeholder_text] || options[:alt] || "?"
    first_char = text.is_a?(String) ? text[0].upcase : "?"
    
    css_class = options[:placeholder_class] || "flex items-center justify-center"
    bg_class = options[:placeholder_bg] || "bg-blue-100"
    text_class = options[:placeholder_text_color] || "text-blue-600"
    
    dimensions = options[:resize_to_limit] || [100, 100]
    size_classes = "h-#{dimensions[1] / 10} w-#{dimensions[0] / 10}"
    
    content_tag :div, class: "#{css_class} #{bg_class} #{size_classes} rounded-md" do
      content_tag :span, first_char, class: "#{text_class} font-medium text-center"
    end
  end
  
  # Safely get a variant of an attached image
  # Returns nil if the attachment is not present
  # 
  # @param attachment [ActiveStorage::Attached] The attachment to process
  # @param size [Symbol] Predefined size (:thumb, :icon, :medium)
  # @return [ActiveStorage::VariantWithRecord, nil] The processed variant or nil
  def safe_variant(attachment, size = :thumb)
    return nil unless attachment&.attached?
    
    begin
      dimensions = case size
                  when :icon
                    [40, 40]
                  when :thumb
                    [100, 100]
                  when :medium
                    [300, 300]
                  when :large
                    [600, 600]
                  else
                    [100, 100]
                  end
      
      attachment.representation(resize_to_limit: dimensions)
    rescue StandardError => e
      Rails.logger.error("Error processing variant: #{e.message}")
      nil
    end
  end
end