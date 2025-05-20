require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Moneygun
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0
    config.generators.template_engine = :erb

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks generators])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    
    # ActiveStorage configuration
    config.active_storage.variant_processor = :mini_magick
    config.active_storage.resolve_model_to_route = :rails_storage_redirect
    config.active_storage.routes_prefix = '/storage'
    
    # Fix for 'body' method issue in DiskController and RedirectController
    config.to_prepare do
      ActiveStorage::BaseController.class_eval do
        private
        def verified_key_with_expiration
          if key = decode_verified_key
            key
          else
            nil
          end
        end
      end
      
      if defined?(ActiveStorage::DiskController)
        ActiveStorage::DiskController.class_eval do
          def show
            if key = decode_verified_key
              send_data(disk_service.download(key[:key]),
                      type: key[:content_type],
                      disposition: key[:disposition],
                      filename: key[:filename])
            else
              head :not_found
            end
          end
        end
      end
    end
  end
end
