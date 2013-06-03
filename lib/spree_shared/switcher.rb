module Spree
  module Shared
    class Switcher

      def initialize(app)
        @app = app
      end

      def call(env)
        request = ActionDispatch::Request.new(env)

        Rails.logger.info "  Requested URL: #{request.url}"
        database = subdomain(request)

        if database
          #switch database
          begin
            database.gsub! '-', '_'

            Apartment::Database.switch database

            Rails.logger.info "  Using database '#{database}'"

            #set image location
            Spree::Image.change_paths database

            #namespace cache keys
            ENV['RAILS_CACHE_ID']= database

            #reset Mail settings
            Spree::Core::MailSettings.init
          rescue Exception => e
            Rails.logger.error "  Stopped request due to: #{e.message}"

            #fallback
            ENV['RAILS_CACHE_ID'] = ""
            Apartment::Database.reset
            return ahh_no
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
        [200, {"Content-type" => "text/html"}, ["Ahh No."]]
      end

    end
  end
end

