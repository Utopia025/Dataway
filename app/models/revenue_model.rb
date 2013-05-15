# == Schema Information
#
# Table name: revenue_models
#
#  id           :integer          not null, primary key
#  ent_id       :string(255)
#  company      :string(255)
#  revenue_mill :decimal(, )
#  source       :string(255)
#  updated_at   :datetime         not null
#  updated_by   :string(255)
#  is_verified  :boolean
#  created_at   :datetime         not null
#

class RevenueModel < ActiveRecord::Base
  attr_accessible :company, :ent_id, :is_verified, :revenue_mill, :source, :updated_at, :updated_by
end
