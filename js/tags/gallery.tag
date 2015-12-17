var riot = require('riot');
var bus = require('riot-bus');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');

<gallery>
  <div class="ui segment">
    <div class="ui small images">
      <div class="ui circular huge green icon file button">
        <i class="icon upload"></i>
        <input type="file">
      </div>
      <div class="ui medium image" each={ images }>
        <div class="ui dimmer">
          <div class="content">
            <div class="center">
              <div class="remove ui red button" data-url={ url }>删除</div>
            </div>
          </div>
        </div>
        <img class="ui image" src={ dataURL || image.url }>
      </div>
    </div>
    <div class="ui bottom attached progress">
      <div class="bar"></div>
    </div>
  </div>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.images = [];
    self.uuid = function () {
      var uuid = 0;
      return function () {
        return ++uuid;
      }
    }();

    self.on('mount', function () {
      self.$progress = $(self.root).find('.progress');
      self.$fileInput = $(self.root).find('[type=file]');
      self.$fileInput.change(function (e) {
        var file = e.currentTarget.files[0];
        var fr = new FileReader();
        var uuid = self.uuid();
        fr.onload = function (e) {
          var data = e.target.result;
          self.images.push({
            dataURL: data,
            uuid: uuid,
          });
          self.update();
          $(self.root).find('.image').dimmer({
            on: 'hover'
          });
        };
        fr.readAsDataURL(file);
        bus.trigger('asset.upload', file, '', uuid);
      });
      $(self.root).on('click', '.remove.button', function (e) {
        var target = $(e.currentTarget).data('url');
        self.images = self.images.filter(function (im) {
          return im.url !== target;
        });
        self.update();
      })
    }).on('asset.uploaded', function (paths, filename, uuid) {
      _(self.images).filter(function (image) {
        return image.uuid === uuid;
      }).first().url = paths[0];
      self.update();
    }).on('asset.upload.done', function () {
      self.$fileInput.val('');
    }).on('asset.upload.failed', function () {
      toastr.error('上传失败！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
    }).on('before.asset.upload', function () {
      self.$progress.progress({
        percent: 0,
      });
    }).on('asset.upload.progress', function (percent) {
      self.$progress.progress({
        percent: percent * 100,
      });
    }).on('asset.uploaded', function () {
      toastr.success('上传成功!', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
      setTimeout(function () {
        self.$progress.progress({ percent: 0 });
      }, 1000);
    });
  </script>
</gallery>
