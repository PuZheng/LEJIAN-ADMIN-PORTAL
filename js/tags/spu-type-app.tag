var riot = require('riot');
var bus = require('riot-bus');

require('tags/loader.tag');
require('tags/spu-type-form.tag');
var nprogress = require('nprogress/nprogress.js');
require('nprogress/nprogress.css');
var swal = require('sweetalert/sweetalert.min.js');

<spu-type-app>
  <div class="ui grid object-app">
    <div class="row">
      <div class="column">
        <div class="ui top attached blue message">
          <div class="ui header" if={ opts.ctx.params.id }>
            SPU分类-<i>{ item.name }</i>
          </div>
          <div class="ui header" if={ !opts.ctx.params.id }>
            创建SPU分类
          </div>
          <i class="icon asterisk" if={ opts.ctx.params.id && editing }></i>
          <button class="ui tiny circular icon green button" data-content="编辑对象" onclick={ onClickEdit } show={ opts.ctx.params.id && !editing }>
            <i class="icon edit"></i>
          </button>
          <button class="ui tiny circular icon button" data-content="锁定对象" onclick={ onCancelEdit } show={ opts.ctx.params.id && editing }>
            <i class="icon lock"></i>
          </button>

          <button class="ui tiny circular icon red button" data-content="删除对象" onclick={ onClickDelete } show={ opts.ctx.params.id }>
            <i class="icon trash"></i>
          </button>
        </div>
        <div class="ui bottom attached segment">
          <spu-type-form editing={ editing } item-id={ item.id }></spu-type-form>
        </div>
      </div>
    </div>
  </div>

  <style scoped>
    form centered-image {
        display: inline-block;
        width: 256px;
        height: 256px;
    }

    form .image.field > div {
        position: relative;
        display: inline-block;
    }
  </style>

  <script>
    var self = this;
    self.mixin(bus.Mixin);

    _.extend(self, {
      onClickEdit: function (e) {
        self.editing = true;
        self.update();
      },
      onCancelEdit: function (e) {
        e.preventDefault();
        self.editing = false;
        self.update();
      },
      onClickDelete: function (e) {
        e.preventDefault();
        if (self.spuType.spuCnt != 0) {
          swal({
            type: 'error',
            title: '请删除该分类下所有的SPU后，再删除本分类!',
            showCancelButton: true,
          });
        } else {
          swal({
            type: 'warning',
            title: '您确认要删除该分类?',
            closeOnConfirm: false,
            showCancelButton: true,
          }, function (confirmed) {
            if (confirmed) {
              bus.trigger('spuType.delete', self.spuType.id);
            }
          });
        }
      },
      editing: !opts.ctx.params.id, // 创建模式下，默认可编辑
    });

    self.on('mount', function () {
      $(self.root).find('[data-content]').popup();
      nprogress.configure({ trickle: false });
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
    }).on('spuType.fetched', function (item) {
      self.item = item;
      self.update();
    }).on('spuType.deleted', function () {
      swal({
        type: 'success',
        title: '成功删除!',
      }, function () {
        bus.trigger('go', '/');
      });
    }).on('spuType.delete.failed', function () {
      swal.close();
      toastr.error('删除失败！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
    });
  </script>
</spu-type-app>

