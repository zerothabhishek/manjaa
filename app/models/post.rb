class Post < ActiveRecord::Base
  belongs_to :site
  
  after_create :create_j
  after_update :update_j
  after_destroy :delete_j
  
  def create_j
    # create the post file
    # => determine the filename
    # => create the YAML front matter (YFM)
    # => save the YFM+content 
    
    # determine filename
    date_str = created_at.strftime("%Y-%m-%d")
    title_str = title.gsub(/\s/,/-/)
    filename = "#{date_str}-#{title_str}.md"
    
    # create YFM
    # => currently expecting YFM within content
    
    # save
    File.open(filename,"w"){ |f| f.write(content) }
  end
  
  def update_j
  end
  
  def delete_j
  end
  
end
