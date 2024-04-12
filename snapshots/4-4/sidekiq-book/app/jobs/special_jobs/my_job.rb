#---
# Excerpted from "Ruby on Rails Background Jobs with Sidekiq",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/dcsidekiq for more book information.
#---
class SpecialJobs::MyJob < ApplicationJob
  sidekiq_options queue: "high"

  def perform(args,should,go,here)
    raise "This job has not been implemented"
  end
end
