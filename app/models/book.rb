class Book < ApplicationRecord
  #has_many :posts, as: :postable
  has_many :posts, as: :postable, dependent: :destroy
  #book 삭제할 때 post모두 삭제해야 해? book 삭제가 가능해야 해?

  accepts_nested_attributes_for :posts
  # field_for로 nested한 값을 입력받을 수 있음
  # params에 posts_attributes가 생성됨, 반드시 params 내용을 확인할 것!
end
