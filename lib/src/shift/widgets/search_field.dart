import 'package:flutter/material.dart';
import 'package:yodel/src/theme/themes.dart';

class SearchField extends StatefulWidget {
  final Function(String query) onQueryChanged;
  final VoidCallback onClear;
  final TextEditingController controller;
  final String hintText;
  final bool autofocus;
  final FocusNode focusNode;
  final bool hasBorder;

  SearchField({
    Key key,
    @required this.onQueryChanged,
    this.onClear,
    TextEditingController controller,
    this.hintText = "Search",
    this.autofocus = false,
    this.focusNode,
    this.hasBorder = true,
  })  : controller = controller ??= TextEditingController(),
        super(key: key);

  @override
  _SearchFieldState createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  bool hasText = false;

  @override
  void initState() {
    hasText =
        widget.controller.text != null && widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onInputChanged);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onInputChanged);
    super.dispose();
  }

  void _onInputChanged() {
    setState(() {
      hasText = _hasText;
    });
  }

  bool get _hasText =>
      widget.controller.text != null && widget.controller.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        TextField(
          focusNode: widget.focusNode,
          onChanged: widget.onQueryChanged,
          controller: widget.controller,
          autocorrect: false,
          autofocus: widget.autofocus,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                  left: 11.0, top: 14.0, bottom: 14.0, right: 11.0),
              hintText: widget.hintText,
              fillColor: YodelTheme.paleGrey,
              filled: true,
              prefixIcon: Icon(
                Icons.search,
              ),
              border: widget.hasBorder ?
                  OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    )  : null,),
        ),
        hasText
            ? Positioned(
                right: 1,
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: IconButton(
                    iconSize: 20,
                    color: Colors.black,
                    onPressed: () {
                      widget.controller?.clear();
                      if (widget.onClear != null) {
                        widget.onClear();
                      }
                    },
                    icon: Icon(Icons.close),
                  ),
                ),
              )
            : Container()
      ],
    );
  }
}
