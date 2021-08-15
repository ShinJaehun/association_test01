class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy ]
  before_action :authenticate_user!
  load_and_authorize_resource

#  def show
#    @posts = Post.where(postable_id: @book.id, postable_type: "Book").order(created_at: :desc)
#  end

#  def edit
#  end

  def new
    @message = Message.new
    @message.posts.new
  end

  def create
    @message = Message.create(images: message_params[:images])
    if @message.valid?
      post = @message.posts.new(content: message_params[:posts_attributes]['0'][:content])
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
#
#  def destroy
#    @Message.destroy
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
    params.require(:message).permit(posts_attributes: [ :content ], images: [] )
  end
end
