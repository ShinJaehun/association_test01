class Message < ApplicationRecord
  #has_many :posts, as: :postable, dependent: :destroy
  has_one :post, as: :postable, dependent: :destroy
  #book 삭제할 때 post모두 삭제해야 해? book 삭제가 가능해야 해?

  #accepts_nested_attributes_for :posts
  accepts_nested_attributes_for :post

  has_many_attached :images
end
