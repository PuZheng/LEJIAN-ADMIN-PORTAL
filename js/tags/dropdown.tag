var riot = require('riot');

<dropdown class="ui selection dropdown">
  <input type="hidden" name={ opts.name } value={ opts.value }>
  <i class="dropdown icon"></i>
  <div class="default text">{ opts.defaultText }</div>
  <div class="menu">
    <div class="item" data-value="">-- 不限{ opts.defaultText } --</div>
    <div class="item" data-value={ Array.isArray(item)? item[0]: item } each={ item in opts.items }>{ Array.isArray(item)? item[1]: item }</div>
  </div>

  <script>
    var self = this;
    self.on('updated', function () {
      if (!_.isEmpty(opts.items) && !self.initialized) {
        $(self.root).dropdown({
          onChange: function (value, text, $choice) {
            if (!value) {
              $(this).dropdown('clear');
            }
            opts.onChange && opts.onChange.apply(this, arguments);
          }
        });
        self.initialized = true;
      }
    });
  </script>
</dropdown>
