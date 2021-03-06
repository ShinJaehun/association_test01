# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, :all

    if user.present?
      if user.has_role?(:admin)
        can :manage, :all
      end

#      can :manage, Book #임시
      can :create, Message
      can :create, Book
#      cannot :manage, Message do |message|
#        message.post.user_id == user.id
#      end

      can :manage, Post, user_id: user.id

      can :manage, Group, id: Group.with_role(:group_manager, user).pluck(:id)

      #can :manage, Message, user_id: user.id
      #야이 븅시나 Message랑 user 관계가 없는 상태인데...
      #이거 오류 찾느라고 힘드렀짜나!

#      can :read, Group
#      can :manage, Group, id: Group.with_role(:group_manager, user).pluck(:id)
#      if user.groups.pluck(:id) == Group.with_role(:group_manager, user).pluck(:id)
#        can :manage, Post
#      end

      can :update, User, id: user.id

    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
