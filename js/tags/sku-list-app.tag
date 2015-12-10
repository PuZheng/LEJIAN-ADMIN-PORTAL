var riot = require('riot');
var bus = require('riot-bus');
var Pagination = require('pagination');

require('tags/sku-table.tag')
require('tags/paginator.tag');
require('tags/spu-filter.tag');

<sku-list-app>
  <div class="ui grid list">
    <div class="ui top attached blue message segment">
      <div class="ui header">
        SKU列表
      </div>
      <a class="ui tiny icon circular green button" href="/spu" data-content="创建SKU">
        <i class="icon plus"></i>
      </a>
      <a riot-tag="batch-delete-btn" ids={ tags['spu-table'].selected } data-content="删除SKU" event="spu.delete"></a>
    </div>
    <div class="ui attached segment filters">
    </div>
    <div class="ui bottom attached segment">
      <div class="ui grid">
        <div class="ui row">
          <div class="four wide column">
            <spu-filter ctx={ opts.ctx }></spu-filter>
          </div>
          <div class="twelve wide column" if={ !loading }>
            <sku-table ctx={ opts.ctx }></sku-table>
            <paginator pagination={ pagination } if={ pagination } ctx={ opts.ctx }></paginator>
          </div>
        </div>
      </div>
    </div>
  </div>

  <style scoped>
  </style>
  <script>
    var self = this;
    self.mixin(bus.Mixin);
    self.on('sku.list.fetched', function (data) {
      self.pagination = new Pagination({
        leftEdge: 3,
        rightEdge: 3,
        leftCurrent: 3,
        rightCurrent: 3,
        currentPage: self.opts.ctx.query.page || 1,
        perPage: self.opts.ctx.query.perPage || 12,
        totalCount: data.totalCnt,
      }).toJSON();
      self.update();
    });

  </script>
</sku-list-app>

