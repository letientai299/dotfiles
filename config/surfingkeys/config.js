settings.nexstLinkRegex = />|=>|->|>>|\b(next)\b|\b(more)\b|Chap kế/i;

// Vim ACE Editor Mappings{{{1

// Quickly exit insert mode
aceVimMap("jk", "<Esc>", "insert");
aceVimMap("kj", "<Esc>", "insert");

// Format paragraph
aceVimMap("gQ", "gqap", "insert");
// }}}1

vmapkey("<Ctrl-[>", "Leave visual mode", function() {
  Visual.visualClear();
  Visual.exit();
});

vmapkey("<Shift-Enter>", "Open link in the new tab", function() {
  RUNTIME("openLink", {
    tab: { tabbed: true, active: false },
    url: document.getSelection().focusNode.parentNode.href
  });
});

mapkey("gp", "Toggle pin tab", function() {
  RUNTIME("togglePinTab");
});

mapkey("i", "Passthrough mode", function() {
  PassThrough.enter();
});

mapkey(
  "sU",
  "#4Edit current URL with vim editor and open within the current tab",
  function() {
    Front.showEditor(
      window.location.href,
      function(data) {
        window.location.href = data;
      },
      "url"
    );
  }
);

// Search {{{1 //
addSearchAlias("y", "youtube", "https://www.youtube.com/search?q=");

mapkey("oy", "#8Open Search with alias y", function() {
  Front.openOmnibar({ type: "SearchEngine", extra: "y" });
});

// }}}1

// Theme {{{ //
settings.theme = `
.sk_theme {
    background-color: #000;
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
