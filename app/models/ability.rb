class Ability
  include CanCan::Ability

  def initialize(user)
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

    self.clear_aliased_actions
    # override cancan default aliasing (we don't want to differentiate between read and index)
    alias_action :delete, to: :destroy
    alias_action :edit, to: :update
    alias_action :new, to: :create
    alias_action :new_action, to: :create
    alias_action :show, to: :read
    alias_action :index, :read, to: :display
    alias_action :create, :update, :destroy, to: :modify

    # user ||= User.new # guest user (not logged in)
    # if user.admin?
    #   can :manage, :all
    # else
      if user
        can :display, Box
        can :modify, Box, user_id: user.id
        can :display, Following, user_id: user.id
        can :display, Balance, user_id: user.id
        can :display, Withdraw, user_id: user.id
        can :display, Order, user_id: user.id
        can :modify, Order, user_id: user.id
      end
    # end
  end
end
