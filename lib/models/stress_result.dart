class StressResult {
  var scores; // String -> List<int>
  var summary;  // String
  var feedback; // String
  var date;
  var averageScore;
  var averageStressDescription;

  StressResult({this.scores, this.summary, this.feedback, this.date, this.averageScore, this.averageStressDescription});

  StressResult returnModel(Map dataMap) {
    try {
      List<int> scores = parseScores(dataMap['scores'] ?? "");
      double averageScore = parseAverageScore(scores);
      String averageStressDescription = getAverageStressDescription(averageScore);

      return StressResult(
        scores: scores,
          averageScore: averageScore,
          averageStressDescription: averageStressDescription,
        summary: dataMap['summary'] == null ? {} : parseSumFeed(dataMap['summary'] ?? ""),
        feedback: dataMap['feedback'] == null ? {} : parseSumFeed(dataMap['feedback'] ?? ""),
          date: dataMap['date'],
      );
    } catch(e) {
      print("error StressResult $e");
      return StressResult();
    }
  }

  double parseAverageScore(List<int> scores) {
    try {
      scores = scores.where((element) => element != 0).toList();
      double averageScore = scores.reduce((a, b) => a + b) / scores.length;
      return averageScore;
    } catch(e) {
      print('error parseAverageScore $e');
      return 0.0;
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

  String getAverageStressDescription(double average) {
    if (average >= 4.5) {
      return "매우 높음";
    } else if (average >= 3.5) {
      return "높음";
    } else if (average >= 2.5) {
      return "중간";
    } else if (average >= 1.5) {
      return "낮음";
    } else {
      return "매우 낮음";
    }
  }

}