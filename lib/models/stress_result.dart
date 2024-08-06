class StressResult {
  var scores; // String -> List<int>
  var summary;  // String
  var feedback; // String
  var date;

  StressResult({this.scores, this.summary, this.feedback, this.date});

  StressResult returnModel(Map dataMap) {
    try {
      return StressResult(
        scores: parseScores(dataMap['scores'] ?? ""),
        summary: dataMap['summary'] == null ? {} : parseSumFeed(dataMap['summary'] ?? ""),
        feedback: dataMap['feedback'] == null ? {} : parseSumFeed(dataMap['feedback'] ?? ""),
          date: dataMap['date'],
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

  Map<String, Map<String, String>> parseSumFeed(String data) {
    Map<String, Map<String, String>> categorizedMap = {
      'cause': {},
      'symptom': {},
      'coping': {},
    };

    List<String> lines = data.split('\n');
    int categoryIndex = 0;
    List<String> categories = ['cause', 'symptom', 'coping'];

    for (String line in lines) {
      if (line.trim().isEmpty) {
        continue;
      }

      int colonIndex = line.indexOf(':');
      if (colonIndex == -1) {
        continue;
      }

      String category = line.substring(0, colonIndex).trim();
      String content = line.substring(colonIndex + 1).trim();

      if (categoryIndex < categories.length) {
        categorizedMap[categories[categoryIndex]]![category] = content;
        categoryIndex++;
      }
    }

    return categorizedMap;
  }

}