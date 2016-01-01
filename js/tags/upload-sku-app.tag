var riot = require('riot');
var bus = require('riot-bus');
require('tags/loader.tag');
var Papa = require('papaparse');
var swal = require('sweetalert/sweetalert.min.js');


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
          <button class="ui import primary button" disabled onclick={ importHandler }>确认导入</button>
        </div>
        <div class="ui bottom attached segment">
          <table class="ui striped compact table">
            <thead>
              <tr>
                <th>行号</th>
                <th>token</th>
                <th>校验码</th>
                <th>生产日期</th>
                <th>有效截止日期</th>
              </tr>
            </thead>
            <tbody>
              <tr each={ row, i in records }>
                <td>{ i + 1 }</td>
                <td>{ row.token }</td>
                <td>{ row.checksum }</td>
                <td>{ row.productionDate }</td>
                <td>{ row.expireDate }</td>
              </tr>
            </tbody>
          </table>
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
    self.importHandler = function (e) {
      swal({
        type: 'warning',
        title: '',
        text: '您确认要导入SPU <' + $(self.root).find('.spu.dropdown').dropdown('get text') + '> 的SKU数据?',
        showCancelButton: true,
        closeOnConfirm: false,
      }, function (confirmed) {
        if (confirmed) {
          bus.trigger('sku.create', self.records.map(function (row) {
            return _.assign({
              spuId: self.$spuDropdown.dropdown('get value'),
            }, row);
          }));
        }
      });
    };

    self.on('vendor.list.fetching spu.list.fetching sku.creating', function () {
      ++self.loading;
      self.update();
    }).on('vendor.list.fetch.done spu.list.fetch.done sku.create.done', function () {
      --self.loading;
      self.update();
    });

    self.on('mount', function () {
      self.$modal = self.$modal || $(self.root).find('.ui.modal');
      self.$modal.modal('show');
      self.$fileInput = $(self.root).find('[type=file]').change(function (e) {
        var fr = new FileReader();
        fr.onload = function (e) {
          self.$fileInput.val('');
          var result = Papa.parse(e.target.result, {
            skipEmptyLines: true,
          });
          if (result.data.length) {
            $(self.root).find('.import.button').removeAttr('disabled');
            self.records = result.data.map(function (row) {
              return {
                token: row[0],
                checksum: row[1],
                productionDate: row[2],
                expireDate: row[3]
              };
            });
            self.update();
          }
        };
        fr.readAsText(e.currentTarget.files[0]);
      });
    }).on('vendor.list.fetched', function (data) {
      self.vendors = data.data;
      self.update();
      self.$vendorDropdown = $(self.root).find('.ui.dropdown.vendor').dropdown({
        onChange: function (value) {
          bus.trigger('spu.list.fetch', {
            vendorId: value,
          });
        }
      });
    }).on('spu.list.fetched', function (data) {
      self.spus = data.data;
      self.update();
      self.$spuDropdown = $(self.root).find('.ui.dropdown.spu').dropdown({
        onChange: function () {
            var $fileButton = $(self.root).find('.file.button');
            var $importButton = $(self.root).find('.import.button');
            return function (value) {
              if (value) {
                $fileButton.removeAttr('disabled');
              } else {
                $fileButton.attr('disabled', 'disabled');
                $importButton.attr('disabled', 'disabled');
              }
            }
        }()
      }).dropdown('clear');
    }).on('sku.created', function (data) {
      swal({
        type: 'success',
        title: '',
        text: '上传成功!',
      });
    }).on('sku.create.failed', function (err) {
      var row = err.response.body.row;
      var rowNO = err.response.body.rowNO;
      swal({
        type: 'error',
        title: '',
        text: _.template(hintTemplate)({ rowNO: rowNO + 1, row: row }),
        html: true,
      })
    });
    var hintTemplate = `
    <p>该行数据出现错误(可能是重复的token或者格式错误):</p>
    <table class="ui compact table">
      <thead>
        <tr>
          <th>行号</th>
          <th>token</th>
          <th>校验码</th>
          <th>生产日期</th>
          <th>有效截止日期</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><%= rowNO %></td>
          <td><%= row.token %></td>
          <td><%= row.checksum %></td>
          <td><%= row.productionDate %></td>
          <td><%= row.expireDate %></td>
          <td></td>
        </tr>
      </tbody>
    `;
  </script>
</upload-sku-app>
