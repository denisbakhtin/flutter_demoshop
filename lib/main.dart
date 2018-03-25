// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'shrine/shrine_home.dart';
import 'shrine/shrine_utils.dart';

class ShrineDemo extends StatelessWidget {
  ShrineDemo();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: buildShrine(context, new ShrineHomeWrapper()),
    );
  }
}

void main() {
  runApp(new ShrineDemo());
}
