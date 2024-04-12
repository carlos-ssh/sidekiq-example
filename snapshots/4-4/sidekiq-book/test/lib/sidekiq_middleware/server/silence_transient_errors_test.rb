#---
# Excerpted from "Ruby on Rails Background Jobs with Sidekiq",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/dcsidekiq for more book information.
#---
require "test_helper"
require "sidekiq_middleware/server/silence_transient_errors"

class SidekiqMiddleware::Server::SilenceTransientErrorsTest < ActiveSupport::TestCase
  setup do
    @payments_service_status = ServiceStatus.find("payments")
    @payments_service_status.update(sleep: 0, throttle: false, crash: false)
    Sidekiq::Testing.server_middleware do |chain|
      chain.add SidekiqMiddleware::Server::SilenceTransientErrors
    end
  end

  test "normal job raising a non-transient exception" do
    job_instance = CompleteOrderJob.new
    non_existent_order_id = -99
    CompleteOrderJob.perform_async(non_existent_order_id)
    assert_raises ActiveRecord::RecordNotFound do
      Sidekiq::Job.drain_all
    end
  end
  test "normal job raising a transient exception" do
    @payments_service_status.update(sleep: 0, throttle: false, crash: true)
    order = FactoryBot.create(:order)
    CompleteOrderJob.perform_async(order.id)
    assert_raises IgnorableExceptionSinceSidekiqWillRetry do
      Sidekiq::Job.drain_all
    end
  end
  class CustomTransientJob < ApplicationJob
    def self.transient_exceptions
      [
        ArgumentError
      ]
    end
    def perform(throw_argument_error)
      if throw_argument_error
        raise ArgumentError
      end
    end
  end
  test "job raising a custom transient exception" do
    order = FactoryBot.create(:order)
    CustomTransientJob.perform_async(true)
    assert_raises IgnorableExceptionSinceSidekiqWillRetry do
      Sidekiq::Job.drain_all
    end
  end
end
