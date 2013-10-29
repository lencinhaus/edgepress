Package.describe({
    summary: "Bootstrap WYSIWYG"
});

Package.on_use(function (api, where) {
    api.use('jquery', 'client');
    api.use('bootstrap3-less', 'client');
    api.add_files('external/google-code-prettify/prettify.css', 'client');
    api.add_files('external/google-code-prettify/prettify.js', 'client');
    api.add_files('external/jquery.hotkeys.js', 'client');
    api.add_files('bootstrap-wysiwyg.js', 'client');
});
