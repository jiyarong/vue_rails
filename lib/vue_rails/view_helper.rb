module VueRails
  module ViewHelper
    def vue_component(component_name, data={}, options={})
      data[:csrf_token] = form_authenticity_token
      options.merge!(name: component_name, __is_vue_component__: true)
      prerender = options.delete(:prerender)
      state = (options.delete(:state) || {}).to_json
      router_push_to = prerender && prerender.is_a?(String) ? prerender : nil
      content = prerender ?
                    VueRails::Renderer.server_render(component_name, data.to_json, router_push_to, state)&.html_safe : nil
      content_tag(:div, content, options.merge(data: {vue_data: data.to_json, vue_state: state}))
    end
  end
end