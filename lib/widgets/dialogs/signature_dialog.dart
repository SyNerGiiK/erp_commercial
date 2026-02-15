import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../config/theme.dart';

class SignatureDialog extends StatefulWidget {
  const SignatureDialog({super.key});

  @override
  State<SignatureDialog> createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<SignatureDialog> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _exportSignature() async {
    if (_controller.isNotEmpty) {
      final Uint8List? data = await _controller.toPngBytes();
      if (data != null && mounted) {
        Navigator.pop(context, data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Signature"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 305, // Fixed width (300 + borders/padding)
            height: 205, // Fixed height
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
            child: ClipRect(
              child: Signature(
                controller: _controller,
                width: 300,
                height: 200,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Signez dans le cadre ci-dessus",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _controller.clear();
          },
          child: const Text("Effacer", style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: _exportSignature,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          child: const Text("Valider", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
