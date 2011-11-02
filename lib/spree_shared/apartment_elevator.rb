module Apartment
  module Elevators
    # Provides a rack based db switching solution based on subdomains
    # Assumes that database name should match subdomain
    class Subdomain

      def initialize(app)
        @app = app
      end

      def call(env)
        request = ActionDispatch::Request.new(env)

        Rails.logger.error "  Requested URL: #{request.url}"
        database = subdomain(request)

        if database
          #switch database
          begin
            Apartment::Database.switch database

            Rails.logger.error "  Using database '#{database}'"

            #set image location
            Image.change_paths database

            #namespace cache keys
            ENV['RAILS_CACHE_ID']= database

            #reset Mail settings
            Spree::MailSettings.init

            #reset Theme
            Spraycan::Engine.initialize_themes
          rescue Exception => e
            Rails.logger.error "  Stopped request due to: #{e.message}"
            Apartment::Database.reset
            ahh_no
          end

          #continue on to rails
          @app.call(env)

        else
          ahh_no
        end

      end

      def subdomain(request)
        request.subdomain.present? && request.subdomain || nil
      end

      def ahh_no
         [200, {"Content-type" => "text/html"}, "Ahh No."]
      end

    end
  end
end

