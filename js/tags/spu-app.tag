var riot = require('riot');
var bus = require('riot-bus');

require('tags/spu-form.tag');

<spu-app>
  <div class="ui grid object-app">
    <div class="row">
      <div class="column">
        <div class="ui top attached blue message">
          <div class="ui header" if={ opts.ctx.params.id }>
            SPU-<i>{ item.name }</i>
          </div>
          <div class="ui header" if={ !opts.ctx.params.id }>
            创建SPU
          </div>
          <i class="icon asterisk" if={ opts.ctx.params.id && editable }></i>
          <button class="ui tiny circular icon green button" data-content="编辑对象" onclick={ onClickEdit } show={ opts.ctx.params.id && !editable }>
            <i class="icon edit"></i>
          </button>
          <button class="ui tiny circular icon button" data-content="锁定对象" onclick={ onCancelEdit } show={ opts.ctx.params.id && editable }>
            <i class="icon lock"></i>
          </button>
          <button class="ui tiny circular icon red button" data-content="删除对象" onclick={ onClickDelete } show={ opts.ctx.params.id }>
            <i class="icon trash"></i>
          </button>
        </div>
        <div class="ui bottom attached segment">
          <spu-form editable={ editable } ctx={ opts.ctx }></spu-form>
        </div>
      </div>
    </div>
  </div>
  <script>
    var self = this;
    self.mixin(bus.Mixin);

    self.editable = !opts.ctx.params.id;
    self.onClickEdit = function () {
      self.editable = true;
      self.update();
    };
    self.onCancelEdit = function () {
      self.editable = false;
      self.update();
    }

    self.on('mount', function () {
      $(self.root).find('[data-content]').popup();
    }).on('spu.fetched', function (item) {
      self.item = item;
      self.update();
    });
  </script>
</spu-app>
