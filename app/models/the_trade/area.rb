class Area < ApplicationRecord
  scope :all_provinces, -> { where(city: '').where.not(province: '')}
  scope :popular, -> { where(popular: true) }

  scope :provinces, ->(nation_name){ select(:province).distinct.where(nation: nation_name) }
  scope :cities, ->(province_name){ select(:city).distinct.where(province: province_name) }

  default_scope -> { where(published: true) }

  after_commit :update_timestamp, :delete_cache, on: [:create, :update]

  def self.list
    Rails.cache.fetch('areas/list') do
      nations.includes(provinces: :cities).map do |nation|
        {
          id: nation.id,
          name: nation.nation,
          provinces: nation.provinces.map do |province|
            {
              id: province.id,
              name: province.province,
              cities: province.cities.map do |city|
                { id: city.id, name: city.city }
              end
            }
          end
        }
      end
    end
  end

  def self.timestamp
    Rails.cache.fetch('areas/timestamp') do
      order(updated_at: :desc).last.updated_at.to_i
    end
  end

  def name
    "#{city} #{province} #{nation}"
  end

  private
  def delete_cache
    Rails.cache.delete('areas/list') &&
    Rails.cache.delete('areas/popular')
  end

  def update_timestamp
    t = self.updated_at.to_i
    Rails.cache.write('areas/timestamp', t)
  end

end
