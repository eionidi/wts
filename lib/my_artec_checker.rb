class MyArtecChecker
  def check_user(email)
    response = RestClient.get "https://staging-booth-my.artec3d.com/users/exist.json?user[email]=#{email}"
    response = JSON.parse response.body
    response['exist'] ? "https://staging-booth-my.artec3d.com/users?utf8=%E2%9C%93&filter%5Bsearch%5D=#{email}" : nil
  end
end
