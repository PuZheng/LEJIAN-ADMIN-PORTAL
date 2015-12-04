var riot = require('riot');

<checkbox class="ui checkbox">
  <input type="checkbox" name={ opts.name } checked={ opts.checked }>
  <label for="">{ opts.label }</label>
  <script>
    var self = this;
    self.on('mount', function () {
      if (!self.initialized) {
        $(self.root).checkbox(opts.options || {});
        self.initialized = true;
      }
    });
  </script>
</checkbox>
