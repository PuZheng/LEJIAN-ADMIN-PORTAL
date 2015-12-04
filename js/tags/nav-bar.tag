var riot = require('riot');
var bus = require('riot-bus');
var page = require('page');

<nav-bar>
  <nav class="ui fixed menu inverted navbar">
    <a class="brand item" href="/">乐鉴</a>
    <div class="ui dropdown item" if={ opts.ctx.user }>
      <i class="dropdown icon"></i>
      SPU相关
      <div class="menu">
        <a class="item { opts.ctx.pathname === '/spu-type-list' && 'active' }" href="/spu-type-list">SPU类型管理</a>
        <a class="item { opts.ctx.pathname === '/spu-list' && 'active' }" href="/spu-list">SPU管理</a>
      </div>
    </div>
    <a class="ui item { opts.ctx.pathname === '/vendor-list' && 'active' }" if={ opts.ctx.user } href="/vendor-list">
      厂商管理
    </a>
    <div class="right menu" if={ opts.ctx.user }>
      <div class="ui dropdown item">
        <div class="fitted item">
          <i class="icon user"></i>
          <span class="ui teal tiny header">
            { opts.ctx.user.name || opts.ctx.user.email }
          </span>
        </div>
        <i class="dropdown icon"></i>
        <div class="menu">
          <a class="item" href="profile">
            <i class="icon edit"></i>
            用户信息
          </a>
          <a class="item" href="#" onclick={ logout }>
            <i class="icon sign out"></i>
            退出
          </a>
        </div>
      </div>
    </div>
  </nav>
  <style scoped>

    .ui.header {
      margin-top: 0;
    }
  </style>

  <script>
    var self = this;
    self.mixin(bus.Mixin);

    self.on('mount', function () {
      $(self.root).find('.ui.dropdown').dropdown({
        transition: 'drop'
      });
    }).on('user.updated', function (user) {
      _.assign(self.opts.ctx.user, user);
      self.update();
    });

    self.logout = function () {
      bus.trigger('logout');
    }
  </script>
</nav-bar>
