import 'dart:async';
import 'package:coconut/products.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceOrderScreen extends StatefulWidget {
  @override
  _VoiceOrderScreenState createState() => _VoiceOrderScreenState();
}

class _VoiceOrderScreenState extends State<VoiceOrderScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Say something...";
  Timer? _timeoutTimer; // Timer for timeout
  final int _listeningTimeout = 10; // Timeout in seconds
  Product? _matchedProduct; // Store the matched product
  String? _errorMessage; // Store the error message

  List<Product> _products = [
    Product(id: 1, name: "Large Pizza", price: 12.99),
    Product(id: 2, name: "Pepperoni Pizza", price: 14.99),
    Product(id: 3, name: "Cheese burger", price: 8.99),
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _matchedProduct = null; // Reset the matched product
        _errorMessage = null; // Reset the error message
      });

      // Start the timeout timer
      _timeoutTimer = Timer(Duration(seconds: _listeningTimeout), _stopListening);

      _speech.listen(onResult: (result) {
        setState(() => _text = result.recognizedWords);
        _processVoiceCommand(_text);
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      if (_matchedProduct == null && _errorMessage == null) {
        _errorMessage = "No matching product found."; // Show error if no match
      }
      _text = "Say something..."; // Reset text
    });
    _timeoutTimer?.cancel(); // Cancel the timer if still running
  }

  // void _processVoiceCommand(String text) {
  //   // Normalize input text
  //   String normalizedText = text.toLowerCase();
  //
  //   // Find a matching product
  //   Product? matchedProduct = _products.firstWhere(
  //         (product) {
  //       // Convert product fields to strings and check if any field matches
  //       return product.name.toLowerCase().contains(normalizedText) ||
  //           product.price.toString().toLowerCase().contains(normalizedText);
  //     },
  //     orElse: () => Product(id: 0, name: "No Product", price: 0.0), // No match found
  //   );
  //
  //   // Update UI based on the result
  //   if (matchedProduct != null) {
  //     setState(() {
  //       _matchedProduct = matchedProduct; // Update matched product
  //       _errorMessage = null; // Clear error message
  //     });
  //     print("Order placed for: ${matchedProduct.name}");
  //     _stopListening();
  //   } else {
  //     setState(() {
  //       _errorMessage = "No matching product found."; // Set error message
  //       _matchedProduct = null; // Clear matched product
  //     });
  //     print("No matching product found.");
  //   }
  // }
  void _processVoiceCommand(String text) {
    // Normalize input text
    String normalizedText = text.toLowerCase();

    // Validate input
    if (normalizedText.trim().isEmpty) {
      setState(() {
        _errorMessage = "Please say something!";
        _matchedProduct = null;
      });
      return;
    }

    // Find a matching product
    Product? matchedProduct = _products.firstWhere(
          (product) {
        return product.name.toLowerCase().contains(normalizedText) ||
            product.price.toString().toLowerCase().contains(normalizedText);
      },
      orElse: () => Product(id: 0, name: "No Product", price: 0.0),
    );

    // Update UI based on the result
    if (matchedProduct != null) {
      setState(() {
        _matchedProduct = matchedProduct;
        _errorMessage = null; // Clear error message
      });
      print("Order placed for: ${matchedProduct.name}");
      _stopListening();
    } else {
      setState(() {
        _errorMessage = "No matching product found.";
        _matchedProduct = null;
      });
      print("No matching product found.");
    }
  }


  @override
  void dispose() {
    _speech.stop(); // Stop speech recognition when disposing
    _timeoutTimer?.cancel(); // Cancel the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice Order')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _text,
              style: TextStyle(fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            if (_matchedProduct != null) ...[
              SizedBox(height: 20),
              Text(
                "Matched Product:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "${_matchedProduct!.name} - \$${_matchedProduct!.price.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
            ],
            if (_errorMessage != null) ...[
              SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isListening ? null : _startListening,
              child: Text(_isListening ? "Listening..." : "Start Listening"),
            ),
          ],
        ),
      ),
    );
  }
}
