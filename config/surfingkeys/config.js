// Theme {{{ //
settings.theme = `
.sk_theme {
    color: #fff;
}
.sk_theme tbody {
    color: #fff;
}
.sk_theme input {
    color: #d9dce0;
}
.sk_theme .url {
    color: #2173c5;
}
.sk_theme .annotation {
    color: #38f;
}
.sk_theme .omnibar_highlight {
    color: #fbd60a;
}
.sk_theme ul>li:nth-child(odd) {
    background: #1e211d;
}
.sk_theme ul>li.focused {
    background: #4ec10d;
}`;
// }}} Theme //

// Search {{{1 //
addSearchAlias("y", "youtube", "https://www.youtube.com/search?q=");

mapkey("oy", "#8Open Search with alias y", function() {
  Front.openOmnibar({ type: "SearchEngine", extra: "y" });
});

// }}}1

// Mapping {{{1
vmapkey("<Ctrl-[>", "Leave visual mode", function() {
  Visual.visualClear();
  Visual.exit();
});

mapkey("gp", "Toggle pin tab", function() {
  RUNTIME("togglePinTab");
});
// }}}1
