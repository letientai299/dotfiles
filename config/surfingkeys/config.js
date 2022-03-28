settings.nexstLinkRegex = />|=>|->|>>|\b(next)\b|\b(more)\b|▶|Chap kế/i;

api.mapkey("gp", "Toggle pin tab", function () {
  RUNTIME("togglePinTab");
});

api.mapkey("i", "Passthrough mode", function () {
  PassThrough.enter();
});

api.mapkey(
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

api.addSearchAlias("y", "youtube", "https://www.youtube.com/search?q=");
api.addSearchAlias(
  "t",
  "translate",
  "https://translate.google.com/#view=home&op=translate&sl=auto&tl=vi&text="
);

api.mapkey("oy", "#8Open Search with alias y", function () {
  Front.openOmnibar({ type: "SearchEngine", extra: "y" });
});
