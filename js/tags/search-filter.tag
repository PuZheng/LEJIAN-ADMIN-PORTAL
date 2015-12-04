// display a search as a filter, when select an option or perform submit, a
// 'go' event with updated url will be sent to bus
// opts:
//     placeholder - see tag 'search'
//     value - see tag 'search'
//     ctx - context provided by page.js
//     name - input name, used in updated url, like 'kw', note, it should be decamelized
//     backend - optional, where to load the auto complete hints, refer to semantic ui.
//     content - optional, local auto complete hints
// example:
//     <search-filter placeholder="请输入用户名" backend="/user/auto-complete/{query}" kw="user_name" ctx={ ctx } value={ ctx.query.userName }></search-filter>

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
      minCharacters: 2,
      onSelect: function (result) {
        var query = opts.ctx.query;
        var col = camelCase(opts.name);
        query[col] = result.title;
        bus.trigger('go', opts.ctx.pathname + '?' + buildQS(query));
      },
    };
    opts.backend && (self.options.apiSettings = {
      url: opts.backend,
    });
    opts.content && (self.options.content = opts.content);
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

