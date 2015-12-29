var riot = require('riot');
var bus = require('riot-bus');
require('tags/form-field.tag');
require('tags/loader.tag');
var moment = require('moment');
var swal = require('sweetalert/sweetalert.min.js');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');

<sku-form>
  <form class="ui form" action="">
    <loader if={ loading }></loader>
    <div class="ui error message">
    </div>
    <div class="required inline field">
      <label for="">SPU</label>
      <div class="ui selection dropdown { !opts.editable && 'disabled' }">
        <input type="hidden" name="spuId" value={ item.spuId }>
        <i class="dropdown icon"></i>
        <div class="default text">选择SPU</div>
        <div class="menu">
          <div class="item" data-value={ id } each={ spus }>{ name }</div>
        </div>
      </div>
    </div>
    <div riot-tag="field" field="token" prop="token" required="required"></div>
    <div riot-tag="field" field="校验码" prop="checksum" required="required"></div>
    <div class="required inline field">
      <label for="">生产日期</label>
      <input type="date" name="productionDate" value={ (item && item.productionDate) || moment().format('YYYY-MM-DD') } disabled={ !opts.editable }>
    </div>
    <div class="required inline field">
      <label for="">有效截止日期</label>
      <input type="date" name="expireDate" min={ (item && item.productionDate) || moment().format('YYYY-MM-DD') } value={ (item && item.expireDate) } disabled={ !opts.editable }>
    </div>
    <input type="submit" class="ui green button" if={ opts.editable } value="提交">
  </form>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.loading = 0;
    self.moment = moment;

    self.on('spu.list.fetching sku.creating sku.fetching sku.updating', function () {
      ++self.loading;
      self.update();
    }).on('spu.list.fetch.done sku.create.done sku.fetch.done sku.update.done', function () {
      --self.loading;
      self.update();
    });

    self.on('mount', function () {
      $(self.productionDate).change(function (e) {
        $(self.expireDate).attr('min', moment($(e.currentTarget).val(), 'YYYY-MM-DD').add(1, 'days').format('YYYY-MM-DD'));
      });
      self.$form = $(self.root).find('form').submit(function (e) {
        return false;
      });
      self.$form.form({
        fields: {
          spuId: {
            identifier: 'spuId',
            rules: [{
              type: 'empty',
              prompt: '请选择SPU'
            }]
          },

          token: {
            identifier: 'token',
            rules: [{
              type: 'empty',
              prompt: 'token不能为空'
            }]
          },
          checksum: {
            identifier: 'checksum',
            rules: [{
              type: 'empty',
              prompt: '校验码不能为空'
            }]
          },
          productionDate: {
            identifier: 'productionDate',
            rules: [{
              type: 'empty',
              prompt: '生产日期不能为空'
            }]
          },
          expireDate: {
            identifier: 'expireDate',
            rules: [{
              type: 'empty',
              prompt: '有效日期不能为空'
            }]
          },
        },
        on: 'submit',
        keyboardShortcuts: false,
        onSuccess: function () {
          if (self.item) {
            var patch = self.patch();
            if (_.isEmpty(patch)) {
              toastr.info('没有变化！', '', {
                positionClass: 'toast-bottom-center',
              timeOut: 1000,
              });
            } else {
              bus.trigger('sku.update', self.item, patch);
              // make a copy
              self.item = _.assign({}, self.item, patch);
              self.update();
            }
          } else {
            bus.trigger('sku.create', self.formData());
          }
        }
      });
    }).on('spu.list.fetched', function (data) {
      self.spus = data.data;
      self.update();
      $(self.root).find('.ui.dropdown').dropdown();
    }).on('sku.created', function (item) {
      swal({
        type: 'success',
        title: '',
        text: '创建成功，是否继续编辑?',
        showCancelButton: true,
      }, function (confirmed) {
        bus.trigger('go', confirmed? '/sku/' + item.id: '/sku-list');
      });
    }).on('sku.fetched', function (item) {
      self.item = item;
      self.update();
    }).on('sku.updated', function (item) {
      self.item = item;
      toastr.success('更新成功！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
      bus.trigger('go', '/sku/' + item.id);
    }).on('sku.update.failed', function (err, oldItem, patch) {
      toastr.error('更新失败！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
      _.assign(self.item, oldItem);
      self.update();
    });

    self.formData = function () {
      return _.object(this.$form.serializeArray().map(function ({ name, value }) {
        return [name, value];
      }))
    };
    self.patch = function () {
      var data = self.formData();
      if (!self.item) {
        return data;
      }
      return _(data).pairs().filter(function ([k, v]) {
        return self.item[k] != v;
      }).object().value();
    };
  </script>
</sku-form>
