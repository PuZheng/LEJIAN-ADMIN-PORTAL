var riot = require('riot');
var bus = require('riot-bus');
var config = require('config');
var urljoin = require('url-join');
var request = require('request');

require('semantic-ui/semantic.css');
require('semantic-ui/semantic.min.js');
require('tags/loader.tag');
require('tags/centered-image.tag');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');
var nprogress = require('nprogress/nprogress.js');
require('nprogress/nprogress.css');
var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');

<spu-type-app>
  <div class="ui page grid">
    <div class="column">
      <div class="ui top attached blue message">
        <div class="ui grid">
          <div class="two column wide row">
            <div class="column">
              <div class="ui header" if={ opts.id }>
                SPU分类-<i>{ spuType.name }</i>
              </div>
              <div class="ui header" if={ !opts.id }>
                创建SPU分类
              </div>
              <i class="icon asterisk" if={ editing }></i>
            </div>
            <div class="right aligned column" if={ spuType }>
              <div class="ui icon buttons">
                <button class="ui green button edit { editing && 'disabled' }" data-content="编辑对象" onclick={ onClickEdit }>
                  <i class="icon edit"></i>
                </button>
                <button class="ui red button" data-content="删除对象" onclick={ onClickDelete }>
                  <i class="icon trash"></i>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="ui bottom attached segment">
        <loader if={ loading }></loader>
        <form class="ui form" action="">
          <div class="ui error message">
          </div>
          <div class="ui inline field" if={ spuType }>
            <label for="">SPU数量</label>
            <div class="ui tiny header">{ spuType.spuCnt }</div>
          </div>
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
              <input type="hidden" name="picPath" value={ spuType.picPath }>
            </div>
            <button class="ui button" if={ !opts.itemId }>上传图片
              <input type="file" disabled={ !editing }>
            </button>
          </div>
          <hr>
          <div class="ui buttons">
            <button class="ui button" if={ editing } onclick={ onCancelEdit }>取消</button>
            <input type="submit" class="ui green button" if={ editing } value="提交"></input>
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
    form .field .header {
      display: inline-block;
    }
    form centered-image {
      display: inline-block;
      width: 256px;
      height: 256px;
    }

    form .button {
      display: inline-block;
      position: relative;
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

    _.extend(self, {
      urljoin: urljoin,
      config: config,
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
      editing: !opts.itemId,
    });

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
      $(self.root).find('.ui.checkbox').checkbox({
        onChange: function () {
          $(self.root).find('[name=enabled]').val($(this).is(':checked'));
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
          if (opts.itemId) {
            bus.trigger('spuType.update', _.extend({}, self.spuType), _.object($(this).serializeArray().filter(function (i) {
              return self.spuType[i.name] != i.value;
            }).map(function (i) {
              return [i.name, i.name === 'enabled'? i.value === 'true': i.value];
            })));
          } else {
            request('/spu/spu-type-list?name=' + this.name.value).done(function (res) {
              if (!res.body.data.length) {
                bus.trigger('spuType.create', _.object(self.$form.serializeArray().map(function (i) {
                  return [i.name, i.name === 'enabled'? i.value === 'true': i.value];
                })));
              } else {
                self.$form.form('add errors', ['名称已经存在'])
              }
            });
          }
        }
      };
      self.$form = $(self.root).find('form').form(formOpts).submit(function (e) {
        e.preventDefault();
        return false;
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
    }).on('spuType.created', function (item) {
      swal({
        type: 'success',
        title: '',
        text: 'spu分类创建成功，是否继续编辑?',
        showCancelButton: true,
      }, function (confirmed) {
        bus.trigger('go', confirmed? '/spu/spu-type/' + item.id: '/');
      });
    }).on('spuType.create.failed', function () {
      toastr.error('创建失败！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
    });
  </script>
</spu-type-app>

