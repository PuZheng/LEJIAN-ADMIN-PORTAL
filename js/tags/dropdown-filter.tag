// display dropdown as a filter, when an option is selected, an
// 'go' event with the updated url will be sent to bus
// opts:
//    name - see tag 'dropdown', this option should be decamelized, like "a_b"
//    value - see tag 'dropdown'
//    "default-text" - see tag 'dropdown'
//    items - see tag 'dropdown'
//    ctx - context provided by page.js
// example:
//    <dropdown-filter name="type" value="小说" defaultText="类型" items={ ['小说', '戏剧', '诗歌', '散文'] } ctx={ ctx }></dropdown-filter>


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
