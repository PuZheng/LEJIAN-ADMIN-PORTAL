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
require('tags/dropdown.tag');
require('tags/checkbox.tag');
require('tags/search.tag');

<spu-list-app>
  <div class="ui grid list">
    <div class="ui top attached blue message segment">
      <div class="ui header">
        SPU列表
      </div>
      <a class="ui tiny icon circular green button" href="/spu" data-content="创建SPU">
        <i class="icon plus"></i>
      </a>
      <a class="ui tiny icon circular red button" href="#" data-content="删除SPU" onclick={ deleteHandlers }>
        <i class="icon trash"></i>
      </a>
    </div>
    <div class="ui attached segment filters">
      <div riot-tag="search" placeholder="输入SPU名称" value={ opts.ctx.query.kw } backend={ urlJoin(config.backend, '/spu/auto-complete/{query}') } on-submit={ onSearchSubmit } on-select={ onSearchSelect }></div>
      <div riot-tag="checkbox" checked={ opts.ctx.query.onlyEnabled === '1' } label="仅展示激活产品" on-change={ filterHandlers.onlyEnabled }></div>
      <div riot-tag="dropdown" items={ vendors } on-change={ filterHandlers.vendor } default-text="厂商" name="vendor" value={ opts.ctx.query.vendor }></div>
      <div riot-tag="dropdown" items={ spuTypes } on-change={ filterHandlers.spuType } default-text="分类"
        name="spu_type" value={ opts.ctx.query.spuType }></div>
      <div riot-tag="dropdown" items={ [1, 2, 3, 4, 5] } on-change={ filterHandlers.rating } default-text="评分" name="rating" value={ opts.ctx.query.rating }></div>
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
            <th riot-tag="sortable-th" sort-by={ sortBy } label="编号" name="id" onclick={ sortHandlers.id }></th>
            <th>封面</th>
            <th>名称</th>
            <th>激活</th>
            <th riot-tag="sortable-th" sort-by={ sortBy } label="零售价" name="msrp" onclick={ sortHandlers.msrp }>
            </th>
            <th>厂商</th>
            <th>分类</th>
            <th riot-tag="sortable-th" sort-by={ sortBy } label="评分" name="rating" onclick={ sortHandlers.rating }></th>
            <th riot-tag="sortable-th" sort-by={ sortBy } label="创建时间" name="createTime" onclick={ sortHandlers.createTime }></th>
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
      <paginator pagination={ pagination } url-for={ urlFor } if={ pagination }></paginator>
    </div>
  </div>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    _.extend(self, {
      urlJoin: urlJoin,
      config: config,
      urlFor: function (page) {
        var query = _.assign({}, self.opts.ctx.query);
        query.page = page;
        return '/spu-list?' + buildQS(_.assign(query));
      },
      processOpts: function () {
        self.currentPage = self.opts.ctx.query.page || 1;
        self.perPage = self.opts.ctx.query.perPage || 12;
        var sortBy = self.opts.ctx.query.sortBy;
        if (sortBy) {
          sortBy = sortBy.toLowerCase().split('.');
          self.sortBy = {
            name: sortBy[0] || 'id',
            order: sortBy[1] || 'asc',
          }
        }
      },
      sortBy: {},
      moment: moment,
      sortHandlers: {},
      filterHandlers: {},
      selected: new Set(),
      onSearchSubmit: function (kw) {
          var query = self.opts.ctx.query;
          query.kw = kw;
          bus.trigger('go', '/spu-list?' + buildQS(query));
      },
      onSearchSelect: function (result) {
          var query = self.opts.ctx.query;
          query.kw = result.title;
          bus.trigger('go', '/spu-list?' + buildQS(query));
      },
      deleteHandlers: function () {
        var selected = Array.from(self.selected);
        if (!selected.length) {
          swal({
            type: 'info',
            title: '',
            text: '请至少选择一个对象',
          });
        } else {
          swal({
            type: 'warning',
            title: '',
            text: '您确认要删除选中的对象?',
            showCancelButton: true,
            closeOnConfirm: false,
          }, function (confirmed) {
            if (confirmed) {
              bus.trigger('spu.delete', selected);
            }
          });
        }
      }
    });

    ['id', 'msrp', 'rating', 'createTime'].forEach(function (col) {
      col = decamelize(col);
      self.sortHandlers[col] = function () {
        var query = self.opts.ctx.query;
        if (self.sortBy.name === col) {
          query.sortBy = col + '.' + {
            desc: 'asc',
            asc: 'desc'
          }[self.sortBy.order];
        } else {
          query.sortBy = col + '.asc';
        }
        bus.trigger('go', '/spu-list?' + buildQS(query));
      };
    });
    ['rating', 'spuType', 'vendor'].forEach(function (col) {
      self.filterHandlers[col] = function (value, text, $choice) {
        var query = self.opts.ctx.query;
        if (value) {
          query[col] = value;
        } else {
          delete query[col];
        }
        bus.trigger('go', '/spu-list?' + buildQS(query));
      };
    });

    self.filterHandlers.onlyEnabled = function () {
      var checked = $(this).is(':checked');
      var query = self.opts.ctx.query;
      if (checked) {
        query.onlyEnabled = 1;
      } else {
        delete query.onlyEnabled;
      }
      bus.trigger('go', '/spu-list?' + buildQS(query));
    };

    self.on('mount', function () {
      self.processOpts();
      $(self.root).find('[data-content]').popup();
    }).on('spu.list.fetchding', function () {
      self.loading = true;
      self.update();
    }).on('spu.list.fetched', function (data) {
      self.items = data.data;
      self.totalCnt = data.totalCnt;
      self.loading = false;
      self.pagination = new Pagination({
        currentPage: self.currentPage,
        perPage: self.perPage,
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
