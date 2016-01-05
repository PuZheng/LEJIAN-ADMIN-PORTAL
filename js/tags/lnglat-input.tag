var riot = require('riot');
var $script = require('scriptjs');
var config = require('config');
var swal = require('sweetalert/sweetalert.min.js');

<lnglat-input>
  <div class="map"></div>
  <style scoped>
    .map {
      width: 100%;
      height: 100%;
    }
  </style>
  <script>
    var self = this;
    self.on('mount', function () {
      $script(['http://webapi.amap.com/maps?v=1.3&key=' + config.mapKey.api], function () {
        self.map = new AMap.Map($(self.root).find('.map')[0], {
          resizeEnable: true,
          zoom:11,
          center: opts.value,
        });

        self.map.plugin(["AMap.ToolBar", "AMap.OverView", "AMap.Scale"], function() {
          self.map.addControl(new AMap.ToolBar());
          self.map.addControl(new AMap.OverView({isOpen: true}));
          self.map.addControl(new AMap.Scale());
        });
        if (opts.value) {
            self.marker = new AMap.Marker({
                map: self.map,
                position: new AMap.LngLat(...opts.value),
                offset: new AMap.Pixel(-9, -31),
                icon: "http://webapi.amap.com/theme/v1.3/markers/n/mark_r.png",
            });
        }

        AMap.event.addListener(self.map, "click", function (e) {
          if (!self.opts.editable) {
            return false;
          }
          swal({
            type: 'warning',
            title: '警告',
            text: '你确认要修改经纬度?',
            showCancelButton: true,
          }, function (confirmed) {
            if (confirmed) {
              self.marker && self.marker.hide();
              self.marker = new AMap.Marker({
                map: self.map,
                position: new AMap.LngLat(e.lnglat.lng, e.lnglat.lat),
                offset: new AMap.Pixel(-9, -31),
                icon: "http://webapi.amap.com/theme/v1.3/markers/n/mark_r.png",
              });
              self.trigger('change', [e.lnglat.lng, e.lnglat.lat]);
            }
          });
        });
      });
    });
  </script>
</lnglat-input>

