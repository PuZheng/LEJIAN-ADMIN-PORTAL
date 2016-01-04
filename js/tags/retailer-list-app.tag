var riot = require('riot');
var bus = require('riot-bus');

require('tags/loader.tag');
require('tags/retailer-table.tag');
require('tags/search-filter.tag');
require('tags/checkbox-filter.tag');
require('tags/dropdown-filter.tag');

require('tags/paginator.tag');
var Pagination = require('pagination');
var urlJoin = require('url-join');
var config = require('config');

<retailer-list-app>
  <div class="list-app">
    <div class="ui top attached blue message segment">
      <div class="ui header">零售商列表</div>
      <a class="ui tiny icon circular green button" href="/retailer" data-content="创建零售商">
        <i class="icon plus"></i>
      </a>
      <div riot-tag="search-filter" placeholder="按名称过滤..." value={ opts.ctx.query.kw } backend={ urlJoin(config.backend, '/retailer/auto-complete/{query}') } ctx={ opts.ctx } name="kw"></div>
      <div riot-tag="checkbox-filter" checked_={ opts.ctx.query.enabledOnly === '1' } label="仅展示激活" ctx={ opts.ctx } name='enabled_only'></div>
      <div riot-tag="dropdown-filter" items={ [1, 2, 3, 4, 5] } default-text="评分" name="rating" value={ opts.ctx.query.rating } ctx={ opts.ctx }></div>
    </div>
    <div class="ui bottom attached segment">
      <loader if={ loading }></loader>
      <retailer-table ctx={ opts.ctx }></retailer-table>
    </div>
    <div class="ui bottom fixed menu">
      <paginator pagination={ pagination } if={ pagination } ctx={ opts.ctx }></paginator>
    </div>
  </div>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.urlJoin = urlJoin;
    self.config = config

    self.on('retailer.list.fetching', function () {
      self.loading = true;
      self.update();
    }).on('retailer.list.fetched', function (data) {
      self.items = data.data;
      self.pagination = new Pagination({
        currentPage: self.opts.ctx.query.page,
        perPage: self.opts.ctx.query.perPage,
        totalCount: data.totalCnt,
        leftEdge: 3,
        rightEdge: 3,
        leftCurrent: 3,
        rightCurrent: 3,
      }).toJSON();
      self.update();
    }).on('retailer.list.fetch.done', function () {
      self.loading = false;
      self.update();
    });
  </script>
</retailer-list-app>

