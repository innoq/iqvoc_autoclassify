require 'digest/sha1'

class Document < ActiveRecord::Base
  has_many :classifications, :dependent => :destroy
  
  before_save do |document|
    self.content_hash = Digest::SHA1.hexdigest(content)
  end
  
end
