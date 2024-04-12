#---
# Excerpted from "Ruby on Rails Background Jobs with Sidekiq",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/dcsidekiq for more book information.
#---
require "sidekiq_middleware/server/silence_transient_errors"

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add SidekiqMiddleware::Server::SilenceTransientErrors
  end
  config.death_handlers << ->(job,exception) {
    ErrorCatcherServiceWrapper.new.notify(
      "#{job['class']} won't be retried: #{exception.message}"
    )
  }
  config.error_handlers << ->(exception,context_hash) {
    ErrorCatcherServiceWrapper.new.notify(exception)
  }
end
