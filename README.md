# VueRails

## Get started with Webpacker
#### add webpacker and vue_rails to your gemfile
```ruby
gem 'webpacker'
gem 'vue_rails'
```

#### run installers
```shell
$ bundle install
$ rails webpacker:install
$ rails webpacker:install:vue
$ rails generate vue:install
```

#### confirm your webpacker source_entry path
```
|-- app
   |-- javascript
      |-- packs
         |-- application.js
         |-- vue_server_render.js
      |-- vue_components
         |-- hello.vue
      |-- rails_vue_ujs.js
```
#### all the vue components should be initialized in `vue_componects`

## Basic Usage

**1. add javascript_pack_tag to application.html**
```ruby
<%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
```
**2. generate a controller and view**

example:
```shell
$ rails generate controller home index
```
and don't forget the router config!

**3. add vue_components in your home/index.html**
```ruby
<%= vue_component("hello") %>
```

multiple components render is also work!
```
<%= vue_component("hello") %>
<%= vue_component("hello") %>
<%= vue_component("hello") %>
```

**4. open the browser and check it, it should been works!** 

## Advanced Usage

### pass props to your components
```ruby
<%= vue_component("hello", {foo: 'bar'}) %>
```
in your component hello.vue:
```vue
<template>
  <div id="app">
    <p>{{ outside.foo }}</p>
  </div>
</template>

<script>
  export default {
    props: ['outside'],
    data: function () {
      return {
        message: "Hello Vue!"
      }
    }
  }
</script>
```

hash or array is also works
```ruby
<%= vue_component("hello", {foo: {name: 'Peter'}}) %>
```

```vue
<template>
  <div id="app">
    <p>{{ outside.foo.name }}</p>
  </div>
</template>

<script>
  export default {
    props: ['outside'],
    data: function () {
      return {
        message: "Hello Vue!"
      }
    }
  }
</script>
```

```ruby
<%= vue_component("hello", {foo: [1,2,3]}) %>
```

```vue
<template>
  <div id="app">
  	<template v-for="i in outside.foo">
  	  <div>{{i}}</div>
	</template>	
    <p>{{ outside.foo.name }}</p>
  </div>
</template>

<script>
  export default {
    props: ['outside'],
    data: function () {
      return {
        message: "Hello Vue!"
      }
    }
  }
</script>
```

### server side render
**If you're just a component for rendering small parts, you should not use server side render!**

with options `prerender`, server side will prerender a dom before vue components initialize in client side

```
<%= vue_component("hello", {foo: [1,2,3]}, {prerender: true}) %>
```


### server side render with vue-router
```shell
$ yarn add vue-router
```
in both application.js and vue_server_render.js
```js
import VueRouter from 'vue-router';

RailsVueUJS.use(VueRouter);

```

and your vue component

```html
<template>
    <div class="container">
      <div class="content">
        <router-view :outside="outside"></router-view>
      </div>
    </div>
</template>

<script>
  import VueRouter from 'vue-router';
  import PostList from './posts/index';
  import PostDetail from './posts/show';
  import newPost from './posts/new';
  import EditPost from './posts/edit';

  const routes = [
    {
      path: '/',
      component: PostList,
      name: 'post_index',
      props: true
    },
    {
      path: '/posts/new',
      component: newPost,
      name: 'new_post'
    },
    {
      path: '/posts/edit/:id',
      component: EditPost,
      name: 'edit_post'
    },
    {
      path: '/posts/:id',
      component: PostDetail,
      name: 'post_detail'
    }
  ];

  const router = new VueRouter({
    mode: 'history',
    routes
  });

  export default {
    props: ['outside'],
    router
  };
</script>
```

option prerender can receive a path for vue router
```html
<%= vue_component("hello", {foo: [1,2,3]}, {prerender: request.path}) %>
```

in your routes.rb
```ruby
  get '*path', to: 'home#index'
```

### server side render with vuex
```shell
$ yarn add vuex
```

initialize a store

```js
import Vue from 'vue'
import Vuex from 'vuex';

Vue.use(Vuex);
const store = new Vuex.Store({
  state: {
    currentUser: {},
    hasLogin: false
  }
});

export default store;
```

in both application.js and vue_server_render.js
```js
import VueRouter from 'vue-router';
import Vuex from 'vuex';
import store from "../vue_components/store";

RailsVueUJS.use(VueRouter, Vuex);
RailsVueUJS.initializeVuexStore(store);
...
```

in your html file
```html
<%= vue_component("hello", {foo: [1,2,3]}, {prerender: true, state: {
  hasLogin: true
}}) %>
```

with option `state`, it will replace your vuex state, for more information see the doc with vuex 

in your component
```html
...
<div v-if="$store.state.hasLogin">
  <a href="/users/logout">logout</a>
</div>
...
```


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the VueRails project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/vue_rails/blob/master/CODE_OF_CONDUCT.md).
