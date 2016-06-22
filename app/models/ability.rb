class Ability
  include CanCan::Ability

  def initialize(user)
    can %i(show edit update), User, id: user.id
    can %i(index show new create), Post
    can %i(edit update), Post, author: user
    can %i(show new create), Comment
    can %i(edit update), Comment, author: user
    can %i(edit update), Comment, post: { author: :user }

    if user.moderator?
      can %i(index show edit update), User
      can %i(edit update), Post
      can %i(edit update), Comment
    end

    if user.admin?
      can %i(index show edit update set_role destroy), User
      can %i(edit update destroy), Post
      can %i(edit update destroy), Comment
    end
  end
end
