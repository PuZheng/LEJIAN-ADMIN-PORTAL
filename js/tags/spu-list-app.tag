var riot = require('riot');
var bus = require('riot-bus');
var urlJoin = require('url-join');
require('tags/loader.tag');
var config = require('config');
var buildQS = require('build-qs');
var Pagination = require('pagination');
var decamelize = require('decamelize');
var buildQS = require('build-qs');
require('tags/sortable-th.tag');
require('tags/paginator.tag');
require('tags/dropdown-filter.tag');
require('tags/checkbox-filter.tag');
require('tags/search-filter.tag');
require('tags/batch-delete-btn.tag');
require('tags/spu-table.tag');

<spu-list-app>
  <div class="list-app">
    <div class="ui top attached blue message segment">
      <div class="ui header">
        SPU列表
      </div>
      <a class="ui tiny icon circular green button" href="/spu" data-content="创建SPU">
        <i class="icon plus"></i>
      </a>
      <a riot-tag="batch-delete-btn" ids={ tags['spu-table'].selected } data-content="删除SPU" event="spu.delete" success-event="spu.deleted" ctx={ opts.ctx }></a>
      <div riot-tag="search-filter" placeholder="按名称过滤..." value={ opts.ctx.query.kw } backend={ urlJoin(config.backend, '/spu/auto-complete/{query}') } ctx={ opts.ctx } name="kw"></div>
      <div riot-tag="checkbox-filter" checked_={ opts.ctx.query.onlyEnabled === '1' } label="仅展示激活产品" ctx={ opts.ctx } name='only_enabled'></div>
      <div riot-tag="dropdown-filter" items={ vendors } default-text="厂商" name="vendor_id" value={ opts.ctx.query.vendor } ctx={ opts.ctx }></div>
      <div riot-tag="dropdown-filter" items={ spuTypes } default-text="分类"
        name="spu_type_id" value={ opts.ctx.query.spuType } ctx={ opts.ctx }></div>
      <div riot-tag="dropdown-filter" items={ [1, 2, 3, 4, 5] } default-text="评分" name="rating" value={ opts.ctx.query.rating } ctx={ opts.ctx }></div>

    </div>
    <div class="ui bottom attached segment">
      <loader if={ loading }></loader>
      <spu-table ctx={ opts.ctx }></spu-table>
    </div>
    <div class="ui bottom fixed menu">
      <paginator pagination={ pagination } if={ pagination } ctx={ opts.ctx }></paginator>
    </div>
  </div>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    _.extend(self, {
      urlJoin: urlJoin,
      config: config,
    });

    self.on('mount', function () {
      $(self.root).find('[data-content]').popup();
    }).on('spu.list.fetching spu.list.deleting', function () {
      self.loading = true;
      self.update();
    }).on('spu.list.fetched', function (data) {
      self.pagination = new Pagination({
        leftEdge: 3,
        rightEdge: 3,
        leftCurrent: 3,
        rightCurrent: 3,
        currentPage: self.opts.ctx.query.page || 1,
        perPage: self.opts.ctx.query.perPage || 12,
        totalCount: data.totalCnt,
      }).toJSON();
      self.update();
    }).on('spu.list.fetch.done', function () {
      self.loading = false;
      self.update();
    }).on('vendor.list.fetched', function (data) {
      self.vendors = data.data && data.data.map(function (v) {
        return [v.id, v.name];
      });
      self.update();
    }).on('spuType.list.fetched', function (data) {
      self.spuTypes = data.data && data.data.map(function (spuType) {
        return [spuType.id, spuType.name];
      });
      self.update();
    }).on('spu.deleteing', function () {
      self.loading = true;
      self.update();
    }).on('spu.delete.done', function () {
      self.loading = false;
      self.update();
    }).on('error', function (err) {
      console.error(err);
    });
  </script>
</spu-list-app>
