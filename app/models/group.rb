class Group < ApplicationRecord
  has_many :user_groups
  has_many :users, through: :user_groups

  has_many :post_recipient_groups, foreign_key: :recipient_group_id

  validates :name, presence: true, uniqueness: true

  def join_user_by_creating
    #기본으로 group create하면서 creater를 group에 join하고 싶음.
  end
end
