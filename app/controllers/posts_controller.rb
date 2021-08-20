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
    puts 'posts_controller/edit@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2'
    puts '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    puts params
    puts '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    @type = params[:type]
    @receiver_id = params[:receiver_id]
  end

  # POST /posts or /posts.json
  def create
    # 지금 posts create는 books show 페이지에서만 처리하고 있음.(messages는 배제)
    puts 'posts_controller/create@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2'
    puts '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    puts params
    puts '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'

    #@post = current_user.posts.new(post_params)
    #posts_controller에서 generic하게 create하려면 @postable을 set_postable로 받아와야 함
    #이걸 controllers/books/posts_controller.rb에서 먼저 한다.
    #books/show 페이지에서 create 호출하여 @post 생성
    post = @postable.posts.new(post_params)
    post.user = current_user
    post.save

    if params[:type] == 'user'

      post_recipient_user = PostRecipientUser.new
      post_recipient_user.recipient_user_id = params[:receiver_id]
      post_recipient_user.post_id = post.id
      post_recipient_user.save
      redirect_back(fallback_location: root_path, flash:{notice: '글을 작성했습니다.'})

    elsif params[:type] == 'group'
      #그래서 아직 group으로 처리할 내용은 없음

      if current_user.has_role? :group_member, Group.find(params[:receiver_id])
        post_recipient_group = PostRecipientGroup.new
        post_recipient_group.recipient_group_id = params[:receiver_id]
        post_recipient_group.post_id = post.id
        post_recipient_group.save
        redirect_back(fallback_location: root_path, flash:{notice: '그룹에 글을 남겼습니다.'})
      else
        redirect_back(fallback_location: root_path, flash:{notice: '그룹에 글을 남길 권한 없음.'})
      end

    else
      redirect_back(fallback_location: root_path, flash:{notice: '이 포스트의 대상은 사용자도 아니고 그룹도 아녀!'})
    end

  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    if @post.update(post_params)
      # Post와 Group은 many to many가 아니라서 좀 복잡하지만 이렇게 써야 함.
      @type = params[:type]
      @receiver_id = params[:receiver_id]

      puts '@type: ' + @type
      puts '@receiver_id: ' + @reciever_id.to_s

      if @type == 'group' && @receiver_id.present?
        #redirect_to group_path(Group.find(@receiver_id))
        redirect_to group_path(@receiver_id)
        # 야... 근데 redirect 하긴 했는데 꼭 이런 식으로 해야 하는거야?
        # link_to에 param을 붙여서 edit과 update에서 param을 받아오는 식으로 구현함...ㅠㅠ

      else
        redirect_to @post, notice: '수정 후 redirect 실패'
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
