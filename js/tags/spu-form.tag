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
    <div class="required inline field">
      <label for="">名称</label>
      <input type="text" placeholder="输入名称..." name="name" value={ item.name } disabled={ !opts.editable }>
    </div>
    <div class="required inline field">
      <label for="">code</label>
      <input type="text" placeholder="输入code..." name="code" value={ item.code } disabled={ !opts.editable }>
    </div>
    <div class="required inline field">
      <label for="">零售价</label>
      <input type="number" placeholder="输入零售价..." name="msrp" value={ item.msrp } disabled={ !opts.editable }>
      <span>(元)</span>
    </div>
    <div class="inline field">
      <div class="ui checkbox">
        <label for="">是否激活</label>
        <input type="checkbox" name="enabled" checked={ item && item.enabled } disabled={ !opts.editable }>
      </div>
    </div>
    <div class="inline field">
      <label for="">评分(1-5)</label>
      <input type="number" placeholder="输入评分" step="1" name="rating" min="1" max="5" value={ (item && item.rating) || 1} disabled={ !opts.editable }>
    </div>
    <div class="inline field">
      <label for="">描述</label>
      <textarea name="desc" cols="30" rows="10" disabled={ !opts.editable }>{ item.desc }</textarea>
    </div>
    <div class="required inline field">
      <label for="">所属分类</label>
      <div class="{ !opts.editable && 'disabled' } spu-type ui fluid search selection dropdown">
        <input type="hidden" name="spuTypeId" value={ item.spuTypeId }>
        <i class="dropdown icon"></i>
        <div class="default text">选择分类</div>
        <div class="menu">
          <div class="item" data-value={ id } each={ spuTypes }>{ name }</div>
        </div>
      </div>
    </div>
    <div class="required inline field">
      <label for="">厂商</label>
      <div class="{ !opts.editable && 'disabled' } vendor ui fluid search selection dropdown">
        <input type="hidden" name="vendorId" value={ item.vendorId }>
        <i class="dropdown icon"></i>
        <div class="default text">选择厂商</div>
        <div class="menu">
          <div class="item" data-value={ id } each={ vendors }>{ name }</div>
        </div>
      </div>
    </div>
    <div class="inline field">
      <label for="">图片</label>
      <div riot-tag="gallery" editable={ opts.editable }></div>
      <input type="hidden" name="picPaths">
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
      ret.picPaths = ret.picPaths && ret.picPaths.split(',');
      if (ret.msrp === '') {
        delete ret.msrp;
      } else {
        ret.msrp = parseFloat(ret.msrp);
      }
      return ret;
    };
    self.diff = function () {
      if (!self.item) {
        return self.formData();
      } else {
        var formData = self.formData();
        var diff = _(formData).pairs().filter(function (pair) {
          var k = pair[0];
          var v = pair[1];
          if (k !== 'picPaths') {
            return self.item[k] != v;
          } else {
            return self.item.picPaths.join(',') !== v.join(',');
          }
        }).object().value();
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
            identifier: 'spuTypeId',
            rules: [
              {
                type: 'empty',
                prompt: '请选择所属分类'
              }
            ]
          },
          vendor: {
            identifier: 'vendorId',
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
            if (_.isEmpty(diff)) {
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
      self.tags['gallery'].on('remove', function (path) {
        $(self.picPaths).val($(self.picPaths).val().split(',').filter(function (path_) {
          return path_ != path;
        }));
        console.log('remove a new image ' + path);
      }).on('add', function (path) {
        $(self.picPaths).val($(self.picPaths).val() + ',' + path);
        console.log('add a new image ' + path);
      });
    }).on('spuType.list.fetching vendor.list.fetching spu.creating spu.fetching spu.updating', function () {
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
    }).on('spuType.list.fetch.done vendor.list.fetch.done spu.create.done spu.fetch.done spu.update.done', function () {
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
      self.tags['gallery'].addImages(item.pics);
      $(self.picPaths).val(item.pics.map(function (pic) {
        return pic.path;
      }));
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
      self.update();
    }).on('error', function (err) {
      console.error(err);
    });
  </script>
</spu-form>
