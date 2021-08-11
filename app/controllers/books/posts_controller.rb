class Books::PostsController < PostsController
  #지금 이 posts_controller가 동작할 때는
  #books/show 페이지에서 posts_controller의 create 액션을 호출했기 때문
  before_action :set_postable

  private

  def set_postable
    @postable = Book.find(params[:book_id])
    puts 'books/posts_controller.rb set_postable@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
  end
end
