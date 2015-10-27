var riot = require('riot');
require('semantic-ui/semantic.css');
require('semantic-ui/semantic.min.js');
var bus = require('riot-bus');
var config = require('config');
var urljoin = require('url-join');
require('./centered-image.tag');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');

<spu-type-list-app>
  <div class="ui page grid">
    <div class="ui top attached info segment">
      <div class="ui header">
        SPU类型列表
      </div>
      <a class="ui icon green circular button" href="/spu/spu-type" data-content="创建SPU分类">
        <i class="icon plus"></i>
      </a>
    </div>
    <div class="ui attached segment ops">
      <div class="ui checkbox">
        <input type="checkbox" name="">
        <label for="">仅展示激活类型</label>
      </div>
      <button class="ui icon button { sorter === 'weight' && 'green' }" onclick={ sortHandlers.weight }>
        <i class="icon sort { sorter === 'weight' && order }"></i>
        按权重
      </button>
      <button class="ui icon button { sorter === 'spuCnt' && 'green' }" onclick={ sortHandlers.spuCnt }>
        <i class="icon sort { sorter === 'spuCnt' && order }"></i>
        按SPU数量
      </button>
    </div>
    <div class="ui bottom attached segment" if={ visibleItems }>
      <div class="ui items">
        <div class="item" each={ item in items } show={ ~visibleItems.indexOf(item) } data-item-id={ item.id }>
          <div class="image">
            <a href="/spu/spu-type/{ item.id }">
              <centered-image img={ urljoin(config.backend, item.picPath) }>
            </a>
          </div>
          <div class="content">
            <a class="header" href="/spu/spu-type/{ item.id }">{ item.name } </a>
            <div class="description">
              <div>
                产品数量 - { item.spuCnt }
              </div>
              <div class="ui checkbox slider" data-enabled={ item.enabled || '' }>
                <input type="checkbox" name="enabled" data-item-id={ item.id }>
                <label for="enabled">{ item.enabled? '激活': '未激活' }</label>
              </div>
              <div>
                <label for="">权重</label>
                <input class="ui input" type="number" name="" value={ item.weight } step="1.0" min="1" data-item-id={ item.id } onChange={ updateHandlers['weight'](item) } onkeypress={ onInputWeightKeyPress }>
              </div>
            </div>
          </div>
        </div>
      </div>
      </div>
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
      margin-left: 3rem;
    }

    .item .description > div {
      margin-left: 2rem;
      display: inline-block;
    }

    .ops.attached.segment > div {
      margin-left: 1rem;
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
    });

    ['weight', 'spuCnt'].forEach(function (sorter) {
      self.sortHandlers[sorter] = function (sorterCopy) {
        return function () {
          if (self.sorter === sorterCopy) {
            self.order = {
              descending: 'ascending',
              ascending: 'descending'
            }[self.order];
          } else {
            self.order = 'descending';
          }
          self.sorter = sorterCopy;
          self.items = _(self.items).sortBy(function (item) {
            return item[self.sorter];
          });
          if (self.order === 'descending') {
            self.items = self.items.reverse();
          }
          self.items = self.items.value();
          self.update();
        };
      }(sorter);
    });

    self.on('mount', function () {
      $(self.root).find('.ops .ui.checkbox').checkbox({
        onChecked: function () {
          self.visibleItems = self.items.filter(function (item) {
            return item.enabled;
          });
          self.update();
        },
        onUnchecked: function () {
          self.visibleItems = self.items;
          self.update();
        }
      });
      self.sorter = 'weight';
      self.order = 'descending';
      $(self.root).find('[data-content]').popup();
    }).on('update', function () {
      setTimeout(function () {
        $(self.root).find('.item .ui.checkbox').each(function (idx) {
          if ($(this).attr('data-enabled')) {
            $(this).checkbox('set checked');
          } else {
            $(this).checkbox('set unchecked');
          }
        });
      }, 0);
    }).on('spuType.list.fetching spuType.updating', function () {
      self.update();
    }).on('spuType.list.fetched', function (data) {
      self.items = data.data;
      self.visibleItems = self.items;
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
    }).on('spuType.updated', function () {
      toastr.success('更新成功！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
    }).on('spuType.update.failed', function (oldItem, patch) {
      toastr.error('更新失败！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
      // restore the old value
      for (var item_ of self.items) {
        if (item_.id === oldItem.id) {
          _.assign(item_, oldItem);
          break;
        }
      }
      self.update();
    });

  </script>
</spu-type-list-app>
