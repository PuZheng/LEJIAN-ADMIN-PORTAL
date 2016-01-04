var riot = require('riot');
var bus = require('riot-bus');
var moment = require('moment');
require('tags/sortable-th.tag');
require('tags/loader.tag');
require('perfect-scrollbar/dist/css/perfect-scrollbar.min.css');
require('perfect-scrollbar/dist/js/min/perfect-scrollbar.jquery.min.js');

<sku-table>
  <loader if={ loading }></loader>
  <table class="ui sortable compact striped table">
    <thead class="full-width">
      <th>
        <div class="select-all ui checkbox">
          <input type="checkbox">
          <label for=""></label>
        </div>
      </th>
      <th riot-tag="sortable-th" label="编号" name="id" ctx={ opts.ctx }></th>
      <th>SPU</th>
      <th>token</th>
      <th riot-tag="sortable-th" label="验证次数" name="verity_count" ctx={ opts.ctx }></th>
      <th riot-tag="sortable-th" label="最后验证时间" name="last_verify_time" ctx={ opts.ctx }></th>
      <th riot-tag="sortable-th" label="生产日期" name="manufacture_date" ctx={ opts.ctx }></th>
      <th riot-tag="sortable-th" label="质保期" name="expire_date" ctx={ opts.ctx }></th>
    </thead>
    <tbody>
      <tr each={ items }>
        <td>
          <div class="select ui checkbox">
            <input type="checkbox" data-id={ id }>
            <label for=""></label>
          </div>
        </td>
        <td>
          <a href="/sku/{ id }">{ id }</a>
        </td>
        <td>{ spu.name }</td>
        <td>{ token }</td>
        <td>{ verifyCount }</td>
        <td>{ moment(lastVerifiedAt).format('YY-MM-DD HH:MM') }</td>
        <td>{ moment(productionDate).format('YYYY-MM-DD') }</td>
        <td class={ (moment(expireDate) < new Date()) && 'ui tiny header red' }>{ moment(expireDate).format('YY-MM-DD') }</td>
      </tr>
    </tbody>
  </table>
  <style scoped>
    tbody {
      overflow-y: auto;
    }
  </style>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.moment = moment;
    self.selected = new Set();

    self.on('mount', function () {
      $(self.root).find('.select-all.checkbox').checkbox({
        onChecked: function () {
          $(self.root).find('.ui.select.checkbox').checkbox('check');
        },
        onUnchecked: function () {
          $(self.root).find('.ui.select.checkbox').checkbox('uncheck');
        }
      });
    }).on('sku.list.fetching', function () {
      self.loading = true;
      self.update();
    }).on('sku.list.fetched', function (data) {
      self.items = data.data;
      self.update();
      $(self.root).find('.select-all.checkbox').checkbox('set unchecked');
      $(self.root).find('tbody').outerHeight(100);
    }).on('sku.list.fetch.done', function () {
      self.loading = false;
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
</sku-table>
