var riot = require('riot');
var bus = require('riot-bus');
var config = require('config');
var urljoin = require('url-join');
var toastr = require('toastr/toastr.min.js');
var request = require('request');
require('toastr/toastr.min.css');
require('tags/centered-image.tag');
require('tags/gallery.tag');

<spu-form>
  <form class="ui form" action="">
    <loader if={ loading }></loader>
    <div class="ui error message">
    </div>
    <div class="required inline field">
      <label for="">名称</label>
      <input type="text" placeholder="输入名称..." name="name">
    </div>
    <div class="require inline field">
      <label for="">code</label>
      <input type="text" placeholder="输入code..." name="code">
    </div>
    <div class="inline field">
      <label for="">零售价</label>
      <input type="number" placeholder="输入零售价..." name="mrsp">
      <span>(元)</span>
    </div>
    <div class="inline field">
      <div class="ui checkbox">
        <label for="">是否激活</label>
        <input type="checkbox" name="enabled">
      </div>
    </div>
    <div class="inline field">
      <label for="">评分(1-5)</label>
      <input type="number" placeholder="输入评分" step="1" name="rating" min="1" max="5">
    </div>
    <div class="inline field">
      <label for="">描述</label>
      <textarea name="description" cols="30" rows="10"></textarea>
    </div>
    <div class="inline field">
      <label for="">所属分类</label>
      <div class="spu-type ui fluid search selection dropdown">
        <input type="hidden" name="country">
        <i class="dropdown icon"></i>
        <div class="default text">选择分类</div>
        <div class="menu">
          <div class="item" data-value={ id } each={ spuTypes }>{ name }</div>
        </div>
      </div>
    </div>
    <div class="inline field">
      <label for="">厂商</label>
      <div class="vendor ui fluid search selection dropdown">
        <input type="hidden" name="country">
        <i class="dropdown icon"></i>
        <div class="default text">选择厂商</div>
        <div class="menu">
          <div class="item" data-value={ id } each={ vendors }>{ name }</div>
        </div>
      </div>
    </div>
    <div class="inline field">
      <label for="">图片</label>
      <div riot-tag="gallery"></div>
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
    form .gallery {
      width: 60%!important;
    }
  </style>
  <script>
    var self = this;
    self.mixin(bus.Mixin);

    _.extend(self, {
      loading: 0,
    });
    self.on('mount', function () {
    }).on('spuType.list.fetching vendor.list.fetching', function () {
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
    }).on('spuType.list.fetch.done vendor.list.fetch.done', function () {
      --self.loading;
      self.update();
    });
  </script>
</spu-form>
