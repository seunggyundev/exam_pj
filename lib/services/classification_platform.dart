import 'package:devjang_cs/services/responsive.dart';
import 'package:flutter/material.dart';
// 화면 사이즈, 기기정보를 통해 플랫폼을 구별하기 위함
class ClassificationPlatform {

  bool isNotMobile({required context,}) {
    if (Responsive.isMobile(context)) {
      return false;
    } else if (Responsive.isTablet(context)) {
      return true;
    } else {
      return true;
    }
  }

  classifyWithScreenSize({required context, criteriaSize = 1300, tabletCriteriaSize = 630,}) {
    final double screenWidthSize = MediaQuery.of(context).size.width;

    if (screenWidthSize > criteriaSize) {
      // web
      return 2;
    } else if(screenWidthSize < criteriaSize && screenWidthSize > tabletCriteriaSize) {
      // tablet
      return 1;
    } else {
      // mobile
      return 0;
    }
  }

  int classifyWithDevice({required context,}) {
    if (Responsive.isMobile(context)) {
      return 0;
    } else if (Responsive.isTablet(context)) {
      return 1;
    } else {
      return 2;
    }
  }

}