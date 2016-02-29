var riot = require('riot');
var bus = require('riot-bus');
require('tags/sortable-th.tag');
var moment = require('moment');
require('magnific-popup/magnific-popup.css');
require('magnific-popup/jquery.magnific-popup.js');
var config = require('config');

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
      <th>经纬度</th>
    </thead>

    <tbody class="full-width">
      <tr each={ items } data-item-id={ id }>
        <td>
          <a href="/retailer/{id}">{ id }</a>
        </td>
        <td>{ name }</td>
        <td>
          <a class="ui tiny image" href="{ pic && pic.url }">
            <img src="{ pic && pic.url }" alt="">
          </a>
        </td>
        <td>
          <i class="ui icon { enabled? 'green checkmark': 'red remove' }"></i>
        </td>
        <td>{ tel }</td>
        <td>{ poi.addr }</td>
        <td>{ rating }</td>
        <td>{ moment(createTime).format('YY-MM-DD HH时') }</td>
        <td>{ spuCnt }</td>
        <td>
          <a class="ui lnglat image" href={ staticMapURL }>
            <img src={ staticMapURL } alt="">
          </a>
        </td>
      </tr>
    </tbody>
  </table>
  <style scoped>
    tbody .image img {
      max-width: 100% !important;
    }
    tbody a.lnglat {
      width: 128px !important;
      height: 128px !important;
    }
  </style>

  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.moment = moment;

    self.on('retailer.list.fetched', function (data) {
      self.items = data.data.map(function (item) {
        return _.assign(item, {
          staticMapURL: `http://restapi.amap.com/v3/staticmap?location=${ item.poi.lng },${ item.poi.lat }&zoom=10&size=640*640&markers=small,,A:${ item.poi.lng },${ item.poi.lat }&key=${ config.mapKey.web }`
        });
      });
      console.log(self.items);
      self.update();
    }).on('updated', function () {
      $(self.root).find('tbody a.image').magnificPopup({type:'image'});
    });
  </script>
</retailer-table>
