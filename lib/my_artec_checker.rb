class MyArtecChecker
  def check_user(email)
  	response = RestClient.get "https://staging-booth-my.artec3d.com/users/exist.json?user[email]=#{email}"
  	response.body
  end
end