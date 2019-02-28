require "vue_rails/view_helper"

module VueRails
  class Engine < ::Rails::Engine
    isolate_namespace VueRails

    initializer "vue_rails.engine" do
      ActionView::Base.send :include, VueRails::ViewHelper
    end
  end
end