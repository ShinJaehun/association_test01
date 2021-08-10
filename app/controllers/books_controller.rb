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
  end

  def new
    @book = Book.new
    @book.posts.new #이게 없으면 field_for :posts 항목이 나오지 않음.
  end

  def create
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
    post.user_id = book_params[:posts_attributes]['0'][:user_id]
    # current_user.id로 해도 상관 없는거 아니?
    post.save

    redirect_to root_path
  end

#  def create
#    unless @book = Book.find_by(isbn: book_params[:isbn])
#
#      thumbnail_url = book_params[:thumbnail]
#
#      # puts "thumbnail_url : " + thumbnail_url
#      unless thumbnail_url.to_s.empty?
#        # thumbnail_path = URI.unescape(thumbnail_url.match(/^http.+?(http.+?)%3F/)[1].to_s)
#        # %3F는 '?'를 의미
#
#        # puts "-----------------book_thumbnail-------------------------"
#        thumbnail_url_unescape = URI.unescape(thumbnail_url)
#        # puts "thumbnail_url_unescape : " + thumbnail_url_unescape
#
#        # thumbnail_url_unescape_regex = thumbnail_url_unescape.match(/^http.+?(http.+?)\?/)[1].to_s
#        # puts "thumbnail_url_unescape.nil? : " + (thumbnail_url_unescape.nil?).to_s
#        # puts "thumbnail_url_unescape_regex.nil? : " + (thumbnail_url_unescape.match(/^http.+?(http.+?)\?/).nil?).to_s
#
#        if !(thumbnail_url_unescape.match(/^http.+?(http.+?)\?/).nil?)
#        # https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http://t1.daumcdn.net/lbook/image/1097174?timestamp=20210114144331
#        # fname= 이후의 http://부터 ?timestamp 전까지 추출
#          thumbnail_path = thumbnail_url_unescape.match(/^http.+?(http.+?)\?/)[1].to_s
#        elsif !(thumbnail_url_unescape.match(/^http.+?(http.+?)$/).nil?)
#        # https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http://t1.daumcdn.net/lbook/image/3744671
#        # 뒤에 timestamp가 붙지 않는 녀석도 있음...  이나중 탁구부;;
#          thumbnail_path = thumbnail_url_unescape.match(/^http.+?(http.+?)$/)[1].to_s
#        else
#          puts "큰일났어... 또 새로운 녀석이 나타났나봐...ㅠㅠ"
#          thumbnail_path = nil
#        end
#
#        # puts "thumbnail_path : " + thumbnail_path
#        # puts "-----------------book_thumbnail-------------------------"
#
#      end
#
#      @book = Book.create(
#        title: CGI.unescapeHTML(book_params[:title]),
#        contents: CGI.unescapeHTML(book_params[:contents]),
#        url: book_params[:url],
#        isbn:  book_params[:isbn],
#        datetime: book_params[:datetime],
#        authors: book_params[:authors],
#        publisher: book_params[:publisher],
#        translators: book_params[:transaltors],
#        thumbnail:  thumbnail_path
#      )
#    end
#
##    puts "-----------------------book_params-----------------------"
##    puts book_params
##    puts "-----------------------book_params-----------------------"
##
##    puts "-----------------------book_params[:posts_attributes]-----------------------"
##    puts book_params[:posts_attributes]
##    puts "-----------------------book_params[:posts_attributes]-----------------------"
##
##    puts "-----------------------book_params[:posts_attributes]['0']-----------------------"
##    puts book_params[:posts_attributes]['0']
##    puts "-----------------------book_params[:posts_attributes]['0']-----------------------"
#
#    post = @book.posts.new(content: book_params[:posts_attributes]['0'][:content])
#    post.user_id = book_params[:posts_attributes]['0'][:user_id]
#    post.save
#
#    redirect_to root_path
#  end

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

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :contents, :isbn, :publisher, posts_attributes: [:user_id, :content])
    #params.require(:book).permit(:title, :contents, :url, :isbn, :datetime, :authors, :publisher, :translators, :thumbnail, posts_attributes: [:user_id, :content])
  end
end
