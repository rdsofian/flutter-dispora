
import 'package:division/division.dart';
import 'package:flutter/material.dart';

import 'package:dispora/styles/styles.dart';

class DashboardBox extends StatelessWidget {
  final String url;
  
  const DashboardBox(this.url, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Parent(
      style: parentStyle.clone()..background.image(url: url, fit: BoxFit.cover),
    );
  }
}
