var riot = require('riot');
<paginator>
  <div class="ui inverted centered pagination menu">
    <a class="{ opts.pagination.hasPrev()? '': 'disabled' } icon item"
      href="{ opts.urlFor(opts.pagination.currentPage - 1) }" >
      <i class="left arrow icon"></i>
    </a>


    <raw each="{ page in opts.pagination.pages() }" url-for={ opts.urlFor } pagination={ opts.pagination }>
    <a href="{ opts.urlFor(page) }" class=" { page === opts.pagination.currentPage? 'disabled': ''} item" if={ page != null }>{ page }</a>
    <div class="disable item" if={ page === null }>...</div>
    </raw>

    <a href="{ opts.urlFor(opts.pagination.currentPage + 1) }" aria-label="Next"
      class="{ opts.pagination.hasNext()? '': 'disabled' } icon item">
      <i class="right arrow icon"></i>
    </a>
  </div>
</paginator>
