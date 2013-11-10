require "pathname"

module VagrantPlugins
  module OpenStack
    module Helper
      action_root = Pathname.new(File.expand_path("../helper", __FILE__))
      autoload :Machine, action_root.join("machine")
    end
  end
end
