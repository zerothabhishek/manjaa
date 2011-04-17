class Post < ActiveRecord::Base
  belongs_to :user
  
  def yafm
    fm = {
      "layout"    => "default",
      "title"     => title,
      "permalink" => permalink,
      "date"      => updated_at.strftime("%d %B %Y")         # 12 april 2011
    }
    yafm = "#{fm.to_yaml}---\n"    
  end
  
  # publish status getters
  def preprocessed?;  self.publish_status=="PREPROCESSED" end
  def jkylled?;       self.publish_status=="JKYLLED"      end
  def copied?;        self.publish_status=="COPIED"       end
  def pushed?;        self.publish_status=="PUSHED"       end
  def unpublished?;   self.publish_status.blank?          end
  def published?;           pushed?                       end
  def almost_published?;    !unpublished? && !pushed?     end
  
  # publish status setters
  def preprocessed!;  self.update_attribute(:publish_status, "PREPROCESSED") end
  def jkylled!;       self.update_attribute(:publish_status, "JKYLLED")      end
  def copied!;        self.update_attribute(:publish_status, "COPIED")       end
  def pushed!;        self.update_attribute(:publish_status, "PUSHED")       end

  def do_publish
    Stalker.enqueue("post.preprocess", :post_id => self.id)   unless preprocessed?
    Stalker.enqueue("post.jkyll", :post_id => self.id)        unless jkylled?
    Stalker.enqueue("post.copy",  :post_id => self.id)        unless copied?
    Stalker.enqueue("post.push",  :post_id => self.id)        unless pushed?
  end
    
  def preprocess
    begin
      username = user.name
      sites_home = Manjaa::Application.config.sites_path
      user_home = "#{sites_home}/#{username}"  
      filename = updated_at.strftime("%Y-%m-%d") + "-" + permalink
      filepath = "#{user_home}/_posts/#{filename}"

      File.open(filepath, "w") do |f|
        f.write self.yafm
        f.write self.content
      end
      self.preprocessed!
    rescue => e
      p e.message
      p e.backtrace
    end      
  end
  
  def jkyll
    begin
      user_home = user.home_path
      FileUtils.cd user_home
    
      jekyll_command = "jekyll"
      output = `#{jekyll_command}`
      raise output unless $?.success?
        
      self.jkylled!
    rescue => e
      p e.message
      p e.backtrace
    end  
  end
  
  def copy
    begin
      site_path = "#{user.home_path}/_site"
      push_path = "#{user.home_path}/_push"
    
      post_file = permalink    
      index_file = "index.html"
    
      cp_cmd = "cp #{site_path}/#{post_file} #{push_path}/#{post_file}"
      output = `#{cp_cmd}`
      raise output unless $?.success?
        
      cp_cmd = "cp #{site_path}/#{index_file} #{push_path}/#{index_file}"
      output = `#{cp_cmd}`
      raise output unless $?.success?  
    
      self.copied!
    rescue => e
      p e.message
      p e.backtrace
    end  
  end
  
  def push
    begin
      push_path = "#{user.home_path}/_push"    
      FileUtils.cd push_path    
    
      post_file = permalink    
      index_file = "index.html"
      git_add_command = "git add #{post_file} #{index_file}"
      git_commit_command = "git commit -m \"committing #{post_file} on #{Time.now}\""
      git_pull_command = "git pull #{user.remote_repo} master"
      git_push_command = "git push #{user.remote_repo} master"
      git_merge_conflict_command = "git checkout #{post_file} #{index_file} --ours" 

      p "doing #{git_add_command}..."
      output = `#{git_add_command}`
      raise output unless $?.success?
    
      p "doing #{git_commit_command}..."
      output = `#{git_commit_command}`
      raise output unless $?.success?

      p "doing #{git_pull_command}..."
      output = `#{git_pull_command}`
      raise output unless $?.success?

      p "doing #{git_merge_conflict_command}..."
      output = `#{git_merge_conflict_command}`
      raise output unless $?.success?

      p "doing #{git_push_command}..."
      output = `#{git_push_command}`
      raise output unless $?.success?
    
      self.pushed!
    rescue => e
      p e.message
      p e.backtrace
    end    
  end
end

