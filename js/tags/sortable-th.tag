// display th in a list, send 'go' event with updated url (which sort ths list by a certain column) to bus when clicked.
// opts:
//     label - text displayed in th
//     name - column name in url, like "id"
//     ctx - context provide by page.js
// example:
//     <th riot-tag="sortable-th" label="重量" name="weight" ctx={ ctx }></th>
// note:
//     to avoid the wrapping "sortable-th" element, you should use "th" element with riot-tag attribute set to "sortable-th"

var riot = require('riot');
var bus = require('riot-bus');
var buildQS = require('build-qs');


<sortable-th class={ class_ } onclick={ clickHandler }>
  <a href="#">{ opts.label }</a>
  <script>
    var self = this;
    self.class_ = 'sorted unordered';
    self.sortBy = {};
    self.on('update', function () {
      if (self.sortByString === opts.ctx.query.sortBy) {
        return;
      }
      self.sortByString = opts.ctx.query.sortBy;
      self.sortBy = function (sortBy) {
        sortBy = sortBy.split('.');
        return {
          name: sortBy[0],
          order: sortBy[1] || 'asc',
        }
      }(self.sortByString);

      if (self.sortBy.name === opts.name) {
        self.class_ = {
          desc: 'descending',
          asc: 'ascending',
        }[self.sortBy.order];
      } else {
        self.class_ = 'unordered';
      }
      self.class_ = 'sorted ' + self.class_;
    });
    self.clickHandler = function () {
      opts.ctx.query.sortBy = opts.name;
      if (self.sortBy.name === opts.name) {
          opts.ctx.query.sortBy += '.' + {
            'asc': 'desc',
            'desc': 'asc'
          }[self.sortBy.order];
      } else {
          opts.ctx.query.sortBy += '.asc';
      }
      bus.trigger('go', opts.ctx.pathname + '?' + buildQS(opts.ctx.query));
    }
  </script>
</sortable-th>
