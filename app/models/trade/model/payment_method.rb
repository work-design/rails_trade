module Trade
  module Model::PaymentMethod
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :account_name, :string
      attribute :account_num, :string
      attribute :bank, :string
      attribute :verified, :boolean, default: false
      attribute :myself, :boolean, default: true
      attribute :extra, :json, default: {}

      belongs_to :creator, optional: true
      has_many :payments, dependent: :nullify
      has_many :payment_references, dependent: :destroy_async, autosave: true, inverse_of: :payment_method
      has_many :buyers, through: :payment_references

      default_scope -> { where(verified: true) }

      validates :account_num, uniqueness: { scope: [:account_name, :verified] }, if: :verified?
    end

    def account_types
      PaymentReference.pluck(:account_type).uniq
    end

    def detective_save
      if detect_repetition
        self.verified = false
      else
        self.verified = true
      end
      self.save
    end

    def detect_repetition
      if self.persisted?
        self.class.unscoped.where.not(id: self.id).exists?(account_name: self.account_name, account_num: self.account_num)
      else
        self.class.unscoped.exists?(account_name: self.account_name, account_num: self.account_num)
      end
    end

    def repeat_results
      self.class.where.not(id: self.id).where(account_name: self.account_name, account_num: self.account_num)
    end

    def merge_from(other_id)
      other = self.class.unscoped.find other_id

      self.class.transaction do
        other.payment_references.each do |payment_reference|
          payment_reference.payment_method_id = self.id  # for callback, do not use update
          payment_reference.save
        end
        other.payment_references.reload
        other.destroy
      end
    end

    def kind
      type.to_s.sub('Method', '').downcase
    end

  end
end
