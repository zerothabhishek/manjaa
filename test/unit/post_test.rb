require 'test_helper'

class PostTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "preprocess should create a file for the post in _posts" do
    post = Post.make
    post.preprocess
  end
  
  test "preprocess should place the YAML front matter in the _posts file" do
  end
  
  test "preprocess should place the post content in the _posts file " do
  end
  
  test "proprocess should mark the post as processed at last" do
  end
  
end
