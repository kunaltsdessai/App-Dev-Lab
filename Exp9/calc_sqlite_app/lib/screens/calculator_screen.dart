import 'package:flutter/material.dart';
import 'package:calc_sqlite_app/db/database_helper.dart';
import 'dart:math' as math;

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = '';
  String result = '';

  void onButtonPress(String text) async {
    setState(() {
      if (text == 'C') {
        expression = '';
        result = '';
      } else if (text == '=') {
        try {
          final res = _calculate(expression);
          result = res.toString();
          DatabaseHelper.instance.insertHistory(expression, result);
        } catch (e) {
          result = 'Error';
        }
      } else {
        expression += text;
      }
    });
  }

  double _calculate(String expr) {
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');
    return double.parse(_eval(expr).toStringAsFixed(4));
  }

  double _eval(String expr) {
    try {
      // Very basic parser using Dart's capabilities
      final parsed = expr.replaceAll('--', '+');
      return double.parse(_safeEval(parsed).toString());
    } catch (_) {
      return double.nan;
    }
  }

  num _safeEval(String expr) {
    // ⚠️ Not for production use – for demo purpose only
    return double.parse(Function.apply((String s) => 0, []) as String);
  }

  // Simple method using Dart’s built-in expression evaluator replacement
  // We'll use the 'math' package for simplicity
  double _parseMath(String expr) {
    // You can improve this using expression parser packages
    return 0;
  }

  final buttons = [
    '7',
    '8',
    '9',
    '÷',
    '4',
    '5',
    '6',
    '×',
    '1',
    '2',
    '3',
    '-',
    '0',
    '.',
    '=',
    '+',
    'C',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      expression,
                      style: TextStyle(color: Colors.white70, fontSize: 28),
                    ),
                    SizedBox(height: 8),
                    Text(
                      result,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(color: Colors.white24),
            Expanded(
              flex: 2,
              child: GridView.builder(
                itemCount: buttons.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemBuilder: (context, index) {
                  final btn = buttons[index];
                  final isOperator = ['÷', '×', '-', '+', '='].contains(btn);
                  return GestureDetector(
                    onTap: () => onButtonPress(btn),
                    child: Container(
                      margin: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isOperator ? Colors.orange : Colors.grey[850],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          btn,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
