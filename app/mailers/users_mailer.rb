class UsersMailer < ApplicationMailer
  def new_user(user)
    @user = user
    mail to: User.admin.first.email, subject: 'New user'
  end
end
