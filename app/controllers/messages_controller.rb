class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy ]
  before_action :authenticate_user!
  load_and_authorize_resource

#  def show
#    @posts = Post.where(postable_id: @book.id, postable_type: "Book").order(created_at: :desc)
#  end

#  def edit
#  end

#  def new
#    @message = Message.new
#    @message.posts.new
#  end

  def create
    puts '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    puts message_params
    puts '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'

    @message = Message.create(images: message_params[:images])
    if @message.valid?
      #post = @message.posts.new(content: message_params[:posts_attributes]['0'][:content])
      # has_many일 때
      #post = @message.post.new(content: message_params[:post_attributes][:content])
      # has_one일 때 : 이게 될 줄 알았는데 안된다. nil-class/no method of new
      # 그래서 보기 싫지만 postable_type과 postable_id를 직접 입력(이렇게 하면 성공함)
      #post = Post.new(content: message_params[:post_attributes][:content])
      #post.postable_type = 'Message'
      #post.postable_id = @message.id

      post = @message.build_post(content: message_params[:post_attributes][:content])
      # 헐... auto-generated-methods 이거 참조....
      # https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html
      post.user_id = current_user.id

      if post.save
        flash[:success] = '글을 남겼습니다.'
        redirect_to root_path
      else
        flash[:alert] = '글을 남길 수 없어요.'
        redirect_back(fallback_location: new_message_url)
      end
    else
      flash[:alert] = '정상적인 이미지 파일이 아니네요?'
      redirect_to root_path
    end
  end

#  def update
#    respond_to do |format|
#      if @message.update(book_params)
#        format.html { redirect_to @message, notice: "Message was successfully updated." }
#      else
#        format.html { render :new, status: :unprocessable_entity }
#      end
#    end
#  end

#  def destroy
#    #@message 삭제하면 함께 post도 삭제되어야 하고... 
#    #@post 삭제할 때 message도 함께 삭제되어야 함 
#    @message.destroy
#    respond_to do |format|
#      format.html { redirect_to posts_url, notice: "Message was successfully destroyed." }
#      format.json { head :no_content }
#    end
#  end

  private

  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    #params.require(:message).permit(images: [], posts_attributes: [ :content ])
    # has_many일 때
    params.require(:message).permit(images: [], post_attributes: [ :content ])
    # has_one일 때
  end
end