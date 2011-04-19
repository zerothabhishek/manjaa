class Post < ActiveRecord::Base
  belongs_to :user
  
  attr_accessor :post_file, :site_file, :push_file
  attr_accessor :post_file_path, :site_file_path, :push_file_path
  
  def post_file; self.created_at.strftime("%Y-%m-%d") + "-" + self.permalink;  end
  def site_file; self.permalink; end
  def push_file; self.permalink; end
  def post_file_path; File.join(self.user.posts_dir, self.post_file);   end
  def site_file_path; File.join(self.user.site_dir,  self.site_file);   end
  def push_file_path; File.join(self.user.push_dir,  self.push_file);   end
  
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
  def unpublished!;   self.update_attribute(:publish_status, "")             end
    
  def do_publish
    Stalker.enqueue("post.preprocess", :post_id => self.id)   unless preprocessed?
    Stalker.enqueue("post.jkyll", :post_id => self.id)        unless jkylled?
    Stalker.enqueue("post.copy",  :post_id => self.id)        unless copied?
    Stalker.enqueue("post.push",  :post_id => self.id)        unless pushed?
  end
  
  def do_remove  
    Stalker.enqueue("post.git_remove", :post_id => self.id)
    Stalker.enqueue("post.cleanup", :post_id => self.id)
    Stalker.enqueue("post.jkyll",   :post_id => self.id)
    Stalker.enqueue("post.copy",    :post_id => self.id, :removing => true)
    Stalker.enqueue("post.push",    :post_id => self.id, :removing => true)        
  end
  
  def preprocess
    begin
      File.open(self.post_file_path, "w") do |f|
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
      FileUtils.cd user.home_path
    
      jekyll_command = "jekyll"
      output = `#{jekyll_command}`
      raise output unless $?.success?
        
      self.jkylled!
    rescue => e
      p e.message
      p e.backtrace
    end  
  end
  
  def copy(removing=false)
    begin
      self.copy_post  unless removing
      self.copy_index            
      self.copied!
    rescue => e
      p e.message
      p e.backtrace
    end  
  end
  
  def copy_post
    cp_cmd = "cp #{self.post_file_path} #{self.push_file_path}"
    output = `#{cp_cmd}`
    raise output unless $?.success?  
  end
  
  def copy_index
    index_file = "index.html"
    site_index_path = File.join(self.user.site_dir, index_file)
    push_index_path = File.join(self.user.push_dir, index_file)

    cp_cmd = "cp #{site_index_path} #{push_index_path}"
    output = `#{cp_cmd}`
    raise output unless $?.success?  
  end
  
  def push(removing=false)
    begin
      self.git_commit_post     unless removing
      self.git_commit_index
      self.git_push
      self.pushed!
    rescue => e
      p e.message
      p e.backtrace
    end
  end
  
  def git_commit_post   
    FileUtils.cd self.user.push_dir        

    git_add_command = "git add #{self.push_file}"
    p "doing #{git_add_command}..."
    output = `#{git_add_command}`
    raise output unless $?.success?
  
    git_commit_command = "git commit -m \"committing #{self.push_file} on #{Time.now}\""
    p "doing #{git_commit_command}..."
    output = `#{git_commit_command}`
    raise output unless $?.success?
    
  end
  
  def git_commit_index
    FileUtils.cd self.user.push_dir    

    index_file = "index.html"
    git_add_command = "git add #{index_file}"
    p "doing #{git_add_command}..."
    output = `#{git_add_command}`
    raise output unless $?.success?

    git_commit_command = "git commit -m \"committing #{index_file} on #{Time.now}\""
    p "doing #{git_commit_command}..."
    output = `#{git_commit_command}`
    raise output unless $?.success?
  end
  
  def git_push  
    FileUtils.cd self.user.push_dir        
    
    git_pull_command = "git pull #{self.user.remote_repo} master"
    p "doing #{git_pull_command}..."
    output = `#{git_pull_command}`
    #don't raise output unless $?.success?

    git_merge_conflict_command = "git checkout . --ours" 
    p "doing #{git_merge_conflict_command}..."
    output = `#{git_merge_conflict_command}`
    raise output unless $?.success?

    git_push_command = "git push #{user.remote_repo} master"
    p "doing #{git_push_command}..."
    output = `#{git_push_command}`
    raise output unless $?.success?
  end
  
  
  # Deletes the files created by the post
  def clean_up    
    FileUtils.rm self.post_file_path
    FileUtils.rm self.site_file_path    
    FileUtils.rm self.push_file_path
  end
  
  def git_remove
    FileUtils.cd self.user.push_dir     
    git_remove_command = "git rm #{self.push_file}"
    p "doing #{git_remove_command}"
    output = `#{git_remove_command}`
    raise output unless $?.success?
  end
  
end

