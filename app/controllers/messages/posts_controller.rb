class Messages::PostsController < PostsController
  before_action :set_postable

  def create
    puts 'messages/posts_controller.rb create@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
  end

  private

  def set_postable
    @postable = Message.find(params[:message_id])
    puts 'messages/posts_controller.rb set_postable@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
  end
end
