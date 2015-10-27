var riot = require('riot');
var bus = require('riot-bus');
var config = require('config');
var urljoin = require('url-join');

require('semantic-ui/semantic.css');
require('semantic-ui/semantic.min.js');
require('tags/loader.tag');
require('tags/centered-image.tag');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');
var nprogress = require('nprogress/nprogress.js');
require('nprogress/nprogress.css');

<spu-type-app>
  <div class="ui page grid">
    <div class="column">
      <div class="ui top attached blue message">
        <div class="ui grid">
          <div class="two column wide row">
            <div class="column">
              <div class="ui header">
                SPU类型-<i>{ spuType.name }</i>
              </div>
              <i class="icon asterisk" if={ editing }></i>
            </div>
            <div class="right aligned column">
              <div class="ui icon buttons">
                <button class="ui green button edit { editing && 'disabled' }" data-content="编辑对象" onclick={ onClickEdit }>
                  <i class="icon edit"></i>
                </button>
                <button class="ui red button" data-content="删除对象">
                  <i class="icon trash"></i>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="ui bottom attached segment">
        <loader if={ loading }></loader>
        <form class="ui form" action="" show={ spuType }>
          <div class="ui inline field">
            <label for="">名称</label>
            <input type="text" name="name" value={ spuType.name } disabled={ !editing }>
          </div>
          <div class="ui inline field">
            <label for="">权重</label>
            <input type="number" name="weight" value={ spuType.weight } disabled={ !editing }  step=1>
          </div>
          <div class="ui inline field">
            <div class="ui checkbox">
              <input type="checkbox" disabled={ !editing }>
              <label for="">是否激活</label>
            </div>
            <input type="hidden" name="enabled">
          </div>
          <div class="ui inline image field">
            <label for="">图标</label>
            <div>
              <centered-image img={ urljoin(config.backend, spuType.picPath) }></centered-image>
              <input type="file" disabled={ !editing }>
            </div>
            <input type="hidden" name="picPath" value={ spuType.picPath }>
          </div>
          <hr>
          <div class="ui buttons">
            <button class="ui button" if={ editing } onclick={ onCancelEdit }>取消</button>
            <button class="ui green button" if={ editing }>提交</button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <style scoped>
    .top.attached.message .row {
      padding: 0;
    }
    .top.attached.message .header {
      display: inline-block !important;
    }

    .bottom.attached.segment {
      min-height: 32rem;
    }

    form .field label {
      width: 10rem !important;
    }
    form centered-image {
      display: inline-block;
      width: 256px;
      height: 256px;
    }

    form .image.field > div {
      position: relative;
      display: inline-block;
    }

    input[type=file] {
      position: absolute;
      top: 0;
      right: 0;
      min-width: 100%;
      min-height: 100%;
      opacity: 0 !important;
      display: block;
    }

  </style>

  <script>
    var self = this;
    self.mixin(bus.Mixin);

    self.urljoin = urljoin;
    self.config = config;
    self.onClickEdit = function (e) {
      self.editing = true;
      self.update();
    };
    self.onCancelEdit = function (e) {
      e.preventDefault();
      self.editing = false;
      self.update();
    }

    self.on('mount', function () {
      $(self.root).find('[data-content]').popup();
      $(self.root).find('[type=file]').change(function (e) {
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
      nprogress.configure({ trickle: false });
      $(self.root).find('form').submit(function (e) {
        e.preventDefault();
        bus.trigger('spuType.update', _.extend({}, self.spuType), _.object($(this).serializeArray().filter(function (i) {
          return self.spuType[i.name] != i.value;
        }).map(function (i) {
          return [i.name, i.value];
        })));
      });
      $(self.root).find('.ui.checkbox').checkbox({
        onChange: function () {
          $(self.root).find('[name=enabled]').val($(this).is(':checked')? 1: 0);
        },
      });
    }).on('update', function () {
      if (self.spuType) {
        $(self.root).find('.ui.checkbox').checkbox(self.spuType.enabled? 'set checked': 'set unchecked');
      }
    }).on('spuType.updated', function (spuType, patch) {
      self.spuType = spuType;
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
      _.assign(self.spuType, oldItem);
    }).on('before.asset.update', function () {
      nprogress.start();
      self.loading = true;
      self.update;
    }).on('asset.upload.progress', function (percent) {
      nprogress.set(percent);
    }).on('asset.upload.done', function (paths) {
      $(self.root).find('[name=picPath]').val(paths[0]);
    }).on('asset.upload.failed', function () {
      toastr.error('上传失败！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
    }).on('asset.upload.end', function () {
      nprogress.done();
      self.$fileInput.val('');
    }).on('spuType.fetching', function () {
      self.loading = true;
      self.update();
    }).on('spuType.fetched', function (spuType) {
      self.spuType = spuType;
      self.update();
    }).on('spuType.fetch.done', function () {
      self.loading = false;
      self.update();
    }).on('spuType.fetch.failed', function () {
        toastr.error('无法获取对象！', '', {
          positionClass: 'toast-bottom-center',
          timeOut: 1000,
        });
    });
  </script>
</spu-type-app>

