var riot = require('riot');
var bus = require('riot-bus');
var urlJoin = require('url-join');
require('tags/loader.tag');
var config = require('config');
var buildQS = require('build-qs');
var Pagination = require('pagination');
var moment = require('moment');
var decamelize = require('decamelize');
var buildQS = require('build-qs');
require('tags/sortable-th.tag');
require('tags/paginator.tag');
require('tags/dropdown-filter.tag');
require('tags/checkbox-filter.tag');
require('tags/search-filter.tag');
require('tags/batch-delete-btn.tag');

<spu-list-app>
  <div class="ui grid list">
    <div class="ui top attached blue message segment">
      <div class="ui header">
        SPU列表
      </div>
      <a class="ui tiny icon circular green button" href="/spu" data-content="创建SPU">
        <i class="icon plus"></i>
      </a>
      <a riot-tag="batch-delete-btn" ids={ selected } data-content="删除SPU" event="spu.delete"></a>
    </div>
    <div class="ui attached segment filters">
      <div riot-tag="search-filter" placeholder="输入SPU名称" value={ opts.ctx.query.kw } backend={ urlJoin(config.backend, '/spu/auto-complete/{query}') } ctx={ opts.ctx } name="kw"></div>
      <div riot-tag="checkbox-filter" checked={ opts.ctx.query.onlyEnabled === '1' } label="仅展示激活产品" ctx={ opts.ctx } name='only_enabled'></div>
      <div riot-tag="dropdown-filter" items={ vendors } default-text="厂商" name="vendor" value={ opts.ctx.query.vendor } ctx={ opts.ctx }></div>
      <div riot-tag="dropdown-filter" items={ spuTypes } default-text="分类"
        name="spu_type" value={ opts.ctx.query.spuType } ctx={ opts.ctx }></div>
      <div riot-tag="dropdown-filter" items={ [1, 2, 3, 4, 5] } default-text="评分" name="rating" value={ opts.ctx.query.rating } ctx={ opts.ctx }></div>
    </div>
    <div class="ui bottom attached segment">
      <loader if={ loading }></loader>
      <table class="ui sortable compact striped table" if={ !loading && !_.isEmpty(items) }>
        <thead>
          <tr>
            <th>
              <div class="select-all ui checkbox">
                <input type="checkbox">
                <label for=""></label>
              </div>
            </th>
            <th riot-tag="sortable-th" label="编号" name="id" ctx={ opts.ctx }></th>
            <th>封面</th>
            <th>名称</th>
            <th>激活</th>
            <th riot-tag="sortable-th" label="零售价" name="msrp" ctx={ opts.ctx }>
            </th>
            <th>厂商</th>
            <th>分类</th>
            <th riot-tag="sortable-th" label="评分" name="rating" ctx={ opts.ctx }></th>
            <th riot-tag="sortable-th" label="创建时间" name="create_time" ctx={ opts.ctx }></th>
          </tr>
        </thead>
        <tbody>
          <tr each={items}>
            <td>
              <div class="select ui checkbox">
                <input type="checkbox" data-id={ id }>
                <label for=""></label>
              </div>
            </td>
            <td>
              <a href="/spu/{ id }">{ id }</a>
            </td>
            <td>
              <div class="ui tiny image">
                <img src="{ urlJoin(config.backend, icon) }" alt="">
              </div>
            </td>
            <td>
              { name }
            </td>
            <td>
              <i class="icon { enabled? 'green checkmark': 'red remove' }"></i>
            </td>
            <td>
              { msrp }
            </td>
            <td>
              <a href="/vendor/{ vendorId }">{ vendor.name }</a>
            </td>
            <td>
              <a href="/spu-type/{ spuTypeId }">{ spuType.name }</a>
            </td>
            <td>
              { rating }
            </td>
            <td>
              { moment(createTime).format('YY-MM-DD HH时') }
            </td>
          </tr>
        </tbody>
      <table>
      <div class="ui teal message" if={ !loading && _.isEmpty(items) }>
        -- 没有数据 --
      </div>
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
      moment: moment,
      selected: new Set(),
    });

    self.on('mount', function () {
      $(self.root).find('[data-content]').popup();
    }).on('spu.list.fetchding', function () {
      self.loading = true;
      self.update();
    }).on('spu.list.fetched', function (data) {
      self.items = data.data;
      self.totalCnt = data.totalCnt;
      self.loading = false;
      self.pagination = new Pagination({
        currentPage: self.opts.ctx.query.page || 1,
        perPage: self.opts.ctx.query.perPage || 12,
        totalCount: self.totalCnt,
      });
      self.update();
      $(self.root).find('.select-all.checkbox').checkbox({
        onChecked: function () {
          $(self.root).find('.ui.select.checkbox').checkbox('check');
        },
        onUnchecked: function () {
          $(self.root).find('.ui.select.checkbox').checkbox('uncheck');
        }
      }).checkbox('set unchecked');
      $(self.root).find('.ui.select.checkbox').checkbox({
        onChecked: function () {
          self.selected.add($(this).data('id'));
        },
        onUnchecked: function () {
          self.selected.delete($(this).data('id'));
        }
      });
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
    }).on('spu.deleted', function () {
      swal({
        type: 'success',
        title: '',
        text: '删除成功!'
      }, function () {
        bus.trigger('go', opts.ctx.path);
      });
    }).on('spu.delete.done', function () {
      self.loading = false;
      self.update();
    }).on('error', function (err) {
      console.error(err);
    });
  </script>
</spu-list-app>
