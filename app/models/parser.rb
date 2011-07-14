require 'active_support/core_ext/string'

class Parser

  def self.parse(txt = "")
    txt.strip.squish.split(/\.|\.s/)
  end
  
end
