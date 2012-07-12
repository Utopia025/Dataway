class RevenueModel < ActiveRecord::Base
  attr_accessible :company, :ent_id, :is_verified, :revenue_mill, :source, :updated_at, :updated_by
end
