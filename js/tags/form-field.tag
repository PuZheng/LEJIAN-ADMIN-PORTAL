var riot = require('riot');

<field class="inline field { opts.required && 'required' }">
  <label for="">{ opts.field }</label>
  <input type={ opts.type || 'text' } placeholder="输入{ opts.field }..." value={ opts.value || parent.item[opts.prop] } disabled={ !parent.opts.editable } name={ opts.prop }>
</field>
