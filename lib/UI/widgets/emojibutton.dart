import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class EmojiButton extends StatefulWidget {
  final Function(String) onEmojiSelected;

  const EmojiButton({Key? key, required this.onEmojiSelected}) : super(key: key);

  @override
  _EmojiButtonState createState() => _EmojiButtonState();
}

class _EmojiButtonState extends State<EmojiButton> {
  bool _showPicker = false;

  void _toggleEmojiPicker() {
    setState(() {
      _showPicker = !_showPicker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(Icons.emoji_emotions),
          onPressed: _toggleEmojiPicker,
        ),
        if (_showPicker)
          SizedBox(
            height: 250,
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                widget.onEmojiSelected(emoji.emoji);
                _toggleEmojiPicker(); 
              },
            ),
          ),
      ],
    );
  }
}
