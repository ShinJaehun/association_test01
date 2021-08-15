class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  load_and_authorize_resource

  # GET /posts or /posts.json
  def index
    @posts = Post.all
    #이렇게 하면 안돼?
#    @message = Message.new
#    @post = @message.posts.new
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
    puts 'posts_controller/create@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2'
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
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
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
