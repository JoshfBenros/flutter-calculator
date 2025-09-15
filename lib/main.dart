import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
  home: const MyHomePage(title: 'Lets Math Togehter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _expression = '';
  String _result = '';
  String _accumulator = '';

  final List<String> _buttons = [
  '7', '8', '9', '/',
  '4', '5', '6', '*',
  '1', '2', '3', '-',
  'C', '0', '=', '+',
  'x²',
  ];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '';
        _accumulator = '';
      } else if (value == 'x²') {
        // Square the current expression/result
        try {
          if (_expression.isEmpty) return;
          final exp = Expression.parse(_expression);
          final evaluator = const ExpressionEvaluator();
          final evalResult = evaluator.eval(exp, {});
          num? n;
          if (evalResult is int) {
            n = evalResult;
          } else if (evalResult is double) {
            if (evalResult.isInfinite || evalResult.isNaN) {
              n = null;
            } else {
              n = evalResult;
            }
          }
          if (n == null) {
            _result = 'Undefined';
            _accumulator = '($_expression)² = Undefined';
            _expression = '';
          } else {
            final squared = n * n;
            _result = squared.toString();
            _accumulator = '($_expression)² = $_result';
            _expression = _result;
          }
        } catch (e) {
          _result = 'Undefined';
          _accumulator = '($_expression)² = Undefined';
          _expression = '';
        }
      } else if (value == '=') {
        try {
          final exp = Expression.parse(_expression);
          final evaluator = const ExpressionEvaluator();
          final evalResult = evaluator.eval(exp, {});
          if (evalResult is double && (evalResult.isInfinite || evalResult.isNaN)) {
            _result = 'Undefined';
            _accumulator = '$_expression = Undefined';
            _expression = '';
          } else {
            _result = evalResult.toString();
            _accumulator = '$_expression = $_result';
            _expression = _result;
          }
        } catch (e) {
          _result = 'Undefined';
          _accumulator = '$_expression = Undefined';
          _expression = '';
        }
      } else {
        // Prevent two operators in a row
        if (_isOperator(value)) {
          if (_expression.isEmpty || _isOperator(_expression[_expression.length - 1])) {
            // Do not allow starting with operator or two in a row
            return;
          }
        }
        _expression += value;
        _accumulator = _expression;
      }
    });
  }

  bool _isOperator(String value) {
    return value == '+' || value == '-' || value == '*' || value == '/';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _accumulator.isEmpty ? '0' : _accumulator,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: _buttons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    final btn = _buttons[index];
                    Color btnColor = Colors.black;
                    Color textColor = Colors.white;
                    if (btn == 'C') {
                      btnColor = Colors.red[700]!;
                    } else if (btn == '=') {
                      btnColor = Colors.green[700]!;
                    } else if (_isOperator(btn) || btn == 'x²') {
                      btnColor = Colors.orange[700]!;
                    }
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnColor,
                        foregroundColor: textColor,
                        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.zero,
                        elevation: 2,
                      ),
                      onPressed: () => _onButtonPressed(btn),
                      child: Text(btn),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
