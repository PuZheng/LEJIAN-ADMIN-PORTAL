// 批量删除对象按钮， 用于列表中
// opts:
//    ids - type: Set; list of ids of items to be deleted
//    event - the event triggered when performing delete


var riot = require('riot');
var bus = require('riot-bus');
var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');


<batch-delete-btn class="ui tiny icon circular red button" onclick={ handler }>
  <i class="icon trash"></i>
  <script>
    var self = this;
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
  </script>
</batch-delete-btn>
