var riot = require('riot');
var bus = require('riot-bus');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');
var swal = require('sweetalert/sweetalert.min.js');
require('tags/loader.tag');

<field class="inline field { opts.required && 'required' }">
  <label for="">{ opts.field }</label>
  <input type={ opts.type || 'text' } placeholder="输入{ opts.field }..." value={ parent.item[opts.prop] } disabled={ !parent.opts.editable } name={ opts.prop }>

</field>

<vendor-form>
  <form class="ui form" action="">
    <loader if={ loading }></loader>
    <div class="ui error message"></div>
    <div riot-tag="field" required="required" field="企业名称" prop="name"></div>
    <div class="inline field">
      <div class="ui checkbox">
        <label for="">是否激活</label>
        <input type="checkbox" name="enabled" checked={ !opts.ctx.params.id || item.enabled } disabled={ !opts.editable }>
      </div>
    </div>
    <div class="inline field">
      <label for="">简介</label>
      <textarea name="desc" cols="30" rows="10">{ item.desc }</textarea>
    </div>
    <div riot-tag="field" field="电话" prop="tel"></div>
    <div riot-tag="field" field="地址" prop="addr"></div>
    <div riot-tag="field" field="电子邮箱" prop="email"></div>
    <div riot-tag="field" field="企业官网" prop="website" type="url"></div>
    <div riot-tag="field" field="微博账户" prop="weiboUserId"></div>
    <div riot-tag="field" field="微博主页" prop="weiboHomepage" type="url"></div>
    <div riot-tag="field" field="微信账户" prop="weixinAccount"></div>

    <div class="ui buttons">
      <input type="submit" class="ui green button" if={ opts.editable } value="提交"></input>
    </div>
  </form>
  <style scoped>
    form .field textarea {
      width: 50%!important;
    }
  </style>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.loading = 0;

    self.on('mount', function () {
      self.$form = $(self.root).find('form').form({
        fields: {
          name: {
            identifier: 'name',
            rules: [
              {
                type: 'empty',
                prompt: '名称不能为空'
              }
            ]
          }
        },
        on: 'submit',
        onSuccess: function () {
          if (self.item) {
            var patch = self.patch();
            if (_.isEmpty(patch)) {
              toastr.info('没有变化！', '', {
                positionClass: 'toast-bottom-center',
              timeOut: 1000,
              });
            } else {
              bus.trigger('vendor.update', _.extend({}, self.item), patch);
            };
          } else {
            bus.trigger('vendor.create', self.formData());
          }
        }
      }).submit(function () {
        return false;
      });
      $(self.root).find('.ui.checkbox').checkbox();
    }).on('vendor.creating vendor.fetching vendor.updating', function () {
      ++self.loading;
      self.update();
    }).on('vendor.fetched', function (item) {
      self.item = item;
      self.update;
    }).on('vendor.fetch.done', function () {
      --self.loading;
      self.update();
    }).on('vendor.create.done', function () {
      --self.loading;
      self.update();
    }).on('vendor.created', function (item) {
      swal({
        type: 'success',
        title: '',
        text: '创建成功，是否继续编辑?',
        showCancelButton: true,
      }, function (confirmed) {
        bus.trigger('go', confirmed? '/vendor/' + item.id: '/vendor-list');
      });
    }).on('vendor.create.failed', function (data, err) {
      self.$form.form('add errors', [ err.response.body.message ]);
    }).on('vendor.update.done', function () {
      --self.loading;
      self.update();
    }).on('vendor.updated', function (item, orig, patch) {
      self.item = item; // must set the item
      toastr.success('更新成功！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
    }).on('vendor.update.failed', function (err, orig, patch) {
      // TODO restore the form
      toastr.error('更新失败！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
    }).on('error', function (err) {
      console.error(err);
    });
    self.formData = function () {
      var ret = _(self.$form.serializeArray()).map(function (o) {
        return [o.name, o.value];
      }).object().value();
      ret.enabled = ret.enabled === 'on';
      return ret;
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

</vendor-form>

