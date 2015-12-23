var riot = require('riot');
var bus = require('riot-bus');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');
var request = require('request');
require('tags/centered-image.tag');

<spu-type-form>
  <form class="ui form" action="">
    <loader if={ loading }></loader>
    <div class="ui error message">
    </div>
    <div class="ui inline field" if={ item }>
      <label for="">SPU数量</label>
      <div class="ui tiny header">
        <a href="/spu-list?spu_type={ item.id }">
          { item.spuCnt }
        </a>
      </div>
    </div>
    <div class="ui inline field">
      <label for="">名称</label>
      <input type="text" name="name" value={ item.name } disabled={ !opts.editing }>
    </div>
    <div class="ui inline field">
      <label for="">权重</label>
      <input type="number" name="weight" value={ item.weight } disabled={ !opts.editing }  step=1>
    </div>
    <div class="ui inline field">
      <div class="ui checkbox">
        <input type="checkbox" disabled={ !opts.editing } checked={ item.enabled } name="enabled">
        <label for="">是否激活</label>
      </div>
    </div>
    <div class="ui inline field">
      <label for="">图标</label>
      <div>
        <centered-image img={ item.pic.url }></centered-image>
        <input type="hidden" name="picPath" value={ item.picPath }>
      </div>
      <button class="file ui tiny button" disabled={ !opts.editing }>上传图片
        <input type="file">
      </button>
    </div>
    <hr>
    <div class="ui buttons">
      <input type="submit" class="ui green button" if={ opts.editing } value="提交"></input>
    </div>
  </form>
  <style scoped>

  </style>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    _.extend(self, {
      formData: function () {
        var item = this.item;
        var data = _.object(this.$form.serializeArray().map(
          function ({name, value}) {
            return [name, value];
          }
        ));
        // serialize will omit checkbox when it is unchecked
        if (data.enabled) {
          data.enabled = true;
        } else {
          data.enabled = false;
        }
        return data;
      },
    });
    var formOpts = {
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
        picPath: {
          identifier: 'picPath',
          rules: [
            {
              type: 'empty',
              prompt: '图片不能为空'
            },
          ]
        },
      },
      on: 'submit',
      keyboardShortcuts: false,
      onSuccess: function () {
        if (self.item) {
          var formData = self.formData();
          if (_.isEmpty(formData)) {
            toastr.info('没有变化！', '', {
              positionClass: 'toast-bottom-center',
              timeOut: 1000,
            });
          } else {
            bus.trigger('spuType.update', _.extend({}, self.item), formData);
          }
        } else {
          bus.trigger('spuType.create', self.formData());
        }
      }
    };
    self.on('mount', function () {
      self.$form = $(self.root).find('form').form(formOpts).submit(function (e) {
        e.preventDefault();
        return false;
      });
      self.$form.find('.ui.checkbox').checkbox();
      self.$form.find('[type=file]').change(function (e) {
        var file = e.currentTarget.files[0];
        var fr = new FileReader();
        fr.onload = function (e) {
          var data = e.target.result;
          self.tags['centered-image'].opts = {
            img: data,
          };
          self.update();
        };
        fr.readAsDataURL(file);
        bus.trigger('asset.upload', file);
      });
      self.$fileInput = $(self.root).find('[type=file]');
    }).on('spuType.fetching', function () {
      self.loading = true;
      self.update();
    }).on('spuType.fetched', function (item) {
      self.item = item;
      self.loading = false;
      self.update();
    }).on('spuType.updated', function (item, patch) {
      self.item = item;
      toastr.success('更新成功！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
      self.editing = false;
      self.update();
    }).on('spuType.update.failed', function (oldItem, patch) {
      toastr.error('更新失败！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
      _.assign(self.item, oldItem);
    }).on('asset.uploaded', function (paths) {
      $(self.root).find('[name=picPath]').val(paths[0]);
      toastr.success('上传成功!', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
    }).on('asset.upload.failed', function () {
      toastr.error('上传失败！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
    }).on('asset.upload.done', function () {
      self.$fileInput.val('');
    }).on('spuType.created', function (item) {
      swal({
        type: 'success',
        title: '',
        text: '创建成功，是否继续编辑?',
        showCancelButton: true,
      }, function (confirmed) {
        bus.trigger('go', confirmed? '/spu-type/' + item.id: '/spu-type-list');
      });
    }).on('spuType.create.failed', function (data, err) {
      self.$form.form('add errors', [ err.response.body.message ]);
      toastr.error('创建失败！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
    });
  </script>
</spu-type-form>
