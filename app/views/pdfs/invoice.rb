module Pdfs
  module Invoice

    def build_invoice(order)
      something
      header(720, order)
      body(590, order)

      start_new_page if cursor < 175

      footer
      pod(order)
    end

    def header(start_y, order)
      col1 = 10
      col2 = 80

      bounding_box([0, start_y], :width => 540, :height => 120) do
        formatted_text_box [{ text: "Invoice:", styles: [:bold] }], :at => [col1, cursor]
        formatted_text_box [{ text: order.order_number }], :at => [col2, cursor]

        y = cursor - 30
        formatted_text_box [{ text: "Delivery date:", size: 10}], :at => [col1, y]
        formatted_text_box [{ text: order.delivery_date.strftime('%m/%d/%y'), size: 10 }], :at => [col2, y]

        y = cursor - 45
        formatted_text_box [{ text: "Due date:", size: 10}], :at => [col1, y]
        formatted_text_box [{ text: order.due_date.strftime('%m/%d/%y'), size: 10 }], :at => [col2, y]

        y = cursor - 60
        bounding_box([col1, y], :width => 50, :height => 20) do
         formatted_text_box [{ text: "Ship to:", size: 10}], :valign => :bottom
        end

        bounding_box([col2, y], :width => 300, :height => 20) do
         name = "#{order.location.company.name} - #{order.location.name} - #{order.location.id}"
         formatted_text_box [{ text: name, size: 12, styles: [:bold, :italic] }], :valign => :bottom
        end

        y = cursor - 5
        bounding_box([col2, y], :width => 300, :height => 30) do
          # address = "#{order.location.address.street}\n#{order.location.address.city}, #{order.location.address.state} #{order.location.address.zip}"
          formatted_text_box [{ text: order.location.address.to_s, size: 10 }]
          # transparent(0.5) { stroke_bounds }
        end
      end

      image "app/assets/images/logo.png", :width => 120, :at => [ 430, start_y+10]
    end

    def body(start_y, order)
      move_cursor_to start_y
      table_header

      move_down 5
      order.order_items
        .select{|oi| oi.has_quantity?}
        .each_with_index do |order_item, index|
          order_row(order_item, index)
        end

      total(order.total)
    end

    def table_header
      y = cursor
      height = 12

      bounding_box([-10, y], :width => 30, :height => height) do
       formatted_text_box [{ text: "#", styles: [:bold], size: 9 }], :align => :right
      end

      bounding_box([20, y], :width => 30, :height => height) do
       formatted_text_box [{ text: "QTY", styles: [:bold], size: 9 }], :align => :right
      end

      bounding_box([60, y], :width => 60, :height => height) do
       formatted_text_box [{ text: "PRODUCT", styles: [:bold], size: 9 }], :align => :left
      end

      bounding_box([450, y], :width => 35, :height => height) do
       formatted_text_box [{ text: "PRICE", styles: [:bold], size: 9 }], :align => :right
      end

      bounding_box([500, y], :width => 35, :height => height) do
       formatted_text_box [{ text: "TOTAL", styles: [:bold], size: 9 }], :align => :right
      end
    end

    def order_row(order_item, index)
      y = cursor
      height = 17

      self.line_width = 0.5
      # dash(8, :space => 20, :phase => 5)
      transparent(0.5) { stroke_horizontal_line 0, 540, :at => y + 2 }

      bounding_box([-10, y], :width => 30, :height => height) do
       formatted_text_box [{ text: "#{index + 1}:", size: 8, styles: [:italic]}], :align => :right, :valign => :center
      end

      bounding_box([20, y], :width => 30, :height => height) do
       formatted_text_box [{ text: order_item.quantity.to_i.to_s, size: 11}], :align => :right, :valign => :center
      end

      bounding_box([60, y], :width => 100, :height => height) do
       formatted_text_box [{ text: order_item.item.name, size: 9}], :align => :left, :valign => :center
      end

      bounding_box([170, y], :width => 290, :height => height) do
        desc = Maybe(order_item).item.description._.truncate(61)
        formatted_text_box [{ text: desc, size: 9}], :align => :left, :valign => :center
      end

      bounding_box([450, y], :width => 35, :height => height) do
       formatted_text_box [{ text: order_item.unit_price.to_s, size: 9}], :align => :right, :valign => :center
      end

      bounding_box([500, y], :width => 35, :height => height) do
       formatted_text_box [{ text: order_item.total.to_s, size: 9}], :align => :right, :valign => :center
      end

      move_down 4

      start_new_page if cursor < 20
    end

    def total(val)
      # guide_y
      y = cursor
      self.line_width = 1

      dash(1, :space => 0, :phase => 0)
      stroke_horizontal_line 380, 540

      bounding_box([340, y], :width => 100, :height => 20) do
       formatted_text_box [{ text: 'Total', size: 9, styles:[:bold]}], :align => :right, :valign => :center
      end

      bounding_box([500, y], :width => 35, :height => 20) do
       formatted_text_box [{ text: val.to_s, size: 11}], :align => :right, :valign => :center
      end

    end

    def pod(order)
      size = 30
      y = 210
      x = 540/2-(size*4)/2

      signature = Maybe(order).fulfillment.pod.signature._

      if signature.present?
        img = StringIO.new(Base64.decode64(signature['data:image/png;base64,'.length .. -1]))

        bounding_box([x, y], :width => size*4, :height => size) do
          formatted_text_box [{ text: 'Received', size: size/3}], :align => :left, :valign => :bottom
        end

        y = cursor
        bounding_box([x, y], :width => size*4, :height => size) do
         image img, :height => size, :position => :center, :vposition => :bottom

         stroke_color "FF5500"
         self.line_width = 2
         self.join_style = :miter
         stroke_bounds

         stroke_color "000000"
       end

       y = cursor - 5
       bounding_box([x, y], :width => size*4, :height => size/3) do
         name = Maybe(order).fulfillment.pod.name.fetch('')
         date = '01/12/16 - 10:42am'
         formatted_text_box [{ text: "#{date} - #{name}", size: size/4.5, styles: [:italic, :bold]}], :align => :left, :valign => :top
       end

       image "app/assets/images/stamp_icon.png", :at => [x + size*3.5, y+size], :width => size/2
      end
    end

    def footer
      image "app/assets/images/footer.png", :at => [0, 140], :width => 540
    end

  end
end
