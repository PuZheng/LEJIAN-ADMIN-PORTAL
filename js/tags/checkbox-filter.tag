// display checkbox as a list filter, when checked/unchecked, will
// send "go" event with the updated path to bus
// opts:
//     checked_ - see tag 'checkbox', note not "checked", since it will be converted to '__checked' by riotjs.
//     label - see tag 'checkbox'
//     name - see tag 'checkbox', note, it should be decamelized, like "a_b"
//     ctx - context provided by page.js
// Example:
//     <checkbox-filter checked="checked" label="只看未读邮件" name="only_unread" ctx={ ctx }></checkbox-filter>

var riot = require('riot');
var bus = require('riot-bus');
var buildQS = require('build-qs');
var camelCase = require('camelcase');
require('tags/checkbox.tag');

<checkbox-filter>
  <div riot-tag="checkbox" checked_={ opts.checked_ }
    label={ opts.label } name={ opts.name } options={ options }>
  </div>
  <script>
    self.options = {
      onChange: function () {
        var checked = $(this).is(':checked');
        var query = opts.ctx.query;
        var col = camelCase(opts.name);
        if (checked) {
          query[col] = 1;
        } else {
          delete query[col];
        }
        bus.trigger('go', opts.ctx.pathname + '?' + buildQS(query));
      }
    }
  </script>
</checkbox-filter>
