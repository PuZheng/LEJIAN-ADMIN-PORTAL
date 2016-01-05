var riot = require('riot');
var bus = require('riot-bus');
require('tags/form-field.tag');
require('tags/loader.tag');
var swal = require('sweetalert/sweetalert.min.js');
var toastr = require('toastr/toastr.min.js');
require('toastr/toastr.min.css');
require('tags/gallery.tag');
require('tags/lnglat-input.tag');

<retailer-form>
  <form class="ui form" action="">
    <loader if={ loading }></loader>
    <div class="ui error message">
    </div>
    <div class="two fields">
      <div class="field">
        <div riot-tag="field" required="required" field="名称" prop="name"></div>
        <div class="inline field">
          <label for="">简介</label>
          <textarea name="desc" cols="30" rows="10" disabled={ !opts.editable }>{ item.desc }</textarea>
        </div>
        <div class="inline field">
          <label for="">评分(1-5)</label>
          <input type="number" name="rating" min=1 max=5 step=1 value={ item? item.rating: 1 } disabled={ !opts.editable }>
        </div>
        <div class="inline field">
          <div class="ui checkbox">
            <input type="checkbox" name="enabled" checked={ !item || item.enabled } disabled={ !opts.editable }>
            <label for="">是否激活</label>
          </div>
        </div>
        <div riot-tag="field" field="地址" prop="addr"></div>
        <div riot-tag="field" field="电话" prop="tel"></div>
        <div class="inline field">
          <label for="">外景图片</label>
          <div riot-tag="gallery" max="1" editable={ opts.editable } images={ [item.pic] }></div>
          <input type="hidden" name="picPath" value={ item.picPath }>
        </div>
      </div>
      <div class="field">
        <label for="">选择坐标</label>
        <div riot-tag="lnglat-input" value={ [item.lng, item.lat] } class="ui input" editable={ opts.editable }></div>
        <input type="hidden" name="lnglat" value={ [ item.lng, item.lat ] }>
      </div>
    </div>
    <hr>
    <input type="submit" value="提交" class="ui button primary" if={ opts.editable }>
  </form>
  <style scoped>
    textarea, [riot-tag="gallery"] {
      width: 70% !important;
    }
    [riot-tag="lnglat-input"] {
      width: 100%;
      height: 480px;
    }
  </style>
  <script>
    var self = this;
    self.mixin(bus.Mixin);

    self.loading = 0;

    self.on('retailer.fetching retailer.creating retailer.updating', function () {
      ++self.loading;
      self.update();
    }).on('retailer.fetch.done retailer.create.done retailer.update.done', function () {
      --self.loading;
      self.update();
    });

    self.on('mount', function () {
      self.$form = $(self.root).find('form').submit(function (e) {
        return false;
      }).form({
        fields: {
          name: {
            identifier: 'name',
            rules: [{
              type: 'empty',
              prompt: '名称不能为空',
            }]
          },
          lnglat: {
            identifier: 'lnglat',
            rules: [{
              type: 'empty',
              prompt: '经纬度不能为空',
            }]
          }
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
              bus.trigger('retailer.update', self.item, patch);
              // make a copy
              self.item = _.assign({}, self.item, patch);
              console.log(self.item);
              // update the input's value
              self.update();
            }
          } else {
            bus.trigger('retailer.create', self.formData());
          }
        },
      });
    }).on('retailer.fetched', function (item) {
      self.item = item;
      self.update();
      self.tags.gallery.addImages([item.pic]);
    }).on('retailer.created', function (item) {
      swal({
        type: 'success',
        title: '',
        text: '创建成功，是否继续编辑?',
        showCancelButton: true,
      }, function (confirmed) {
        self.item = item;
        bus.trigger('go', confirmed? '/retailer/' + item.id: '/retailer-list');
      });
    }).on('retailer.updated', function (item) {
      toastr.success('更新成功！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
      self.item = item;
      bus.trigger('go', opts.ctx.pathname);
    }).on('retailer.update.failed', function (err, origItem, patch) {
      self.item = origItem;
      toastr.error('更新失败！', '', {
        positionClass: 'toast-bottom-center',
        timeOut: 1000,
      });
      self.update();
    });
    self.tags.gallery.on('add', function (path) {
      $(self.picPath).val(path);
    }).on('remove', function (path) {
      $(self.picPath).val('');
    });
    self.tags['lnglat-input'].on('change', function (lnglat) {
      $(self.lnglat).val(lnglat);
    });
    self.formData = function () {
      return _.object(this.$form.serializeArray().map(function ({ name, value }) {
        return [name, name === 'lnglat'? value.split(','): value];
      }))
    };

    self.patch = function () {
      var data = self.formData();
      if (!self.item) {
        return data;
      }
      return _(data).pairs().filter(function ([k, v]) {
        if (k === 'lnglat') {
          return self.item.lng + ',' + self.item.lat != v.join(',');
        }
        return self.item[k] != v;
      }).object().value();
    };

    self.clear = function () {
      self.tags.gallery.clear();
    }
  </script>
</retailer-form>
