var riot = require('riot');
<sortable-th class={ class_ }>
  <a href="#">{ opts.label }</a>
  <script>
    var self = this;
    self.on('update', function () {
      if (opts.sortBy) {
        if (opts.sortBy.name === opts.name) {
          self.class_ = {
            desc: 'descending',
            asc: 'ascending',
          }[opts.sortBy.order];
        } else {
          self.class_ = 'unordered';
        }
        self.class_ = 'sorted ' + self.class_;
      }
    })
  </script>
</sortable-th>
