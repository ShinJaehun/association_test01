class GroupsController < ApplicationController
  #before_action :set_group, only: %i[ show edit update destroy ]
  before_action :set_group, except: %i[ index new create ]

  # GET /groups or /groups.json
  def index
    @groups = Group.all
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
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: "Group was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def add_user_to_group
    if UserGroup.where(user_id: current_user.id, group_id: @group.id).count <= 0
      usergroup = UserGroup.new
      usergroup.user_id = current_user.id
      usergroup.group_id = @group.id
      usergroup.save
      redirect_to groups_path, notice: "You're already a member of #{@group.name}."
    else
    end
  end

  def remove_user_from_group
    usergroup = current_user.user_groups.find_by_group_id(@group.id)
    usergroup.destroy
    current_user.save!
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
