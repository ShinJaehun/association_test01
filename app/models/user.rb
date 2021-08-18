class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true

  has_many :posts, dependent: :destroy
  # 정말 이렇게 해야 하는거야? 사용자가 삭제되도 post는 남겨야 함...
  # 하지만 db에 빈 공간으로 놔둘 순 없음!

  has_many :user_groups
  has_many :groups, through: :user_groups

  has_many :post_recipient_users, foreign_key: :recipient_user_id
end
