Package.describe({
  summary: 'Open source rich text editor based on HTML5 and the progressive-enhancement approach'
});

Package.on_use(function (api) {
  api.add_files('parser_rules/advanced.js', 'client', {bare: true});
  api.add_files('wysihtml5-0.3.0.js', 'client', {bare: true});

  if (typeof api.export !== 'undefined') {
    api.export(['wysihtml5', 'wysihtml5ParserRules'], 'client');
  }
});