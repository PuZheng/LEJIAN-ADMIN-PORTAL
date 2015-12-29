var riot = require('riot');
var bus = require('riot-bus');
var Pagination = require('pagination');
var uploadHelpHtml = require('raw!../../sku-upload-help.html');

require('tags/sku-table.tag')
require('tags/paginator.tag');
require('tags/spu-filter.tag');
require('tags/checkbox-filter.tag');
require('tags/loader.tag');

require('css/sku-list.css');

<sku-list-app>
  <div class="list-app">
    <loader if={ loading }></loader>
    <div class="ui top attached blue message segment">
      <div class="ui header">
        SKU列表
      </div>
      <a class="ui tiny icon circular green button" href="/sku" data-content="创建SKU">
        <i class="icon plus"></i>
      </a>
      <a riot-tag="batch-delete-btn" ids={ tags['sku-table'].selected } data-content="删除SKU" event="sku.delete" success-event="sku.deleted" ctx={ opts.ctx }></a>
      <a class="ui tiny icon circular button" href="#" data-html={ uploadHelpHtml }>
        <i class="icon upload"></i>
      </a>
      <div class="ui icon help"></div>
      <div riot-tag="checkbox-filter" label="仅展示未过期SKU" name="unexpired_only" ctx={ opts.ctx } checked_={ opts.ctx.query.unexpiredOnly === '1' }></div>
    </div>
    <div class="ui bottom attached segment">
      <aside riot-tag="spu-filter" ctx={ opts.ctx }></aside>
      <section>
        <div riot-tag="sku-table" ctx={ opts.ctx }></div>
        <paginator pagination={ pagination } if={ pagination } ctx={ opts.ctx }></paginator>
      </section>
    </div>
  </div>

  <style scoped>
    .ui.bottom.segment {
      min-height: 20rem;
    }
    .ui.bottom.segment:after {
      content: "";
      display: table;
      clear: both;
    }
    .ui.bottom.segment > * {
      float: left;
      padding-right: 1rem;
    }
    .ui.bottom.segment > *:last-child {
      padding-right: 0rem;
    }

    .ui.bottom.segment > section {
      width: 70%;
      text-align: center;
      position: relative;
      height: 100%;
    }

    .ui.bottom.segment section paginator {
      position: absolute;
      bottom: 10px;
      left: 50%;
      transform: translateX(-50%);
    }

    [riot-tag="sku-table"] {
      height: 100%;
      padding-bottom: 4rem;
    }

    [riot-tag="spu-filter"] {
      width: 30%;
      height: 100%;
    }
  </style>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.uploadHelpHtml = uploadHelpHtml;
    self.on('mount', function (data) {
      $(self.root).find('[data-content],[data-html]').popup();
    }).on('sku.deleting', function () {
      self.loading = true;
      self.update();
    }).on('sku.delete.done', function () {
      self.loading = false;
      self.update();
    }).on('sku.list.fetched', function (data) {
      self.pagination = new Pagination({
        leftEdge: 3,
        rightEdge: 3,
        leftCurrent: 3,
        rightCurrent: 3,
        currentPage: self.opts.ctx.query.page,
        perPage: self.opts.ctx.query.perPage,
        totalCount: data.totalCount,
      }).toJSON();
      self.update();
    }).on('spu.list.fetched', function (data) {
      var $bottom = $(self.root).find('.bottom.segment');
      $bottom.outerHeight($bottom.offsetParent().height() - $bottom.offset().top);
    });

  </script>
</sku-list-app>

