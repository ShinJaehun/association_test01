class Books::PostsController < PostsController
  #지금 이 posts_controller가 동작할 때는
  #books/show 페이지에서 posts_controller의 create 액션을 호출했기 때문
  before_action :set_postable

#  def create
#    puts 'books/posts_controller/create@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2'
#    super
#    # super가 있어야 posts_controller/create가 실행된다.
#    # 실행되는 순서는...
#    # books/posts_controller.rb set_postable@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#    # books/posts_controller/create@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2
#    # posts_controller/create@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2
#    # 만일 여기에 create가 없으면 바로 posts_controller/create가 실행됨.
#    # create가 있으면 여기서 view를 찾음... 
#  end

  private

  def set_postable
    @postable = Book.find(params[:book_id])
    puts 'books/posts_controller.rb set_postable@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
  end
end
