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
          <input type="number" name="rating" min=1 max=5 step=1 value={ item.rating } disabled={ !opts.editable }>
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
          <div riot-tag="gallery" max="1" editable={ opts.editable }></div>
          <input type="hidden" name="picPath" value={ item.picPath }>
        </div>
      </div>
      <div class="field">
        <label for="">选择坐标</label>
        <lnglat-input value={ [item.lng, item.lat] }></lnglat-input>
        <input type="hidden" name="lnglat" value={ [ item.lng, item.lat ] }>
      </div>
    </div>
    <hr>

    <input type="submit" value="提交" class="ui button primary">
  </form>
  <style scoped>
    textarea, [riot-tag="gallery"] {
      width: 70% !important;
    }
  </style>
  <script>
    var self = this;
    self.mixin(bus.Mixin);

    self.loading = 0;

    self.on('retailer.fetching', function () {
      ++self.loading;
      self.update();
    }).on('retailer.fetch.done', function () {
      --self.loading;
      self.update();
    });

    self.on('mount', function () {
      self.$form = $(self.root).find(form).submit(function () {
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
        }
      })
    }).on('retailer.fetched', function (item) {
      self.item = item;
      self.update();
      self.tags['gallery'].addImages([item.pic]);
    });
  </script>
</retailer-form>
