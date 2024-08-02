class StressResult {
  var scores; // String -> List<int>
  var summary;  // String
  var feedback; // String

  StressResult({this.scores, this.summary, this.feedback});

  StressResult returnModel(Map dataMap) {
    try {
      return StressResult(
        scores: parseScores(dataMap['scores'] ?? ""),
        summary: dataMap['summary'],
        feedback: dataMap['feedback'],
      );
    } catch(e) {
      print("error StressResult $e");
      return StressResult();
    }
  }

  List<int> parseScores(String scores) {
    try {
      return scores.split(',').map((s) => int.parse(s.trim())).toList();
    } catch(e) {
      print('error parseScores $e');
      return [];
    }
  }
}