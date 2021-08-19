class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  load_and_authorize_resource

  # GET /posts or /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  # GET /posts/new
#  def new
#    @post = Post.new
#  end

  # GET /posts/1/edit
  def edit
    # books/posts_controller.rb에 set_postable이 before_action 이니까 여기서 @postable 쓸 수 있는거 아닌가?
    #@postable
  end

  # POST /posts or /posts.json
  def create
    # 지금 posts create는 books show 페이지에서만 처리하고 있음.(messages는 배제)
    puts 'posts_controller/create@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2'
    puts '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    puts post_params
    puts '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'

    #@post = current_user.posts.new(post_params)
    #posts_controller에서 generic하게 create하려면 @postable을 set_postable로 받아와야 함
    #이걸 controllers/books/posts_controller.rb에서 먼저 한다.
    #books/show 페이지에서 create 호출하여 @post 생성
    @post = @postable.posts.new(post_params)
    @post.user = current_user
    @post.save

    redirect_to @postable, notice: "Your post was successfully posted."
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    if @post.update(post_params)
      # Post와 Group은 many to many가 아니라서 좀 복잡하지만 이렇게 써야 함.
      if PostRecipientGroup.find_by_post_id(@post.id).present?
        redirect_to group_path(PostRecipientGroup.find_by_post_id(@post.id).recipient_group_id), notice: "글을 수정했습니다."
        # find_by는 하나만 return한다(LIMIT = 1) @post에 해당하는 group을 return해야 함
      else
        redirect_to @post, notice: '글을 수정했습니다.'
      end
    else
      redirect_to root_path, notice: '수정 실패!'
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    # post가 삭제되어도 book은 삭제 안됨
    # 하지만 post가 삭제되면 message는 삭제되어야 함...
    if @post.postable_type == 'Message'
      @post.postable.destroy
    end
    @post.destroy

    redirect_back(fallback_location: root_path, flash:{notice: '글을 삭제했습니다.'})

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
      puts 'posts_controller.rb set_post@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:content)
    end
end
