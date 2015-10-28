var riot = require('riot');
<paginator>
  <div class="ui basic center aligned segment" if={ opts.pagination }>
    <div class="ui centered pagination menu">
      <a class="{ opts.pagination.hasPrev? '': 'disabled' } icon item"
        href="{ opts.pagination.urlFor(pagination.page - 1) }" >
        <i class="left arrow icon"></i>
      </a>


      <raw each="{ page in opts.pagination.pages }" pagination={ opts.pagination }>
      <a href={ opts.urlFor(page) } class="{ page === opts.pagination.page && 'disabled' } item" if={ page != null }>{ page }</a>
      <div class="disable item" if={ page === null }>...</div>
      </raw>

      <a href="{ opts.pagination.urlFor(opts.pagination.page + 1) }" aria-label="Next"
        class="{ opts.pagination.hasNext? '': 'disabled' } icon item">
        <i class="right arrow icon"></i>
      </a>
    </div>
  </div>
</paginator>
