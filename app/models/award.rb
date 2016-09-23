# == Schema Information
#
# Table name: awards
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# rubocop:enable Metrics/LineLength

class Award < ActiveRecord::Base
  has_paper_trail

  # Associations
  has_many :user_awards
  has_many :users, through: :user_awards
end
