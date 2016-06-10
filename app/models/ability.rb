class Ability
  include CanCan::Ability

  def initialize(user)
    can %i(show), User, id: user.id
    can %i(index show), Post
    can %i(edit update), Post, author: user

    if user.moderator?
      can %i(index show edit update), User
      can %i(edit update), Post
    end

    if user.admin?
      can %i(index show edit update set_role destroy), User
      can %i(edit update destroy), Post
    end
  end
end
