var riot = require('riot');
var bus = require('riot-bus');
var moment = require('moment');
require('tags/loader.tag');

<spu-table>
  <table class="ui sortable compact striped table">
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
        <th riot-tag="sortable-th" label="创建时间" name="created_at" ctx={ opts.ctx }></th>
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
            <img src="{ icon.url }" alt="">
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
          { moment(createdAt).format('YY-MM-DD HH时') }
        </td>
      </tr>
    </tbody>
  </table>
  <div class="ui teal message" if={ !loading && _.isEmpty(items) }>
    -- 没有数据 --
  </div>
  <style scoped>
    .tiny.image img {
      max-width: 100% !important;
    }
  </style>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.selected = new Set();
    self.moment = moment;

    self.on('mount', function () {
      $(self.root).find('.select-all.checkbox').checkbox({
        onChecked: function () {
          $(self.root).find('.ui.select.checkbox').checkbox('check');
        },
        onUnchecked: function () {
          $(self.root).find('.ui.select.checkbox').checkbox('uncheck');
        }
      });
    }).on('updated', function () {
      $(self.root).find('.select-all.checkbox').checkbox('set unchecked');
    }).on('spu.list.fetched', function (data) {
      self.items = data.data;
      self.update();
      $(self.root).find('.ui.select.checkbox').checkbox({
        onChecked: function () {
          self.selected.add($(this).data('id'));
        },
        onUnchecked: function () {
          self.selected.delete($(this).data('id'));
        }
      });
    });
  </script>
</spu-table>
