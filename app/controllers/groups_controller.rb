class GroupsController < ApplicationController
  before_action :set_group, except: %i[ index new create ]
  before_action :authenticate_user!
  load_and_authorize_resource except: %i[ index new create apply_group cancel_apply join_group leave_group ]

  # GET /groups or /groups.json
  def index
    @groups = Group.all
    #@groups = current_user.groups
    #지금은 테스트를 위해서...
  end

  # GET /groups/1 or /groups/1.json
  def show
    @posts = Post.find(@group.post_recipient_groups.pluck(:post_id))

    #@pending_users = User.includes(:user_groups).where("user_groups.state": "pending")
    #이렇게 하면 사용자가 다른 그룹에서 pending하고 있어도 pending_users에 포함됨...
    @pending_users = User.find(@group.user_groups.where(state: "pending").pluck(:user_id))
    @active_users = User.find(@group.user_groups.where(state: "active").pluck(:user_id))
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
      # usergroup 먼저 save 불가, group만 생성하고 usergroup은 생성되지 못하는 상황은 어떻게 해야할까

      usergroup = UserGroup.new
      usergroup.user_id = current_user.id
      usergroup.group_id = group.id
      usergroup.state = "active"
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
    if current_user.has_role? :group_manager, @group
      if User.find(@group.user_groups.where(state: "active").pluck(:user_id)).count == 1 && \
         UserGroup.where(group_id: @group.id, state: "active").pluck(:user_id).include?(current_user.id)
        #include를 이용해서 array에 value가 포함되어 있는지 비교 가능

        posts = Post.find(@group.post_recipient_groups.pluck(:post_id))
        # 그룹 삭제하면서 해당 posts 모두 삭제
        # postable은 post 삭제하면서 자동으로 삭제됨
        unless posts.blank?
          posts.each do |post|
            post.postable.destroy
            post.destroy
          end
        end

        @group.destroy
        redirect_to groups_url, notice: "Group was successfully destroyed."
      else
        redirect_to groups_url, notice: "group_manager 제외하고 group_member가 존재하면 삭제 불가"
      end
    else
      redirect_to groups_url, notice: "group_manager 아님"
    end
  end

  def join_group
    # apply/approve 없이 바로 join
    if UserGroup.where(user_id: current_user.id, group_id: @group.id).count <= 0
      # 그룹에 속해있지 않다면
      usergroup = UserGroup.new
      usergroup.user_id = current_user.id
      usergroup.group_id = @group.id
      usergroup.state = "active"
      usergroup.save

      current_user.add_role :group_member, @group

      redirect_to groups_path, notice: "You've been added to #{@group.name}."
    else
      redirect_to groups_path, notice: "You're already a member of #{@group.name}."
    end
  end

  def apply_group
    # apply하면 pending user인 상태
    if UserGroup.where(user_id: current_user.id, group_id: @group.id).count <= 0
      usergroup = UserGroup.new
      usergroup.user_id = current_user.id
      usergroup.group_id = @group.id
      usergroup.state = "pending"
      usergroup.save

      redirect_to groups_path, notice: "You've been applied for #{@group.name}."
    else
      redirect_to groups_path, notice: "You're already a member of #{@group.name}."
    end
  end

  def cancel_apply
    # apply 취소
    apply_user = User.find(params[:apply_user_id])

    usergroup = apply_user.user_groups.find_by_group_id(@group.id)
    if usergroup.state == "pending" && usergroup.user_id == apply_user.id && usergroup.group_id == @group.id
      # pending 상태이고, apply_user이고, apply하려는 그룹인 경우
      usergroup.destroy
      redirect_to groups_path, notice: "Applying has been canceled."
    else
      redirect_to @group, notice: "user/group 오류 또는 active 상태가 아님"
    end
  end

  def approve_user
    # group_manager의 apply 승인
    apply_user = User.find(params[:apply_user_id])

    if current_user.has_role? :group_manager, @group
      usergroup = apply_user.user_groups.find_by_group_id(@group.id)

      if usergroup.state == "pending" && usergroup.user_id == apply_user.id && usergroup.group_id == @group.id
      # pending 상태이고, apply_user이고, apply하려는 그룹인 경우
        usergroup.state = "active"
        usergroup.save
        apply_user.add_role :group_member, @group
        redirect_to groups_path, notice: "#{apply_user.name}'s been approved."
      else
        redirect_to groups_path, notice: "user/group 오류 또는 pending 상태가 아님"
      end
    else
      redirect_to groups_path, notice: "group_manager가 아님"
    end
  end

  def suspend_user
    # group_manager가 사용자 suspend
    suspend_user = User.find(params[:suspend_user_id])

    if current_user.has_role? :group_manager, @group
      usergroup = suspend_user.user_groups.find_by_group_id(@group.id)

      if usergroup.state == "active" && usergroup.user_id == suspend_user.id && usergroup.group_id == @group.id
        # active 상태이고, suspend_user이고, suspend하려는 그룹인 경우
        usergroup.state = "pending"
        usergroup.save
        suspend_user.remove_role :group_member, @group
        redirect_to groups_path, notice: "#{suspend_user.name}'s been suspended."
      else
        redirect_to groups_path, notice: "user/group 오류 또는 active 상태가 아님"
      end
    else
      redirect_to groups_path, notice: "group_manager가 아님"
    end
  end

  def leave_group
    # 그룹 탈퇴
    if !current_user.has_role? :group_manager, @group
      current_user.remove_role :group_member, @group
      usergroup = current_user.user_groups.find_by_group_id(@group.id)
      if usergroup.user_id == current_user.id && usergroup.group_id == @group.id
        # 내가 탈퇴하려는 사용자이고 탈퇴하려는 그룹인 경우
        usergroup.destroy
        redirect_to groups_path, notice: "You're no longer a member of #{@group.name}."
      else
        redirect_to @group, notice: "user/group 오류 또는 active 상태가 아님"
      end
    else
      redirect_to groups_path, notice: "group_manager는 탈퇴 불가"
    end
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
