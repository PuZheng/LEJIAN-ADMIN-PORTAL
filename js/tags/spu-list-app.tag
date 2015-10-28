var riot = require('riot');
var bus = require('riot-bus');
require('tags/loader.tag');
var urljoin = require('url-join');
var config = require('config');
require('tags/paginator.tag');


<spu-list-app>
  <div class="ui page container">
    <div class="ui top attached blue message">
      SPU列表 - 共{ totalCnt }个
    </div>
    <div class="ui bottom attached segment">
      <loader if={ loading }></loader>
      <div class="ui items">
        <div class="item" each={ items }>
          <div class="image">
            <a href="/spu/spu/{id}">
              <img src={ urljoin(config.backend, icon) }>
            </a>
          </div>
          <div class="content">
            <a class="header" href="/spu/spu/{ id }" >{ name }</a>
            <div class="meta">
              <span>
                <i class="icon yen"></i>
                { msrp/100 }
              </span>
            </div>
            <div class="description">
              <p>{ description }</p>
            </div>
            <div class="extra">
              Additional Details
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="ui bottom attached segment">
      <paginator pagination=pagination urlFor=urlFor></paginator>
    </div>
  </div>
  <style scoped>
    .bottom.attached.segment {
      min-height: 32rem !important;
    }
  </style>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    _.extend(self, {
      urljoin: urljoin,
      config: config
    });

    self.on('spu.list.fetching', function () {
      self.loading = true;
      self.update();
    }).on('spu.list.fetched', function (data) {
      self.items = data.data;
      self.totalCnt = data.totalCnt;
      self.loading = false;
      self.update();
    });
  </script>
</spu-list-app>
