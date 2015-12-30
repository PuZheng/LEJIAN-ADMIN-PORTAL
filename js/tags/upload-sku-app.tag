var riot = require('riot');
var bus = require('riot-bus');
require('tags/loader.tag');

<upload-sku-app>
  <div class="ui page grid">
    <div class="column">
      <div class="row">
        <loader if={ loading }></loader>
        <div class="ui top attached segment">
          <div class="vendor ui search selection dropdown">
            <input type="hidden" name="vendorId">
            <i class="dropdown icon"></i>
            <div class="default text">请选择厂商</div>
            <div class="menu">
              <div class="item" data-value={ id } each={ vendors }>{ name }</div>
            </div>
          </div>
          <div class="spu ui search selection dropdown">
            <input type="hidden" name="vendorId">
            <i class="dropdown icon"></i>
            <div class="default text">请选择SPU</div>
            <div class="menu">
              <div class="item" data-value={ id } each={ spus }>{ name }</div>
            </div>
          </div>
          <button class="ui green file button" disabled>
            选择文件
            <input type="file">
          </button>
          <button class="ui primary button" disabled>确认导入</button>
        </div>
        <div class="ui bottom attached segment">
        </div>
      </div>
    </div>
  </div>
  <div class="ui modal">
    <i class="close icon"></i>
    <div class="header">
      上传SKU注意事项
    </div>
    <div class="image content">
      <div class="ui large image">
        <img src="/img/upload-sku-csv.jpg">
      </div>
      <div class="description">
        <div class="ui header">如左图:</div>
        <ul class="ul list">
          <li class="item">token和校验码中，不能包含中文</li>
          <li class="item">文件格式为CSV</li>
          <li class="item">包含如下四个字段: token; 校验码; 生产日期(YYYY-MM-DD); 质保截止日期(YYYY-MM-DD)</li>
          <li class="item">不要包含字段头，即第一行不应是"token|校验码|生产日期|质保日期"， 直接是数据</li>
        </ul>
      </div>
    </div>
    <div class="actions">
      <div class="ui positive button">
        知道了
      </div>
    </div>
  </div>
  <style scoped>
    .file.button {
      position: relative;
    }
    .file.button input[type=file] {
      position: absolute;
      top: 0;
      right: 0;
      width: 100%;
      height: 100%;
      opacity: 0 !important;
      display: block;
    }
  </style>

  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.loading = 0;
    self.on('vendor.list.fetching spu.list.fetching', function () {
      ++self.loading;
      self.update();
    }).on('vendor.list.fetch.done spu.list.fetch.done', function () {
      --self.loading;
      self.update();
    });

    self.on('mount', function () {
      self.$modal = self.$modal || $(self.root).find('.ui.modal');
      self.$modal.modal('show');
      $(self.root).find('[type=file]').change(function (e) {

      });
    }).on('vendor.list.fetched', function (data) {
      self.vendors = data.data;
      self.update();
      $(self.root).find('.ui.dropdown.vendor').dropdown({
        onChange: function (value) {
          bus.trigger('spu.list.fetch', {
            vendorId: value,
          });
        }
      });
    }).on('spu.list.fetched', function (data) {
      self.spus = data.data;
      self.update();
      $(self.root).find('.ui.dropdown.spu').dropdown({
        onChange: function () {
            var $button = $(self.root).find('.file.button');
            return function (value) {
              value? $button.removeAttr('disabled'): $button.attr('disabled', 'disabled');
            }
        }()
      }).dropdown('clear');
    });
  </script>
</upload-sku-app>
