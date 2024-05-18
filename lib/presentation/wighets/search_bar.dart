import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SearchBarWidget extends HookWidget {
  const SearchBarWidget({
    super.key,
    required this.hintText,
    required this.controller,
    this.onSubmitted,
    this.focusNode,
    this.onSuffixIconPusshed,
  });
  final String hintText;
  final TextEditingController controller;
  final void Function(String)? onSubmitted;
  final void Function()? onSuffixIconPusshed;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final isEmpty = useState(controller.text.isEmpty);
    useEffect(
      () {
        void listener() {
          isEmpty.value = controller.text.isEmpty;
        }

        controller.addListener(listener);
        return () {
          controller.removeListener(listener);
        };
      },
      [controller],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: TextField(
        onSubmitted: onSubmitted,
        focusNode: focusNode,
        controller: controller,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          prefixIcon: const Icon(Icons.search),
          fillColor: Theme.of(context).hoverColor,
          filled: true,
          // border: InputBorder.none,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          hintText: hintText,
          suffixIcon: !isEmpty.value
              ? IconButton(
                  onPressed: () {
                    controller.clear();
                    if (onSuffixIconPusshed != null) {
                      onSuffixIconPusshed!();
                    }
                  }, //リセット処理
                  icon: const Icon(Icons.clear),
                )
              : null,
        ),
      ),
    );
  }
}
