#---
# Excerpted from "Ruby on Rails Background Jobs with Sidekiq",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/dcsidekiq for more book information.
#---
# XXX class RequestOrderFulfillmentJob
# XXX   include Sidekiq::Job
class RequestOrderFulfillmentJob < ApplicationJob
  def perform(order_id)
    order = Order.find(order_id)
    OrderCreator.new.request_order_fulfillment(order)
  rescue BaseServiceWrapper::HTTPError => ex
    raise IgnorableExceptionSinceSidekiqWillRetry.new(ex)
  end
end
