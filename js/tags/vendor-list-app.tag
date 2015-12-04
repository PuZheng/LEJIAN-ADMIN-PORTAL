var riot = require('riot');
var bus = require('riot-bus');
require('tags/batch-delete-btn.tag');
require('tags/checkbox-filter.tag');
require('tags/vendor-table.tag');

<vendor-list-app>
  <div class="ui grid list">
    <div class="ui top attached info message segment">
      <div class="ui header">
        厂商列表
      </div>
      <a class="ui tiny icon green circular button" href="/vendor" data-content="创建厂商">
        <i class="icon plus"></i>
      </a>
      <a riot-tag="batch-delete-btn" data-content="删除SPU分类"></a>
    </div>
    <div class="ui attached segment filters">
      <div class="ui search">
        <div class="ui icon input">
          <input class="prompt" type="text" placeholder="输入名称" name="search" onkeyup={ doSearch } value={ opts.ctx.query.kw }>
          <i class="search icon"></i>
        </div>
        <div class="results"></div>
      </div>
      <div riot-tag="checkbox-filter" checked={ opts.ctx.onlyEnabled === '1' } label="仅展示激活" name="only_enabled" ctx={ opts.ctx }></div>
    </div>
    <div class="ui bottom attached segment">
      <vendor-table></vendor-table>
    </div>
  </div>
  <script>
  </script>
</vendor-list-app>
