class SizeCalculate {
  // 웹 페이지의 경우 다양한 크기로 변경 가능하기 때문에 반응형으로 만들어 오류가 나지 않게 하기 위함입니다.
  double heightCalculate(screenHeight, height) {
    var ratio = height / screenHeight;

    return screenHeight * ratio;
  }

  // 웹 페이지의 경우 다양한 크기로 변경 가능하기 때문에 반응형으로 만들어 오류가 나지 않게 하기 위함입니다.
  double widthCalculate(screenWidth, width) {
    var ratio = width / screenWidth;

    return screenWidth * ratio;
  }

  plusIconSizeRatioChange({required beforeSize, required ratio}) {
    var size = beforeSize + beforeSize * ratio;

    return size;
  }

  minusIconSizeRatioChange({required beforeSize, required ratio}) {
    var size = beforeSize - beforeSize * ratio;

    return size;
  }
}