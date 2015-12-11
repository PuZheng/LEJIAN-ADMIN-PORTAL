var riot = require('riot');
var bus = require('riot-bus');
require('tags/batch-delete-btn.tag');
require('tags/checkbox-filter.tag');
require('tags/vendor-table.tag');
require('tags/loader.tag');

var buildQS = require('build-qs');

<vendor-list-app>
  <div class="list-app">
    <div class="ui top attached info message segment">
      <div class="ui header">
        厂商列表
      </div>
      <a class="ui tiny icon green circular button" href="/vendor" data-content="创建厂商">
        <i class="icon plus"></i>
      </a>
      <div class="ui search">
        <div class="ui icon input">
          <input class="prompt" type="text" placeholder="按名称过滤..." name="search" onkeyup={ doSearch } value={ opts.ctx.query.kw }>
          <i class="search icon"></i>
        </div>
        <div class="results"></div>
      </div>
      <div riot-tag="checkbox-filter" checked_={ opts.ctx.query.onlyEnabled === '1' } label="仅展示激活" name="only_enabled" ctx={ opts.ctx }></div>
    </div>
    <div class="ui bottom attached segment">
      <loader if={ loading }></loader>
      <vendor-table ctx={ opts.ctx }></vendor-table>
    </div>
  </div>
  <script>
    var self = this;
    self.mixin(bus.Mixin);

    self.doSearch = function (e) {
      var kw = $(e.target).val();
      if (kw) {
        opts.ctx.query.kw = encodeURIComponent(kw);
      } else {
        delete opts.ctx.query.kw;
      }
      bus.trigger('go', '/vendor-list?' + buildQS(opts.ctx.query));
    };
    self.on('vendor.list.fetching', function () {
      self.loading = true;
      self.update();
    }).on('vendor.list.fetch.done', function () {
      self.loading = false;
      self.update();
    });
  </script>
</vendor-list-app>
