require 'rails/generators'

module Vue
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "add vue_ujs to javascripts/packs"
      source_root File.expand_path('../../../../', __FILE__)

      def add_initializer
        javascript_packs_dir = ::Webpacker.config.source_entry_path
        javascript_dir = javascript_packs_dir.parent
        template "vue_ujs/vue_ujs.js", "#{javascript_dir}/rails_vue_ujs.js"
        create_file "#{javascript_packs_dir}/vue_server_render.js"

        setup_js = <<-JS
import RailsVueUJS from '../rails_vue_ujs';
var componentRequireContext = require.context("vue_components", true);
RailsVueUJS.initialComponentsContext(componentRequireContext);
self.RailsVueUJS = RailsVueUJS;
        JS
        append_file "#{javascript_packs_dir}/vue_server_render.js", setup_js
        append_file "#{javascript_packs_dir}/application.js", setup_js
        empty_directory "#{javascript_dir}/vue_components"
        remove_file "#{javascript_dir}/app.vue"
        remove_file "#{javascript_packs_dir}/hello_vue.js"
        template "vue_ujs/hello.vue", "#{javascript_dir}/vue_components/hello.vue"
        `yarn add vue-server-renderer`
      end
    end
  end
end