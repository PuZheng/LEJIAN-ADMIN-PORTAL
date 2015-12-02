var riot = require('riot');

<search class="ui search">
  <div class="ui icon input">
    <input class="prompt" type="text" placeholder={ opts.placeholder } value={ opts.value }>
    <i class="search icon"></i>
  </div>
  <div class="results"></div>

  <script>
    var self = this;
    self.on('mount', function () {
      $(self.root).search({
        apiSettings: {
          url: opts.backend,
        },
        minCharacters: 2,
        onSelect: opts.onSelect,
      });
      $(self.root).find('input').keyup(function (e) {
        if (e.keyCode === 13) {
          opts.onSubmit && opts.onSubmit.call(this, $(e.target).val());
        }
      });

    });
  </script>
</search>
