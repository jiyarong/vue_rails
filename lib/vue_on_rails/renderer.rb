require 'vue_on_rails/asset_finder'

module VueOnRails
  class Renderer
    GLOBAL_WRAPPER = <<-JS
        var global = global || this;
        var self = self || this;
    JS

    CONSOLE_POLYFILL = <<-JS
      var console = { history: [] };
      ['error', 'log', 'info', 'warn'].forEach(function (fn) {
        console[fn] = function () {
          console.history.push({level: fn, arguments: Array.prototype.slice.call(arguments)});
        };
      });
    JS

    cattr_accessor :context
    attr_accessor :component, :props, :router_push_to, :state

    def initialize component, props, router_push_to=nil, state={}
      self.component = component
      self.props = props
      self.router_push_to = router_push_to
      self.state = state
    end

    def self.server_render *args
      new(*args).render
    end

    def render
      if Rails.env.production?
        self.context ||= (
        js_code = VueOnRails::WebpackerAssetFinder.new.find_asset("vue_server_render.js")
        ExecJS.compile(GLOBAL_WRAPPER + CONSOLE_POLYFILL + js_code)
        )
      else
        self.context = (
        js_code = VueOnRails::WebpackerAssetFinder.new.find_asset("vue_server_render.js")
        ExecJS.compile(GLOBAL_WRAPPER + CONSOLE_POLYFILL + js_code)
        )
      end

      self.context.eval("RailsVueUJS.serverRender('#{component}', #{props}, '#{router_push_to}', #{state})")
    end

    private

    def cache_key
      path = VueOnRails::WebpackerAssetFinder.new.find_path("vue_server_render.js")
      Digest::MD5.hexdigest("#{component}_#{JSON.parse(props).delete_if {|k, _| k.to_s == "csrf_token"}}_#{router_push_to}_#{path}_#{state}")
    end
  end
end