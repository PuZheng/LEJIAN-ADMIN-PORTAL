var riot = require('riot');
var bus = require('riot-bus');
require('tags/sortable-th.tag');
var moment = require('moment');
require('magnific-popup/magnific-popup.css');
require('magnific-popup/jquery.magnific-popup.js');

<retailer-table>
  <table class="ui sortable compact striped table">
    <thead class="full-width">
      <th riot-tag="sortable-th" label="编号" name="id" ctx={ opts.ctx }></th>
      <th>名称</th>
      <th>外景</th>
      <th>激活</th>
      <th>电话</th>
      <th>地址</th>
      <th riot-tag="sortable-th" label="评分" name="rating" ctx={ opts.ctx }></th>
      <th riot-tag="sortable-th" label="创建时间" name="create_time" ctx={ opts.ctx }></th>
      <th>SPU数量</th>
    </thead>

    <tbody class="full-width">
      <tr each={ item in items } data-item-id={ item.id }>
        <td>
          <a href="/retailer/{item.id}">{ item.id }</a>
        </td>
        <td>{ item.name }</td>
        <td>
          <a class="ui tiny image" href="{ item.pic && item.pic.url }">
            <img src="{ item.pic && item.pic.url }" alt="">
          </a>
        </td>
        <td>
          <i class="ui icon { item.enabled? 'green checkmark': 'red remove' }"></i>
        </td>
        <td>{ item.tel }</td>
        <td>{ item.addr }</td>
        <td>{ item.rating }</td>
        <td>{ moment(item.createTime).format('YY-MM-DD HH时') }</td>
        <td>{ item.spuCnt }</td>
      </tr>
    </tbody>
  </table>
  <style scoped>
    .tiny.image img {
      max-width: 100% !important;
    }
  </style>

  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.moment = moment;

    self.on('retailer.list.fetched', function (data) {
      self.items = data.data;
      self.update();
    }).on('updated', function () {
      $(self.root).find('tbody a.image').magnificPopup({type:'image'});
    });
  </script>
</retailer-table>
