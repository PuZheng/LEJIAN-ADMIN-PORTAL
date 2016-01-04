var riot = require('riot');
var bus = require('riot-bus');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');

<gallery>
  <div class="ui segment">
    <div class="ui small images">
      <div class="ui circular huge green icon file button { !opts.editable && 'disabled' }" if={ images.length < (opts.max || Number.MAX_SAFE_INTEGER) }>
        <i class="icon upload"></i>
        <input type="file">
      </div>
      <div class="ui fluid image" each={ images }>
        <a class="remove ui red right corner label" data-path={ path } show={ parent.opts.editable }>
          <i class="trash icon"></i>
        </a>
        <img src={ url }>
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
    self.addImages = function (images) {
        self.images = self.images.concat(images);
        self.update();
    };

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
            url: data,
            uuid: uuid,
          });
          self.update();
        };
        fr.readAsDataURL(file);
        bus.trigger('asset.upload', file, '', uuid);
      });
      $(self.root).on('click', '.remove.label', function (e) {
        var target = $(e.currentTarget).data('path');
        self.images = self.images.filter(function (im) {
          return im.path !== target;
        });
        self.trigger('remove', target);
        self.update();
      });
      if (!_.isEmpty(opts.images)) {
        self.images = opts.images;
        self.update();
      }
    }).on('asset.uploaded', function (paths, filename, uuid) {
      _(self.images).filter(function (image) {
        return image.uuid === uuid;
      }).first().path = paths[0];
      self.trigger('add', paths[0]);
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
