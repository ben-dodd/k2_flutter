import 'package:flutter/material.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/utils/flutter_typeahead.dart';

class CustomTypeAhead extends StatelessWidget {
  TextEditingController controller;
//  String initialValue;
  TextCapitalization capitalization;
  String label;
  String hint;
  bool enabled;
  FocusNode focusNode;
  FocusNode nextFocus;
  List suggestions;
  TextInputAction textInputAction;
  Function onSaved;
  Function validator;
  Function onSubmitted;
  Function onSuggestionSelected;

  /// Here is your constructor
  CustomTypeAhead({
    this.controller,
//    this.initialValue,
    this.focusNode,
    this.nextFocus,
    this.capitalization,
    this.enabled,
    this.textInputAction,
    this.label,
    this.hint,
    this.suggestions,
    this.onSaved,
    this.validator,
    this.onSubmitted,
    this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        textCapitalization: capitalization,
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        onChanged: (text) {
          onSaved(controller.text);
        },
        textInputAction: textInputAction,
        onSubmitted: (v) {
          onSaved(controller.text);
          nextFocus.hasListeners ? FocusScope.of(context).requestFocus(nextFocus) : null;
        },
        style: enabled ? new TextStyle(fontSize: 14.0) : new TextStyle(fontSize: 14.0, color: Colors.grey),
        cursorColor: CompanyColors.accent,
        cursorWidth: 1.0,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(labelText: label, hintText: hint, hintMaxLines: 10, hintStyle: new TextStyle(fontSize: 10.0)),
      ),
      suggestionsCallback: (pattern) {
        List itemList = suggestions
            .where((item) =>
                item['label'].toLowerCase().contains(pattern.toLowerCase()))
            .toList();
        return itemList;
//          return suggestions.where((item) => item['label'].toLowerCase().startsWith(pattern.toLowerCase())).toList();
      },
      getImmediateSuggestions: true,
//        initialValue: initialValue,
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion['label']),
          dense: true,
        );
      },
      onSuggestionSelected: onSuggestionSelected != null
          ? onSuggestionSelected
          : (suggestion) {
              controller.text = suggestion['label'];
              onSaved(controller.text);
              nextFocus.hasListeners ? FocusScope.of(context).requestFocus(nextFocus) : null;
            },
      transitionBuilder: (context, suggestionsBox, controller) {
        return suggestionsBox;
      },
      hideOnEmpty: true,
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
          elevation: 2.0, constraints: BoxConstraints(maxHeight: 400.0, minHeight: 400.0)),
      validator: validator,
      onSaved: onSaved,
    );
  }
}
