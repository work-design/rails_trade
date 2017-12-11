class AdditionService
  attr_reader :checked_items, :buyer, :user,
              :total_quantity,
              :bulk_price, :discount_price, :retail_price, :promote_price,
              :promote_price, :serve_price,
              :promote_charges, :serve_charges

  def initialize(user_id: nil, buyer_id: nil, session_id: nil, assistant: false)
    @user = User.find(user_id) if user_id
    @buyer = Buyer.find(buyer_id) if buyer_id
    if @user
      puts "-----> Checked User: #{user_id}"
      @checked_items = @user.cart_items.checked.where(assistant: assistant)
    elsif buyer
      puts "-----> Checked Buyer: #{buyer_id}"
      @checked_items = @buyer.cart_items.checked.where(assistant: assistant)
    elsif session_id
      puts "-----> Checked Session: #{session_id}"
      @checked_items = CartItem.where(session_id: session_id).checked.where(assistant: assistant)
    else
      puts "-----> Checked None!"
      @checked_items = CartItem.limit(0)
    end
    compute_total
    compute_promote
    compute_serve
  end

  def compute_price
    @bulk_price = checked_items.sum { |cart_item| cart_item.bulk_price }
  end

  def compute_total
    compute_price
    @promote_price = checked_items.sum { |cart_item| cart_item.promote_price }
    @discount_price = checked_items.sum { |cart_item| cart_item.discount_price }
    @retail_price = checked_items.sum { |cart_item| cart_item.retail_price }
    @total_quantity = checked_items.sum { |cart_item| cart_item.total_quantity }
  end

  def compute_promote
    @promote_charges = []
    Promote.sequence.each do |quence|
      AmountPromote.total.overall.where(sequence: quence).each do |promote|
        charge = promote.compute_price(bulk_price)
        @promote_charges << charge if charge
      end

      if buyer
        buyer.promotes.total.where(sequence: quence).each do |promote|
          charge = promote.compute_price(bulk_price)
          @promote_charges << charge if charge
        end
      end

      compute_price
    end

    @promote_price = @promote_charges.map(&:subtotal).sum
  end

  def compute_serve
    @serve_charges = []

    QuantityServe.total.overall.each do |serve|
      serve = serve.compute_price(total_quantity)
      @serve_charges << serve if serve.persisted?
    end
    @serve_price = @serve_charges.map(&:subtotal).sum
  end

  def total_price
    @total_price ||= @bulk_price + @promote_price + @serve_price
  end

end
