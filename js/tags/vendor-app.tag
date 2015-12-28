var riot = require('riot');
var bus = require('riot-bus');
require('tags/vendor-form.tag');

<vendor-app>
  <div class="ui grid object-app">
    <div class="row">
      <div class="column">
        <div class="ui top attached blue message">
          <div class="ui header">
            <raw if={ opts.ctx.params.id }>
              厂商-<i>{ item.name }</i>
            </raw>
            <raw if={ !opts.ctx.params.id }>
              创建厂商
            </raw>
          </div>
          <i class="icon asterisk" if={ opts.ctx.params.id && editable }></i>
          <section class="ops">
            <a class="ui tiny circular icon green button" data-content="编辑对象" href={ opts.ctx.pathname + '?editable=1' } show={ opts.ctx.params.id && !editable }>
              <i class="icon edit"></i>
            </a>
            <a class="ui tiny circular icon button" data-content="锁定对象" href={ opts.ctx.pathname } show={ opts.ctx.params.id && editable }>
              <i class="icon lock"></i>
            </a>
          </section>
        </div>
        <div class="ui bottom attached segment">
          <vendor-form editable={ editable } ctx={P opts.ctx}></vendor-form>
        </div>
      </div>
    </div>
  </div>
  <script>
    var self = this;
    self.mixin(bus.Mixin);

    self.on('vendor.fetched', function (item) {
      self.item = item;
      self.update();
    }).on('update', function () {
      self.editable = !self.opts.ctx.params.id || self.opts.ctx.query.editable;
    })

  </script>
</vendor-app>
