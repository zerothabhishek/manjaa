class Post < ActiveRecord::Base
  belongs_to :user
  
  def yafm
    fm = {
      "title"     => title,
      "permalink" => permalink,
      "date"      =>  updated_at.strftime("%d %B %Y")         # 12 april 2011
    }
    yafm = "#{fm.to_yaml}---\n"    
  end
  
  # publish status getters
  def preprocessed?;  self.publish_status=="PREPROCESSED" end
  def jkylled?;       self.publish_status=="JKYLLED"      end
  def pushed?;        self.publish_status=="PUSHED"       end
  def unpublished?;   self.publish_status.blank?          end
  def published?;           pushed?                       end
  def almost_published?;    !unpublished? && !pushed?     end
  
  # publish status setters
  def preprocessed!;  self.update_attribute(:publish_status, "PREPROCESSED") end
  def jkylled!;       self.update_attribute(:publish_status, "JKYLLED")      end
  def pushed!;        self.update_attribute(:publish_status, "PUSHED")       end

  def do_publish
    do_preprocessing    unless preprocessed?
    do_jkylling         unless jkylled?
    do_pushing          unless pushed?
  end
  
  def do_preprocessing(background=true)
    preprocess_it   if background == false
    Stalker.enqueue("post.preprocess", :post_id => self.id)
  end
  
  def do_jkylling(background=true)
    jkyll_it        if background == false
    Stalker.enqueue("post.jkyll", :post_id => self.id)
  end
  
  def do_pushing(background=true) 
    push_it         if background ==false
    Stalker.enqueue("post.push", :post_id => self.id)
  end

  private
  
  def preprocess_it
    username = user.name
    sites_home = Manjaa::Application.config.sites_path
    user_home = "#{sites_home}/#{username}"  
    filename = permalink
    filepath = "#{user_home}/_posts/#{filename}"

    File.open(filepath, "w") do |f|
      f.write self.yafm
      f.write self.content
    end
    self.preprocessed!
  end
  
  def jkyll_it
    username = user.name
    sites_home = Manjaa::Application.config.sites_path
    user_home = "#{sites_home}/#{username}"  
    source_path = "#{user_home}/_posts"
    site_path = "#{user_home}/_site"
    jekyll_command = "jekyll #{source_path} #{site_path}"
    output = `#{jekyll_command}`
    raise output unless $?.success?
        
    self.jkylled!
  end
  
  def push_it
    username = user.name
    sites_home = Manjaa::Application.config.sites_path
    user_home = "#{sites_home}/#{username}"  
    user_site = "#{user_home}/_site"
    FileUtils.cd user_site

    post_file = permalink    
    git_add_command = "git add #{post_file}"
    git_commit_command = "git commit -m \"committing #{post_file} on #{Time.now}\""
    git_pull_command = "git pull origin master"
    git_push_command = "git push origin master"
    git_merge_conflict_command = "git checkout #{post_file} --ours" 


    output = `#{git_add_command}`
    raise output unless $?.success?
    
    output = `#{git_commit_command}`
    raise output unless $?.success?

    output = `#{git_pull_command}`
    raise output unless $?.success?

    output = `#{git_merge_conflict_command}`
    raise output unless $?.success?

    output = `#{git_push_command}`
    raise output unless $?.success?
    
    self.published!
  end
end

