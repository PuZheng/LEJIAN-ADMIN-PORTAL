var riot = require('riot');
var bus = require('riot-bus');
var urljoin = require('url-join');
var config = require('config');
require('magnific-popup/magnific-popup.css');
require('magnific-popup/jquery.magnific-popup.js');

<spu-type-table>
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
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.urljoin = urljoin;
    self.config = config;
    self.selected = new Set();

    self.on('mount', function () {
      $(self.root).find('.ui.select-all').checkbox({
        onChecked: function () {
          $(self.root).find('.ui.select.checkbox').checkbox('check');
        },
        onUnchecked: function () {
          $(self.root).find('.ui.select.checkbox').checkbox('uncheck');
        }
      });
    }).on('updated', function () {
      $(self.root).find('a.image-link').magnificPopup({type:'image'});
      $(self.root).find('.ui.select-all').checkbox('set unchecked');
      $(self.root).find('.ui.select.checkbox').checkbox({
        onChecked: function () {
          self.selected.add($(this).data('id'));
        },
        onUnchecked: function () {
          self.selected.delete($(this).data('id'));
        }
      });
    }).on('spuType.list.fetched', function (data) {
      self.items = data.data;
      self.update();
    });

  </script>
</spu-type-table>

