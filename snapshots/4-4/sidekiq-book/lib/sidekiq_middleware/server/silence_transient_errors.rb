#---
# Excerpted from "Ruby on Rails Background Jobs with Sidekiq",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/dcsidekiq for more book information.
#---
module SidekiqMiddleware
  module Server
    class SilenceTransientErrors
      include Sidekiq::ServerMiddleware
      def call(job_instance, _job_payload, _queue)
        begin
          yield
        rescue => ex
          if transient?(job_instance,ex)
            raise IgnorableExceptionSinceSidekiqWillRetry.new(ex)
          else
            raise
          end
        end
      end

    private

      RETRIABLE_EXCEPTIONS = [
        "BaseServiceWrapper::HTTPError",
      ]

      def transient?(job_instance,ex)
        if ex.class.to_s.in?(RETRIABLE_EXCEPTIONS)
          return true
        end
        job_instance.class.respond_to?(:transient_exceptions) &&
          ex.class.to_s.in?(job_instance.class.transient_exceptions.map(&:to_s))
      end
    end
  end
end
