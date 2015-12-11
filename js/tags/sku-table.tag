var riot = require('riot');
var bus = require('riot-bus');
var moment = require('moment');
require('tags/sortable-th.tag');
require('perfect-scrollbar/dist/css/perfect-scrollbar.min.css');
require('perfect-scrollbar/dist/js/min/perfect-scrollbar.jquery.min.js');

<sku-table>
  <table class="ui sortable compact striped table">
    <thead class="full-width">

      <th riot-tag="sortable-th" label="编号" name="id" ctx={ opts.ctx }></th>
      <th>SPU</th>
      <th>token</th>
      <th riot-tag="sortable-th" label="验证次数" name="verity_count" ctx={ opts.ctx }></th>
      <th riot-tag="sortable-th" label="生产日期" name="manufacture_date" ctx={ opts.ctx }></th>
      <th riot-tag="sortable-th" label="质保期" name="expire_date" ctx={ opts.ctx }></th>

    </thead>
    <tbody>
      <tr each={ items }>
        <td>{ id }</td>
        <td>{ spu.name }</td>
        <td>{ token }</td>
        <td>{ verifyCount }</td>
        <td>{ moment(manufactureDate).format('YY-MM-DD') }</td>
        <td>{ moment(expireDate).format('YY-MM-DD') }</td>
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

    self.on('sku.list.fetched', function (data) {
      self.items = data.data;
      self.update();
      $(self.root).find('tbody').outerHeight(100);
    });
  </script>
</sku-table>
