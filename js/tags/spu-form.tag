var riot = require('riot');
var bus = require('riot-bus');
var config = require('config');
var urljoin = require('url-join');
var toastr = require('toastr/toastr.min.js');
var request = require('request');
require('toastr/toastr.min.css');
require('tags/centered-image.tag');
require('tags/gallery.tag');
var swal = require('sweetalert/sweetalert.min.js');

<spu-form>
  <form class="ui form" action="">
    <loader if={ loading }></loader>
    <div class="ui error message">
    </div>
    <div class="required inline field { !opts.editable && 'disabled' }">
      <label for="">名称</label>
      <input type="text" placeholder="输入名称..." name="name" value={ item.name }>
    </div>
    <div class="required inline field { !opts.editable && 'disabled' }">
      <label for="">code</label>
      <input type="text" placeholder="输入code..." name="code" value={ item.code }>
    </div>
    <div class="required inline field { !opts.editable && 'disabled' }">
      <label for="">零售价</label>
      <input type="number" placeholder="输入零售价..." name="msrp" value={ item.msrp }>
      <span>(元)</span>
    </div>
    <div class="{ !opts.editable && 'disabled' } inline field">
      <div class="ui checkbox">
        <label for="">是否激活</label>
        <input type="checkbox" name="enabled" checked={ item && item.enabled }>
      </div>
    </div>
    <div class="inline field { !opts.editable && 'disabled' }">
      <label for="">评分(1-5)</label>
      <input type="number" placeholder="输入评分" step="1" name="rating" min="1" max="5" value={ (item && item.rating) || 1}>
    </div>
    <div class="inline field { !opts.editable && 'disabled' }">
      <label for="">描述</label>
      <textarea name="description" cols="30" rows="10">{ item.description }</textarea>
    </div>
    <div class="required inline field { !opts.editable && 'disabled' }">
      <label for="">所属分类</label>
      <div class="spu-type ui fluid search selection dropdown">
        <input type="hidden" name="spu_type_id" value={ item.spuTypeId }>
        <i class="dropdown icon"></i>
        <div class="default text">选择分类</div>
        <div class="menu">
          <div class="item" data-value={ id } each={ spuTypes }>{ name }</div>
        </div>
      </div>
    </div>
    <div class="required inline field { !opts.editable && 'disabled' }">
      <label for="">厂商</label>
      <div class="vendor ui fluid search selection dropdown">
        <input type="hidden" name="vendor_id" value={ item.vendorId }>
        <i class="dropdown icon"></i>
        <div class="default text">选择厂商</div>
        <div class="menu">
          <div class="item" data-value={ id } each={ vendors }>{ name }</div>
        </div>
      </div>
    </div>
    <div class="inline field { !opts.editable && 'disabled' }">
      <label for="">图片</label>
      <div riot-tag="gallery" images={ item.pics }></div>
    </div>
    <hr>
    <div class="ui buttons">
      <input type="submit" class="ui green button" if={ opts.editable } value="提交"></input>
    </div>
  </form>
  <style scoped>
    form .field textarea {
      width: 50%!important;
    }
    form [riot-tag="gallery"] {
      width: 60%!important;
    }
  </style>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.loading = 0;
    self.formData = function () {
      var ret = _(self.$form.serializeArray()).map(function (o) {
        return [o.name, o.value];
      }).object().value();
      ret.enabled = ret.enabled === 'on';
      if (ret.msrp === '') {
        delete ret.msrp;
      } else {
        ret.msrp = parseFloat(ret.msrp);
      }
      ret.pics = self.tags['gallery'].images.map(function (im) {
        return im.url
      });
      return ret;
    };
    self.diff = function () {
      if (!self.item) {
        return self.formData();
      } else {
        var formData = self.formData();
        var diff = {};
        _(formData).pairs().each(function (pair) {
          var k = pair[0];
          var v = pair[1];
          if (v != self[k]) {
            if (k === 'pics') {
              diff[k] = 
            } else {
              diff[k] = v;
            }
          }
        });
        return diff;
      }
    };

    _.extend(self, {
      loading: 0,
    });
    self.on('mount', function () {
      $(self.root).find('.ui.checkbox').checkbox();
      self.$form = $(self.root).find('form').submit(function (e) {
        return false;
      });
      self.$form.form({
        fields: {
          name: {
            identifier: 'name',
            rules: [
              {
                type: 'empty',
                prompt: '名称不能为空'
              }
            ]
          },
          msrp: {
            identifier: 'msrp',
            rules: [
              {
                type: 'empty',
                prompt: '零售价不能为空'
              }
            ]
          },
          code: {
            identifier: 'code',
            rules: [
              {
                type: 'empty',
                prompt: 'code不能为空'
              }
            ]
          },
          spuType: {
            identifier: 'spu_type_id',
            rules: [
              {
                type: 'empty',
                prompt: '请选择所属分类'
              }
            ]
          },
          vendor: {
            identifier: 'vendor_id',
            rules: [
              {
                type: 'empty',
                prompt: '请选择厂商',
              }
            ]
          }
        },
        on: 'submit',
        keyboardShortcuts: false,
        onSuccess: function () {
          if (self.item) {
            var diff = self.diff();
            if (_.isEmpty(formData)) {
              toastr.info('没有变化！', '', {
                positionClass: 'toast-bottom-center',
              timeOut: 1000,
              });
            } else {
              bus.trigger('spu.update', _.extend({}, self.item), diff);
            };
          } else {
            bus.trigger('spu.create', self.formData());
          }
        }
      });
    }).on('spuType.list.fetching vendor.list.fetching spu.creating spu.fetching', function () {
      ++self.loading;
      self.update();
    }).on('spuType.list.fetched', function (data) {
      self.spuTypes = data.data;
      self.update();
      $(self.root).find('.spu-type.dropdown').dropdown();
    }).on('vendor.list.fetched', function (data) {
      self.vendors = data.data;
      self.update();
      $(self.root).find('.vendor.dropdown').dropdown();
    }).on('spuType.list.fetch.done vendor.list.fetch.done spu.create.done spu.fetch.done', function () {
      --self.loading;
      self.update();
    }).on('spu.created', function (item) {
      swal({
        type: 'success',
        title: '',
        text: '创建成功，是否继续编辑?',
        showCancelButton: true,
      }, function (confirmed) {
        bus.trigger('go', confirmed? '/spu/' + item.id: '/spu-list');
      });
    }).on('spu.fetched', function (item) {
      self.item = item;
      self.item.pics = self.item.pics.map(function (pic) {
        return urljoin(config.backend, pic);
      })
      self.update();
    }).on('spu.updated', function (item, patch) {
      self.item = item;
      toastr.success('更新成功！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
      self.editable = false;
      self.update();
    }).on('spu.update.failed', function (oldItem, patch) {
      toastr.error('更新失败！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
      _.assign(self.item, oldItem);
    });
  </script>
</spu-form>
