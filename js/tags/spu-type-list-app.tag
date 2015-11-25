var riot = require('riot');
require('semantic-ui/semantic.css');
require('semantic-ui/semantic.min.js');
var bus = require('riot-bus');
var config = require('config');
var urljoin = require('url-join');
require('./centered-image.tag');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');
require('magnific-popup/magnific-popup.css');
require('magnific-popup/jquery.magnific-popup.js');
var buildQS = require('build-qs');

<spu-type-list-app>
  <div class="ui page grid">
    <div class="ui top attached info segment">
      <div class="ui header">
        SPU类型列表
      </div>
      <a class="ui icon green circular button" href="/spu/spu-type" data-content="创建SPU分类">
        <i class="icon plus"></i>
      </a>
      <a class="ui icon red circular button" href="#" data-content="删除SPU分类" onclick={ delete }>
        <i class="icon trash"></i>
      </a>
    </div>
    <div class="ui attached segment ops">
      <div class="ui search">
        <div class="ui icon input">
          <input class="prompt" type="text" placeholder="输入名称" name="search" onkeyup={ doSearch } value={ opts.ctx.query.kw }>
          <i class="search icon"></i>
        </div>
        <div class="results"></div>
      </div>
      <div class="only enabled ui checkbox">
        <input type="checkbox" name="" checked={ opts.ctx.query.onlyEnabled === '1' }>
        <label for="">仅展示激活类型</label>
      </div>
    </div>
    <div class="ui bottom attached segment" if={ items }>
      <table class="ui sortable compact striped table">
        <thead class="full-width">
          <th>
            <div class="select-all ui checkbox">
              <input type="checkbox">
              <label for=""></label>
            </div>
          </th>
          <th>名称</th>
          <th>图片</th>
          <th class="{ sortBy.name === 'spu_cnt' && 'sorted ' + \{'asc': 'ascending', 'desc': 'descending'\}[sortBy.order]  }" onclick={ sortHandlers['spu_cnt'] }>
            <a href="#">
              产品数量
            </a>
          </th>
          <th class="{ sortBy.name === 'weight' && 'sorted ' + \{'asc': 'ascending', 'desc': 'descending'\}[sortBy.order]  }" onclick={ sortHandlers.weight }>
            <a href="#">
              权重
            </a>
          </th>
          <th>是否激活</th>
        </thead>
        <tbody class="full-width">
          <tr each={ item in items } data-item-id={ item.id }>
            <td>
              <div class="select ui checkbox">
                <input type="checkbox" data-id={ item.id }>
                <label for=""></label>
              </div>
            </td>
            <td>
              <a href="/spu/spu-type/{ item.id }">
                { item.name }
              </a>
            </td>
            <td>
              <a href={ urljoin(config.backend, item.picPath) } class="image-link">
                <centered-image img={ urljoin(config.backend, item.picPath) } class="ui tiny image"></centered-image>
              </a>
            </td>
            <td>{ item.spuCnt }</td>
            <td>{ item.weight }</td>
            <td>
              <i class="ui icon { item.enabled? 'green checkmark': 'red remove' }"></i>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
  <style scoped>
    .image {
      width: 96px !important;
      height: 96px !important;
    }

    .top.segment > div {
      display: inline-block !important;
    }

    .top.segment > .button {
      margin-left: 1rem;
    }

    .item .description > div {
      margin-left: 2rem;
      display: inline-block;
    }

    .ops.attached.segment > div {
      margin-left: 1rem;
      display: inline-block;
    }
    table thead th:first-child, table tbody td:first-child {
      text-align: center;
    }
  </style>
  <script>
    var self = this;
    this.mixin(bus.Mixin);

    _.extend(self, {
      config: config,
      urljoin: urljoin,
      updating: [],
      updateHandlers: {
        weight: function (item) {
          return function (e) {
            if (self.updating.indexOf('weight') === -1) {
              self.updating.push('weight');
              setTimeout(function () {
                var patch = {
                  weight: $(e.target).val(),
                };
                bus.trigger('spuType.update', _.extend({}, item), patch);
                _.assign(item, patch);
                self.updating = self.updating.filter(function (i) {
                  return i != 'weight';
                });
              }, 500);
            }
          };
        }
      },
      sortHandlers: {},
      delete: function () {
        var selected = Array.from(self.selected);
        if (!selected.length) {
          swal({
            type: 'info',
            title: '',
            text: '请至少选择一个SPU类型',
          });
        } else {
          if (selected.some(function (id) {
            var item = self.items.filter(function (item) {
              return item.id === parseInt(id);
            })[0];
            return item.spuCnt > 0;
          })) {
            swal({
              type: 'error',
              title: '',
              text: '只能删除不包含SPU的SPU分类!'
            });
            return;
          }
          swal({
            type: 'warning',
            title: '',
            text: '您确认要删除选中的SPU类型?',
            showCancelButton: true,
            closeOnConfirm: false,
          }, function (confirmed) {
            if (confirmed) {
              bus.trigger('spuType.delete', selected);
            }
          });
        }

      },
      selected: new Set(),
    });

    ['weight', 'spu_cnt'].forEach(function (field) {
      self.sortHandlers[field] = function () {
        var query = opts.ctx.query;
        query.sortBy = field;
        if (self.sortBy.name === field) {
          query.sortBy += '.' + {
            'asc': 'desc',
            'desc': 'asc'
          }[self.sortBy.order];
        } else {
          query.sortBy += '.asc';
        }
        bus.trigger('go', '/spu/spu-type-list?' + buildQS(query));
      };
    });

    self.on('mount', function () {
      self.sortBy = function (sortBy) {
        if (!sortBy) {
          return {};
        }
        sortBy = sortBy.split('.');
        return {
          name: sortBy[0],
          order: sortBy[1] || 'asc',
        }
      }(opts.ctx.query.sortBy);
      $(self.root).find('[data-content]').popup();
      $(self.root).find('.only.enabled.checkbox').checkbox({
        onChange: function () {
          var query = opts.ctx.query;
          query.onlyEnabled = $(this).is(':checked')? 1: 0;
          bus.trigger('go', '/spu/spu-type-list?' + buildQS(query), opts.ctx.state);
        },
      });
    }).on('updated', function () {
      $(self.root).find('a.image-link').magnificPopup({type:'image'});
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
    }).on('spuType.list.fetching spuType.updating', function () {
      self.update();
    }).on('spuType.list.fetched', function (data) {
      self.items = data.data;
      self.update();
      $(self.root).find('.item .ui.checkbox').checkbox({
        onChange: function () {
          var id = $(this).data('item-id');
          var patch = {
            enabled: $(this).is(':checked')
          };
          var item = self.items.filter(function (item) {
            return item.id === id;
          })[0];
          bus.trigger('spuType.update', _.extend({}, item), patch);
          _.assign(item, patch);
          self.update();
        }
      });
    }).on('spuType.deleted', function () {
      swal({
        type: 'success',
        title: '',
        text: '删除成功!'
      }, function () {
        bus.trigger('go', opts.ctx.path);
      });
    });
    self.doSearch = function () {
      var allItems;
      return function (e) {
        !allItems && (allItems = self.items);
        var needle = $(e.target).val().toLowerCase();
        self.items = allItems.filter(function (item) {
          return ~item.name.toLowerCase().indexOf(needle);
        });
        self.update();
      };
    }();
  </script>
</spu-type-list-app>
