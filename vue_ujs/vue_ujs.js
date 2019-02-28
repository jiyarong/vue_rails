import Vue from 'vue/dist/vue.esm.js'
var renderVueComponentToString = require("vue-server-renderer/basic.js");

self.Vue = Vue;

var RailsVueUJS = {
  initialComponentsContext: function (context) {
    self.RailsVueUJS.getConstructorByName = function (componentName) {
      return context(`./${componentName}`).default;
    }
  },

  handleVueDestructionOn: function(turbolinksEvent, vue) {
    document.addEventListener(turbolinksEvent, function teardown() {
      vue.$destroy();
      document.removeEventListener(turbolinksEvent, teardown);
    });
  },

  TurbolinksAdapter: function(Vue) {
    Vue.mixin({
      beforeMount: function() {
        // If this is the root component, we want to cache the original element contents to replace later
        // We don't care about sub-components, just the root
        if (this == this.$root && this.$el) {
          var destroyEvent = this.$options.turbolinksDestroyEvent || 'turbolinks:visit';
          RailsVueUJS.handleVueDestructionOn(destroyEvent, this);
          this.$originalEl = this.$el.outerHTML;
        }
      },

      destroyed: function() {
        // We only need to revert the html for the root component
        if (this == this.$root && this.$el) {
          this.$el.outerHTML = this.$originalEl;
        }
      }
    })
  },

  use: function (...ms) {
    ms.forEach((m) => {
      self.Vue.use(m);
    })
  },

  initializeVuexStore: function (store) {
    RailsVueUJS.store = store
  },

  serverRender: function (componentName, props={}, router_to=null, initialState={}) {
    let component = self.RailsVueUJS.getConstructorByName(componentName);
    let componentInitialName = componentName.split("/").pop();
    let componentsArgs = {};
    componentsArgs[componentInitialName] = component;
    let initializeObject = {
      data: {data: props},
      template: `<${componentInitialName} :outside="data" :env_ssr="true" />`,
      components: componentsArgs
    };

    if (RailsVueUJS.store !== undefined) {
      let currentState = RailsVueUJS.store.state;
      Object.keys(initialState).forEach((k) => {
        currentState[k] = initialState[k]
      });

      RailsVueUJS.store.replaceState(currentState);

      initializeObject.store = RailsVueUJS.store
    }

    let v = new self.Vue(initializeObject);

    if (component.router && router_to !== null)
      component.router.push(router_to);

    let str = "";

    renderVueComponentToString(v, (err, res) => {
      str = res
    });

    (function (history) {
      if (history && history.length > 0) {
        str += '\n<scr'+'ipt>';
        history.forEach(function (msg) {
          str += '\nconsole.' + msg.level + '.apply(console, ' + JSON.stringify(msg.arguments) + ');';
        });
        str += '\n</scr'+'ipt>';
      }
    })(console.history);

    return str
  },

  detectComponents: function () {
    document.querySelectorAll("[__is_vue_component__=true]").forEach((d) => {
      let componentName = d.getAttribute('name');
      let vueComponent = self.RailsVueUJS.getConstructorByName(componentName);
      let componentInitialName = componentName.split("/").pop();
      let componentsArgs = {};
      componentsArgs[componentInitialName] = vueComponent;

      let initializeObject = {
        el: d,
        data: {data: JSON.parse(d.dataset.vueData)},
        template: `<${componentInitialName} :outside="data" :env_ssr="false" />`,
        components: componentsArgs
      };

      if (RailsVueUJS.store !== undefined) {
        let currentState = RailsVueUJS.store.state;
        let replaceState = JSON.parse(d.dataset.vueState);
        Object.keys(replaceState).forEach((k) => {
          currentState[k] = replaceState[k]
        });

        RailsVueUJS.store.replaceState(currentState);
        initializeObject.store = RailsVueUJS.store
      }

      new Vue(initializeObject)
    })
  },

  detectEvents: function () {
    self.addEventListener('load', function () {
      let TurbolinksDetected = 'Turbolinks' in window && Turbolinks.supported;
      if (TurbolinksDetected) {
        RailsVueUJS.use(RailsVueUJS.TurbolinksAdapter);

        self.addEventListener('turbolinks:load', function () {
          RailsVueUJS.detectComponents();
        })
      }
      RailsVueUJS.detectComponents();
    });
  }
};

if (typeof window !== "undefined") {
  RailsVueUJS.detectEvents();
}

self.RailsVueUJS = RailsVueUJS;
export default RailsVueUJS;
