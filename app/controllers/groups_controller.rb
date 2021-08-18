class GroupsController < ApplicationController
  #before_action :set_group, only: %i[ show edit update destroy ]
  before_action :set_group, except: %i[ index new create ]
  before_action :authenticate_user!
  load_and_authorize_resource except: %i[ index new create join_group leave_group ]

  # GET /groups or /groups.json
  def index
    @groups = Group.all
    #@groups = current_user.groups
    #지금은 테스트를 위해서...
  end

  # GET /groups/1 or /groups/1.json
  def show
    @posts = Post.find(@group.post_recipient_groups.pluck(:post_id))
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups or /groups.json
  def create
    group = Group.new(group_params)

    if Group.find_by(name: group.name).present?
      redirect_to groups_path, notice: "That group name has already been taken."
    else
      group.save

      usergroup = UserGroup.new
      usergroup.user_id = current_user.id
      usergroup.group_id = group.id
      usergroup.save

      current_user.add_role :group_manager, group
      current_user.add_role :group_member, group

      redirect_to group, notice: "Group was successfully created."
    end
  end

  # PATCH/PUT /groups/1 or /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: "Group was successfully updated." }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1 or /groups/1.json
  def destroy
    posts = Post.find(@group.post_recipient_groups.pluck(:post_id))

    unless posts.blank?
      posts.each do |post|
        post.postable.destroy
        post.destroy
      end
    end

    current_user.remove_role :group_member, @group
    current_user.remove_role :group_manager, @group

    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: "Group was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def join_group
    if UserGroup.where(user_id: current_user.id, group_id: @group.id).count <= 0
      usergroup = UserGroup.new
      usergroup.user_id = current_user.id
      usergroup.group_id = @group.id
      usergroup.save

      current_user.add_role :group_member, @group

      redirect_to groups_path, notice: "You've been added to #{@group.name}."
    else
      redirect_to groups_path, notice: "You're already a member of #{@group.name}."
    end
  end

  def leave_group
    current_user.remove_role :group_member, @group
    usergroup = current_user.user_groups.find_by_group_id(@group.id)
    usergroup.destroy
    current_user.save
    redirect_to groups_path, notice: "You're no longer a member of #{@group.name}."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:name, :description)
    end
end
