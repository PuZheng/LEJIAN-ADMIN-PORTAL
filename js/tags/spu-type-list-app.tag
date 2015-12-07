var riot = require('riot');
var bus = require('riot-bus');
require('./centered-image.tag');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');
var buildQS = require('build-qs');
require('tags/sortable-th.tag');
require('tags/checkbox-filter.tag');
require('tags/spu-type-table.tag');
require('tags/loader.tag');

<spu-type-list-app>
  <div class="ui grid list">
    <loader if={ loading }></loader>
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
          <input class="prompt" type="text" placeholder="按名称过滤" name="search" onkeyup={ doSearch } value={ opts.ctx.query.kw }>
          <i class="search icon"></i>
        </div>
        <div class="results"></div>
      </div>

      <div riot-tag="checkbox-filter" checked_={ opts.ctx.query.onlyEnabled === '1' } label="仅展示激活" name="only_enabled" ctx={ opts.ctx }></div>
    </div>
    <div class="ui bottom attached segment">
      <spu-type-table ctx={ opts.ctx }></spu-type-table>
    </div>
  </div>
  <script>
    var self = this;
    this.mixin(bus.Mixin);

    _.extend(self, {
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
        var selected = Array.from(self.tags['spu-type-table'].selected);
        if (!selected.length) {
          swal({
            type: 'info',
            title: '',
            text: '请至少选择一个SPU类型',
          });
        } else {
          if (selected.some(function (id) {
            var item = self.tags['spu-type-table'].items.filter(function (item) {
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
    });

    self.on('mount', function () {
      $(self.root).find('[data-content]').popup();
    }).on('spuType.list.fetching  spuType.deleting', function () {
      self.loading = true;
      self.update();
    }).on('spuType.list.fetched', function () {
      self.loading = false;
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
