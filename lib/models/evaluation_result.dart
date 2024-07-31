class EvaluationResult {
  var category;  // String
  var evaluation;  // String
  var details;  // String
  var isSuccess;  // 평가가 이뤄졌는지 여부

  EvaluationResult({
    this.category,
    this.evaluation,
    this.details,
    this.isSuccess,
  });

  List returnModels(String content) {
    try {
      List<EvaluationResult> results = [];
      // 주석 부분 추출
      int firstCategoryIndex = content.indexOf('[');
      String comment = content.substring(0, firstCategoryIndex).trim();
      String remainingContent = content.substring(firstCategoryIndex).trim();

      final RegExp regex = RegExp(
        r'\[([^\]]+)\]:\s*(.*?)\s*->\s*([^\n]+)\n(.*?)(?=\[|$)',
        dotAll: true,
      );
      final matches = regex.allMatches(remainingContent);

      for (var match in matches) {
        String category = match.group(1)!.trim();
        String evaluation = match.group(3)!.trim();
        String details = match.group(2)!.trim() + "\n" + match.group(4)!.trim();

        results.add(EvaluationResult(
          category: category,
          evaluation: evaluation,
          details: details,
          isSuccess: true,
        ));
      }

      // matches가 비어있는 경우, 평가 결과가 제대로 파싱되지 않았을 가능성이 있음
      if (results.isEmpty) {
        results.add(EvaluationResult(
          isSuccess: false,
          details: content,
          category: '',
          evaluation: '',
        ));
      }

      // for check data, test
      // print("comment : $comment");
      // for (EvaluationResult result in results) {
      //   print('category ${result.category}');
      //   print('evaluation ${result.evaluation}');
      //   print('details ${result.details}');
      // }

      return [comment, results];
    } catch(e) {
      print("EvaluationResult error : $e");
      return [];
    }
  }
}
