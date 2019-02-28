require "vue_on_rails/view_helper"

module VueOnRails
  class Engine < ::Rails::Engine
    isolate_namespace VueOnRails

    initializer "vue_on_rails.engine" do
      ActionView::Base.send :include, VueOnRails::ViewHelper
    end
  end
end