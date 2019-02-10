import 'package:flutter/material.dart';
import 'package:k2e/utils/flutter_typeahead.dart';

class CustomTypeAhead extends StatelessWidget {
  TextEditingController controller;
//  String initialValue;
  TextCapitalization capitalization;
  String label;
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
    this.textInputAction,
    this.label,
    this.suggestions,
    this.onSaved,
    this.validator,
    this.onSubmitted,
    this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return
      TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          textCapitalization: capitalization,
          controller: controller,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onSubmitted: (v) {
            nextFocus != null ? FocusScope.of(context).requestFocus(nextFocus) : null;
          },
          decoration: InputDecoration(
              labelText: label
          ),
        ),
        suggestionsCallback: (pattern) {
            List itemList = suggestions.where((item) => item['label'].toLowerCase().startsWith(pattern.toLowerCase())).toList();
            print (itemList.toString());
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
        onSuggestionSelected:  onSuggestionSelected != null ? onSuggestionSelected : (suggestion) {
          controller.text = suggestion['label'];
          nextFocus != null ? FocusScope.of(context).requestFocus(nextFocus) : null;
        },
        transitionBuilder: (context, suggestionsBox, controller) {
          return suggestionsBox;
        },
        hideOnEmpty: true,
        suggestionsBoxDecoration: SuggestionsBoxDecoration(
            elevation: 2.0,
            constraints: BoxConstraints(maxHeight: 400.0)
        ),
        validator: validator,
        onSaved: onSaved,
      );
  }
}