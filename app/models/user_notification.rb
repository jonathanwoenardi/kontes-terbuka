# == Schema Information
#
# Table name: user_notifications
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  notification_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_user_notifications_on_user_id_and_notification_id  (user_id,notification_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_cdbff2ee9e  (user_id => users.id)
#  fk_rails_d238d8ef07  (notification_id => notifications.id)
#

class UserNotification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notification
  enforce_migration_validations
end
