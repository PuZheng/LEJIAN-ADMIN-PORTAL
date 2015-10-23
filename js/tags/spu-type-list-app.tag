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
    </div>
    <div class="ui bottom attached segment" if={ items }>
      <div class="ui items">
        <div class="item" each={ item in items }>
          <div class="image">
            <a href="/spu-type/{ item.id }">
              <centered-image src={ urljoin(config.backend, item.picPath) }>
            </a>
          </div>
          <div class="content">
            <a class="header" href="/spu-type/{id}">{ item.name }</a>
            <div class="description">
              <div class="ui checkbox slider" data-enabled={ item.enabled || '' }>
                <input type="checkbox" name="enabled" data-item-id={ item.id }>
                <label for="enabled">{ item.enabled? '激活': '未激活' }</label>
              </div>
              <div>
                <label for="">权重</label>
                <input class="ui input" type="number" name="" value={ item.weight } step="1.0" min="1" data-item-id={ item.id } onChange={ updateHandlers['weight'](item.id) } onkeypress={ onInputWeightKeyPress }>
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
    .item .description > div {
      margin-top: 0.5rem;
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
        weight: function (id) {
          return function (e) {
            if (self.updating.indexOf('weight') === -1) {
              self.updating.push('weight');
              setTimeout(function () {
                bus.trigger('spuType.update', id, {
                  weight: $(e.target).val(),
                });
                self.updating = self.updating.filter(function (i) {
                  return i != 'weight';
                });
              }, 500);
            }
          };
        }
      }
    });

    self.on('update', function () {
      setTimeout(function () {
        $(self.root).find('.ui.checkbox').each(function (idx) {
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
      self.update();
      $(self.root).find('.ui.checkbox').checkbox({
        onChange: function () {
          var id = $(this).data('item-id');
          var patch = {
            enabled: $(this).is(':checked')
          };
          bus.trigger('spuType.update', id, patch);
          for (var item_ of self.items) {
            if (item_.id === id) {
              _.assign(item_, patch);
              break;
            }
          }
          self.update();
        }
      });
    }).on('spuType.updated spuType.update.failed', function (which, item, patch) {
      if (which === 'spuType.update.failed' && item) {
      }
      if (which === 'spuType.updated') {
        toastr.success('更新成功！', '', {
          positionClass: 'toast-bottom-center',
          timeOut: 1000,
        });
        self.update();
      } else {
        toastr.error('更新失败！', '', {
          positionClass: 'toast-bottom-center',
          timeOut: 1000,
        });
        for (var item_ of self.items) {
          if (item_.id === item.id) {
            _.assign(item_, item);
            break;
          }
        }
        self.update();
      }
    });

  </script>
</spu-type-list-app>
