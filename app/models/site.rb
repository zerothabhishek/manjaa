class Site < ActiveRecord::Base
  has_many :posts
  
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
  end
  
  def j_update
  end
  
  def j_destroy
  end
  
  def default_layout_content
    File.read "#{Rails.root}/public/liquids/default.html"
  end
  
end
