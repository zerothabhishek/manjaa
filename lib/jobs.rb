
job "jekyll.init" do |args|
  user = User.find args['user_id'].to_i
  user.initilize_site
end

job "github.fetch-access-token" do |args|  
  user = User.find args['user_id'].to_i  
  user.setup_github_access(args["code"])
end

job "github.get-user-info" do |args|  
  user = User.find args['user_id'].to_i  
  user.identify_github_username
end

job "github.create-repo" do |args|
  user = User.find args['user_id'].to_i  
  user.create_site_repo
end

job "github.upload-public-key" do |args|
  user = User.find args['user_id'].to_i  
  user.upload_public_key
end

job "post.preprocess" do |args|
  post = Post.find args["post_id"].to_i
  post.preprocess
end

job "post.jkyll" do |args|
  post = Post.find args["post_id"].to_i
  post.jkyll
end

job "post.copy" do |args|
  post = Post.find args["post_id"].to_i
  post.copy(args["removing"].true?)
end

job "post.push" do |args|
  post = Post.find args["post_id"].to_i
  post.push(args["removing"].true?)
end

job "post.git-remove" do |args|
  post = Post.find args["post_id"].to_i
  post.git_remove
end

job "post.cleanup" do |args|
  post = Post.find args["post_id"].to_i
  post.cleanup
end
