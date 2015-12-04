var riot = require('riot');
var bus = require('riot-bus');
var buildQS = require('build-qs');
var camelCase = require('camelcase');
require('tags/checkbox.tag');

<checkbox-filter>
  <div riot-tag="checkbox" checked={ opts.checked }
    label={ opts.label } name='only_enabled' options={ options }>
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
