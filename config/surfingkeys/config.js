settings.nexstLinkRegex = />|=>|->|>>|\b(next)\b|\b(more)\b|▶|Chap kế/i;

vmapkey("<Ctrl-[>", "Leave visual mode", function () {
  Visual.visualClear();
  Visual.exit();
});

vmapkey("<Shift-Enter>", "Open link in the new tab", function () {
  RUNTIME("openLink", {
    tab: { tabbed: true, active: false },
    url: document.getSelection().focusNode.parentNode.href,
  });
});

mapkey("gp", "Toggle pin tab", function () {
  RUNTIME("togglePinTab");
});

mapkey("i", "Passthrough mode", function () {
  PassThrough.enter();
});

mapkey(
  "sU",
  "#4Edit current URL with vim editor and open within the current tab",
  function () {
    Front.showEditor(
      window.location.href,
      function (data) {
        window.location.href = data;
      },
      "url"
    );
  }
);

addSearchAlias("y", "youtube", "https://www.youtube.com/search?q=");
addSearchAlias(
  "t",
  "translate",
  "https://translate.google.com/#view=home&op=translate&sl=auto&tl=vi&text="
);

mapkey("oy", "#8Open Search with alias y", function () {
  Front.openOmnibar({ type: "SearchEngine", extra: "y" });
});
