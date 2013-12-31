# encoding: UTF-8

require 'iqvoc/auto_classify/version'

module IqvocAutoclassify

  def self.app?
    Iqvoc.const_defined?(:AutoClassify) && Iqvoc::AutoClassify.const_defined?(:Application)
  end

  def self.root
    if app?
      Rails.root
    else
      Iqvoc::AutoClassify::Engine.root
    end
  end

  unless app?
    require File.join(File.dirname(__FILE__), '../config/engine')
  end

  ActiveSupport.on_load(:after_iqvoc_config) do
    require 'iqvoc'
  end

end
