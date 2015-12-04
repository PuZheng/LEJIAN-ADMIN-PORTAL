var riot = require('riot');
var bus = require('riot-bus');
var buildQS = require('build-qs');
var camelCase = require('camelcase');
require('tags/dropdown.tag');

<dropdown-filter>
  <div riot-tag="dropdown" name={ opts.name } value={ opts.value } default-text={ opts.defaultText } items={ opts.items } options={ options }></div>
  <script>
    var self = this;
    self.options =  {
      onChange: function (value, text, $choice) {
        if (!value) {
          $(this).dropdown('clear');
        }
        var query = opts.ctx.query;
        var col = camelCase(opts.name);
        if (value) {
          query[col] = value;
        } else {
          delete query[col];
        }
        bus.trigger('go', opts.ctx.pathname + '?' + buildQS(query));
      }
    }
  </script>
</dropdown-filter>
