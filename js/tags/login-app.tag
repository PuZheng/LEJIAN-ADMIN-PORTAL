var riot = require('riot');
var loader = require('./loader.tag');
var bus = require('riot-bus');
var page = require('page');

<login-app>
  <div class="ui page grid">
    <loader if={ loading }></loader>
    <div class="row">
      <div class="six wide column centered">
        <div class="ui top attached blue message">
          <h3>登录</h3>
        </div>
        <div class="ui attached segment">
          <form class="ui form" action="#" method="POST">
            <div class="ui error message">
            </div>
            <div class="required field">
              <label for="">邮箱或用户名</label>
              <input type="text" name="email_or_name">
            </div>
            <div class="required field">
              <label>密码</label>
              <input type="password" name="password">
            </div>
            <div class="ui divider"></div>
            <div class="row">
              <div class="center aligned column">
                <input type="submit" value="登录" class="ui button">
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.on('mount', function () {
      $('form').form({
        fields: {
          email_or_name: {
            identifier: 'email_or_name',
            rules: [
              {
                type: 'empty',
                prompt: '请输入邮箱',
              }
            ],
          },
          password: {
            identifier: 'password',
            rules: [
              {
                type: 'empty',
                prompt: '请输入密码'
              }
            ],
          }
        },
        trigger: 'blur',
        onSuccess: function () {
          bus.trigger('login', self.email_or_name.value, self.password.value);
        },
        keyboardShortcuts: false
      }).on('submit', function () {
        return false;
      });
    }).on('login.start', function () {
      self.loading = true;
      self.update();
    }).on('login.failed', function (reason) {
      self.loading = false;
      self.update();
      if (!reason) {
        swal({
          type: 'error',
          title: '无法连接后台',
        });
        return;
      }
      typeof reason === 'string' && (reason = [reason]);
      $(self.root).find('form').form('add errors', reason);
    }).on('login.done', function (user) {
      bus.trigger('go', '/')
    });
  </script>
</login-app>
