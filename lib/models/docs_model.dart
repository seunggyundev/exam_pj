class DocsModel {
  var doc;
  var explain;
  var title;
  var key;

  DocsModel({this.key,  this.title, this.explain, this.doc});

  DocsModel returnModel(Map dataMap) {
    return DocsModel(
      doc: dataMap['doc'],
      explain: dataMap['explain'],
      title: dataMap['title'],
      key: dataMap['key'],
    );
  }
}