var riot = require('riot');
var bus = require('riot-bus');
var config = require('config');
var urljoin = require('url-join');
require('./centered-image.tag');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');
require('magnific-popup/magnific-popup.css');
require('magnific-popup/jquery.magnific-popup.js');
var buildQS = require('build-qs');
require('tags/sortable-th.tag');
require('tags/checkbox-filter.tag');

<spu-type-list-app>
  <div class="ui grid list">
    <div class="ui top attached info message segment">
      <div class="ui header">
        SPU类型列表
      </div>
      <a class="ui tiny icon green circular button" href="/spu/spu-type" data-content="创建SPU分类">
        <i class="icon plus"></i>
      </a>
      <a riot-tag="batch-delete-btn" data-content="删除SPU分类" handler={ delete }></a>
    </div>
    <div class="ui attached segment filters">
      <div class="ui search">
        <div class="ui icon input">
          <input class="prompt" type="text" placeholder="输入名称" name="search" onkeyup={ doSearch } value={ opts.ctx.query.kw }>
          <i class="search icon"></i>
        </div>
        <div class="results"></div>
      </div>

      <div riot-tag="checkbox-filter" checked={ opts.ctx.onlyEnabled === '1' } label="仅展示激活" name="only_enabled" ctx={ opts.ctx }></div>
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
          <th riot-tag="sortable-th" label="编号" name="id" ctx={ opts.ctx }></th>
          <th>名称</th>
          <th>图片</th>
          <th riot-tag="sortable-th" label="产品数量" name="spu_cnt" ctx={ opts.ctx }></th>
          <th riot-tag="sortable-th" label="权重" name="weight" ctx={ opts.ctx }></th>
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
              <a href="/spu-type/{ item.id }">
                { item.id }
              </a>
            </td>
            <td>
              { item.name }
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
      delete: function () {
        var selected = Array.from(self.selected);
        if (!selected.length) {
          swal({
            type: 'info',
            title: '',
            text: '请至少选择一个SPU类型',
          });
        } else {
          debugger;
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

    self.on('mount', function () {
      self.processOpts();
      $(self.root).find('[data-content]').popup();
    }).on('updated', function () {
      $(self.root).find('a.image-link').magnificPopup({type:'image'});
      $(self.root).find('.ui.select-all').checkbox({
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
    }).on('spuType.list.fetching spuType.updating', function () {
      self.update();
    }).on('spuType.list.fetched', function (data) {
      self.items = data.data;
      self.update();
    }).on('spuType.deleted', function () {
      swal({
        type: 'success',
        title: '',
        text: '删除成功!'
      }, function () {
        bus.trigger('go', opts.ctx.path);
      });
    });
    self.doSearch = function (e) {
      var kw = $(e.target).val();
      if (kw) {
        opts.ctx.query.kw = encodeURIComponent(kw);
      } else {
        delete opts.ctx.query.kw;
      }
      bus.trigger('go', '/spu-type-list?' + buildQS(opts.ctx.query));
    };
  </script>
</spu-type-list-app>
