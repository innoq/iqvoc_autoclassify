# encoding: UTF-8

require 'iqvoc/auto_classify/version'

module IqvocAutoclassify

  unless Iqvoc.const_defined?(:AutoClassify) && Iqvoc::AutoClassify.const_defined?(:Application)
    require File.join(File.dirname(__FILE__), '../config/engine')
  end

  ActiveSupport.on_load(:after_iqvoc_config) do
    require 'iqvoc'
  end

end
