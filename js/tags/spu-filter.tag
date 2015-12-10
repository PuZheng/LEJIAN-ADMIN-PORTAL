var riot = require('riot');
var bus = require('riot-bus');
var buildQS = require('build-qs');

require('tags/search.tag');
require('tags/loader.tag');
require('perfect-scrollbar/dist/css/perfect-scrollbar.min.css');
require('perfect-scrollbar/dist/js/min/perfect-scrollbar.jquery.min.js');

<spu-filter>
  <loader if={ loading }></loader>
  <div class="ui search">
    <div class="ui icon input">
      <input class="prompt" type="text" placeholder="搜索SPU...">
      <i class="search icon"></i>
    </div>
    <div class="results"></div>
  </div>
  <div class="ui vertical menu">
    <a href="#" class="{ !opts.ctx.query.spu && 'active teal' } item" onclick={ clickHandler }>-- 不限SPU --</a>
    <a class="{ (item.id == parent.opts.ctx.query.spu) && 'active teal' } item" each={ item in items } data-spu={ item.id } href="#" onclick={ clickHandler }>
      { item.name } - <i>{ item.vendor.name }</i>
    </a>
  </div>
  <style scoped>
    .vertical.menu {
      margin-top: 0px;
      position: relative;
    }
    a.item > i {
      font-size: 85%;
    }
    a.item:not(.teal) > i {
      color: rgba(0, 0, 0, 0.3);
    }
  </style>
  <script>
    var self = this;
    self.mixin(bus.Mixin);

    self.on('spu.list.fetching', function () {
      self.loading = true;
      self.update();
    }).on('spu.list.fetch.done', function () {
      self.loading = false;
      self.update();
    }).on('spu.list.fetched', function (data) {
      self.allItems = data.data;
      self.items = self.allItems;
      self.update();
      var $menu = $(self.root).children('.menu');
      $menu.height($(window).height() - $menu.offset().top - 20);
      $menu.perfectScrollbar();
    }).on('mount', function () {
      $(self.root).find('.search input').keyup(function (e) {
        var kw = $(e.target).val().toLowerCase();
        self.items = self.allItems.filter(function (item) {
          return ~item.name.toLowerCase().indexOf(kw);
        });
        self.update();
      });
    });

    self.clickHandler = function (e) {
      e.preventDefault();
      var spuId = $(e.currentTarget).data('spu');
      if (spuId) {
        opts.ctx.query.spu = spuId;
      } else {
        delete opts.ctx.query.spu;
      }
      bus.trigger('go', opts.ctx.pathname + '?' + buildQS(opts.ctx.query));
    };
  </script>
</spu-filter>

