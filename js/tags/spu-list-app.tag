var riot = require('riot');
var bus = require('riot-bus');
var urlJoin = require('url-join');
require('tags/loader.tag');
var config = require('config');
var buildQS = require('build-qs');
var Pagination = require('pagination');
var moment = require('moment');
var decamelize = require('decamelize');
require('tags/sortable-th.tag');
require('tags/paginator.tag');

<spu-list-app>
  <div class="ui grid">
    <div class="ui top attached blue message segment">
      <div class="ui header">
        SPU列表
      </div>
      <a class="ui tiny icon circular green button" href="/spu/spu-type" data-content="创建SPU">
        <i class="icon plus"></i>
      </a>
      <a class="ui tiny icon circular red button" href="#" data-content="删除SPU" onclick={ delete }>
        <i class="icon trash"></i>
      </a>
    </div>
    <div class="ui attached segment">
      <loader if={ loading }></loader>
      <table class="ui sortable compact striped table" if={ !loading && items }>
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
                <input type="checkbox" data-id={ item.id }>
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
      <div class="ui teal message" if={ !loading && !items }>
        -- 没有数据 --
      </div>
    </div>
    <div class="ui bottom fixed menu">
      <paginator pagination={ pagination } url-for={ urlFor } if={ pagination }></paginator>
    </div>
  </div>
  <style scoped>
    .bottom.fixed.menu {
      justify-content: center;
    }
    .top.attached.segment > * {
      display: inline-block;
    }
    table thead th:first-child, table tbody td:first-child {
      text-align: center;
    }
  </style>
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
      selected: new Set(),
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
      }
    });

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
      $(self.root).find('.ui.select-all').checkbox({
        onChecked: function () {
          $(self.root).find('.ui.select.checkbox').checkbox('check');
        },
        onUnchecked: function () {
          $(self.root).find('.ui.select.checkbox').checkbox('uncheck');
        }
      });
      $(self.root).find('.ui.select.checkbox').checkbox({
        onChecked: function () {
          self.selected.add($(this).data('id'));
        },
        onUnchecked: function () {
          self.selected.delete($(this).data('id'));
        }
      });

    }).on('error', function (err) {
      console.error(err);
    });
  </script>
</spu-list-app>
