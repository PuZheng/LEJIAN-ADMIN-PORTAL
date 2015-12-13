// 批量删除对象按钮， 用于列表中
// opts:
//    ids - type: Set; list of ids of items to be deleted, if you want to use your own handler, ignore this
//    event - optinal, the event triggered when performing delete, if you want to use your own handler, ignore this
//    handler - optional, click event handler
//    ctx
//    success-event


var riot = require('riot');
var bus = require('riot-bus');
var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');


<batch-delete-btn class="ui tiny icon circular red button" onclick={ opts.handler || handler }>
  <i class="icon trash"></i>
  <script>
    var self = this;
    self.mixin(bus.Mixin);

    self.handler = function () {
      var selected = Array.from(opts.ids);
      if (!selected.length) {
        swal({
          type: 'info',
          title: '',
          text: '请至少选择一个对象',
        });
      } else {
        swal({
          type: 'warning',
          title: '',
          text: '您确认要删除选中的对象?',
          showCancelButton: true,
          closeOnConfirm: false,
        }, function (confirmed) {
          if (confirmed) {
            bus.trigger(opts.event, selected);
          }
        });
      }
    }
    opts.successEvent && self.on(opts.successEvent, function () {
      swal({
        type: 'success',
        title: '',
        text: '删除成功!'
      }, function () {
        bus.trigger('go', opts.ctx.path);
      });
    });
  </script>
</batch-delete-btn>
