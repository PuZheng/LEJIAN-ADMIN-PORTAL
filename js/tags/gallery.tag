var riot = require('riot');
var bus = require('riot-bus');

<gallery>
  <div class="ui small images">
    <div class="ui circular huge green icon file button">
      <i class="icon upload"></i>
      <input type="file">
    </div>
    <img src={ link } alt="" each={ link in images }>
  </div>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.images = [];
    self.on('mount', function () {
      self.$fileInput = $(self.root).find('[type=file]');
      self.$fileInput.change(function (e) {
        var file = e.currentTarget.files[0];
        var fr = new FileReader();
        fr.onload = function (e) {
          var data = e.target.result;
          self.images.push(data);
          self.update();
        };
        fr.readAsDataURL(file);
        //bus.trigger('asset.upload', file);
      });
    });
  </script>
</gallery>
