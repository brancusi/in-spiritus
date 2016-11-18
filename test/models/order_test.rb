require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  test "creates correct fulfillment structure on save" do
    order = build(:sales_order_with_items, :submitted)

    assert order.fulfillment.nil?, "Fulfillment was present before create and save"
    assert_equal(0, Fulfillment.all.count, "There was a fulfillment when there should't have been")

    order.save

    assert order.fulfillment.present?, "Fulfillment was not present after and save"
    assert_equal(1, Fulfillment.all.count, "Created the wrong number of fulfillments")
  end

  test "Should find or create route_visit when order date changes" do
    order = create(:sales_order_with_items)

    route_visit_id = order.fulfillment.route_visit.id

    order.delivery_date = order.delivery_date + 1
    order.save

    refute_equal route_visit_id, order.fulfillment.route_visit.id
  end

  test "Should not change route_visit when order saves but date is same" do
    order = create(:sales_order_with_items)

    generate_parent_route_visit_spy = Spy.on(order, :generate_parent_route_visit)

    order.save

    refute generate_parent_route_visit_spy.has_been_called?
  end

  test "generates a order_number when one not present on save" do
    order = build(:sales_order_with_items)
    assert order.order_number.nil?

    order.save

    assert order.order_number.present?
  end

  test "generates a order_number when one not present on create" do
    order = create(:sales_order_with_items)
    assert order.order_number.present?
  end

  test "does not generate a order_number if one is present" do
    order = create(:sales_order_with_items, order_number:'prefix')
    assert order.order_number.present?

    order.save

    assert_equal(order.order_number, 'prefix')
  end

  test "generates a order_number if one is duplicated" do
    create(:sales_order_with_items, order_number:'prefix')

    order = create(:sales_order_with_items, order_number:'prefix')
    assert order.order_number.present?

    order.save

    assert order.order_number.present?
    assert_not_equal(order.order_number, 'prefix')
  end

  test "should downcase order_number" do
    order1 = create(:sales_order_with_items, order_number:'Prefix')
    assert_equal(order1.order_number, 'prefix')

    order2 = create(:sales_order_with_items)
    assert_equal(order2.order_number, order2.order_number.downcase)
  end

  test "should be able to clone an order to a new date" do
    order = create(:sales_order_with_items, delivery_date: 1.day.ago)

    duplicated_order = order.clone(to_date: Date.today)

    assert_equal(duplicated_order.delivery_date, Date.today)
    assert_equal(duplicated_order.order_items.count, order.order_items.count)
  end

  test "raises an error when cloned without a new date" do
    order = create(:sales_order_with_items, delivery_date: 1.day.ago)

    assert_raise do
      order.clone
    end
  end
end
