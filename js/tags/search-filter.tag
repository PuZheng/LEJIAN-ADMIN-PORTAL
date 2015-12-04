var riot = require('riot');
var bus = require('riot-bus');
var camelCase = require('camelcase');
var buildQS = require('build-qs');
require('tags/search.tag');

<search-filter>
  <div riot-tag="search" opts={ value.placeholder } value={ opts.value } options={ options } on-submit={ onSubmit }></div>

  <script>
    var self = this;
    self.options = {
      apiSettings: {
        url: opts.backend,
      },
      minCharacters: 2,
      onSelect: function (result) {
        var query = opts.ctx.query;
        var col = camelCase(opts.name);
        query[col] = result.title;
        bus.trigger('go', opts.ctx.pathname + '?' + buildQS(query));
      },
    }
    self.onSubmit = function (kw) {
      var query = opts.ctx.query;
      var col = camelCase(opts.name);
      if (kw) {
        query[col] = kw;
      } else {
        delete query[col];
      }
      bus.trigger('go', opts.ctx.pathname + '?' + buildQS(query));
    };

  </script>
</search-filter>

