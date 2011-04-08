class Site < ActiveRecord::Base
  has_many :posts
  #has_one :option_set
  
  after_create :j_create
  after_update :j_update
  after_destroy :j_destroy
  
  def j_create
    root = File.expand_path(self.root)

    # generate jekyll directory structure
    FileUtils.mkdir_p "#{root}"
    FileUtils.mkdir_p "#{root}/_site"
    FileUtils.mkdir_p "#{root}/_posts"
    FileUtils.mkdir_p "#{root}/_layouts"
    
    # Create important files
    FileUtils.touch   "#{root}/_config.yml"
    FileUtils.touch   "#{root}/_layouts/default.html"    
    
    # Put default content in default layout
    File.open("#{root}/_layouts/default.html", "w"){ |f| f.write(default_layout_content) }
    
    # git initialization and settings for _posts
    setup_git
  end
  
  def setup_git
    # initialize a git repo in the _posts folder
    init_command = "cd #{root}/_posts; git init ."
    `#{init_command}`    
    
    # set the remote origin
    origin = "git@github.com:#{self.user.github_username}/#{self.name}.git"
    set_origin_command = "git remote add origin #{origin}"
    `#{set_origin_command}`    
  end
  
  def j_update
  end
  
  def j_destroy
  end
  
  def default_layout_content
    File.read "#{Rails.root}/public/liquids/default.html"
  end
  
  # Runs the jekyll command to generate the site
  def j_generate
    options = Jekyll::DEFAULTS
    options['source'] = "#{root}"
    options['destination'] = "#{root}/_site"
    j_site = Jekyll::Site.new(options)
    j_site.process
  end
  
  def j_push
    add_command = "git add ."
    commit_msg = "commit dated #{Time.now}"
    commit_command = "git commit -m #{commit_msg}"
    push_command = "git push origin master"
    
    FileUtils.cd "#{root}/_posts"
    `#{add_command}`
    `#{commit_command}`
    `#{push_command}`
  end
  
end
