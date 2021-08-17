class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy ]
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @books = Book.all
  end

  def show
    @posts = Post.where(postable_id: @book.id, postable_type: "Book").order(created_at: :desc)
  end

  def edit
    #has_many belongs_to에 의해 books_controler의 edit 액션을 호출하면
    #field_for 메서드로 book과 관련된 모든 post가edit 대상이 된다.
    #그래서 edit 페이지에서 field_for 메서드로 지정된 post를 제외함.
  end

  def new
    @book = Book.new
    @book.posts.new #이게 없으면 field_for :posts 항목이 나오지 않음.
  end

  def create
    puts '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    puts book_params
    puts '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'

    unless @book = Book.find_by(isbn: book_params[:isbn])
      #@book = Book.new(book_params)
      #@book에 book_params로 부터 넘어온 것을 저장하는 과정은 필요 없음(위에서 다 함)
      #@book.save
      #근데 @book이 두번 저장됨 왜 그럴까?
      @book = Book.create(
        title: CGI.unescapeHTML(book_params[:title]),
        contents: CGI.unescapeHTML(book_params[:contents]),
        isbn: CGI.unescapeHTML(book_params[:isbn]),
        publisher: CGI.unescapeHTML(book_params[:publisher])
      )
    else
      puts '이 책은 이미 DB에 있는 책이군!'
    end

    post = @book.posts.new(content: book_params[:posts_attributes]['0'][:content])
    # posts_controller에서 생성할 때는(아니 꼭 그런 건 아닌 거 같애... 이런 식으로도 가능하다 정도)
    # Post.create(postable: Book.first, content: "testing!")
    #post.user_id = book_params[:posts_attributes]['0'][:user_id]
    post.user_id = current_user.id
    # current_user.id로 해도 상관 없는거 아니?
    post.save

    redirect_to root_path
  end

  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: "Book was successfully updated." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @book.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Book was successfully destroyed." }
      format.json { head :no_content }
    end
  end

#  def create_in_show
#    # 이렇게 book 페이지 내에서 post(index와 show에서)는
#    # 모두 books_controller에서 처리하게 만들고 싶은데
#    # 생각보다 custom 페이지/custom 동작을 처리하는게 쉽지가 않아서 포기함.
#    puts '이게 동작하니?'
#    post = @book.posts.new(post_params)
#    post.user = current_user
#    post.save
#    redirect_to @book, notice: "Your post was successfully posted."
#  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :contents, :isbn, :publisher, posts_attributes: [ :content ])
    #params.require(:book).permit(:title, :contents, :url, :isbn, :datetime, :authors, :publisher, :translators, :thumbnail, posts_attributes: [:user_id, :content])
  end
end
