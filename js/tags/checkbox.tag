var riot = require('riot');

<checkbox class="ui checkbox">
  <input type="checkbox" name="" checked={ opts.checked }>
  <label for="">{ opts.label }</label>
  <script>
    var self = this;
    self.on('mount', function () {
      if (!self.initialized) {
        $(self.root).checkbox({
          onChange: opts.onChange,
        });
      }
    });
  </script>
</checkbox>
