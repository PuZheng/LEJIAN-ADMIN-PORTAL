var riot = require('riot');
var bus = require('riot-bus');
var buildQS = require('build-qs');

<paginator>
  <div class="ui inverted centered pagination menu">
    <a class="{ opts.pagination.hasPrev? '': 'disabled' } icon item"
      href="{ urlFor(opts.pagination.currentPage - 1) }" >
      <i class="left arrow icon"></i>
    </a>


    <raw each={ page in opts.pagination.pages } pagination={ opts.pagination }>
      <a href="{ parent.urlFor(page) }" class=" { page === opts.pagination.currentPage? 'disabled': ''} item" if={ page }>{ page }</a>
      <div class="disable item" if={ !page }>...</div>
    </raw>

    <a href="{ urlFor(opts.pagination.currentPage + 1) }" aria-label="Next"
      class="{ opts.pagination.hasNext? '': 'disabled' } icon item">
      <i class="right arrow icon"></i>
    </a>
  </div>
  <script>
    this.urlFor = function (page) {
      var query = _.assign({}, opts.ctx.query);
      query.page = page;
      return opts.ctx.pathname + '?' + buildQS(query);
    };
  </script>
</paginator>
