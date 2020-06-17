Package.describe({
  name: "elm-app",
  version: "1.0.0",
  summary: "elm app",
  documentation: "add your elm app into meteor",
});

Package.onUse(function (api) {
  api.versionsFrom("1.10.2");
  api.use("modules");
  api.addFiles("dist/elm-app.css", "client");
  api.mainModule("dist/elm-app.js", "client");
});
