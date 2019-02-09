import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CustomTypeAhead extends StatelessWidget {
  TextEditingController controller;
  TextCapitalization capitalization;
  String label;
  List<String> suggestions;
  TextInputAction textInputAction;
  Function onSaved;
  Function validator;
  Function onSubmitted;


  /// Here is your constructor
  CustomTypeAhead({
    this.controller,
    this.capitalization,
    this.textInputAction,
    this.label,
    this.suggestions,
    this.onSaved,
    this.validator,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return
      TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          textCapitalization: capitalization,
          controller: controller,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
              labelText: label
          ),
        ),
        suggestionsCallback: (pattern) {
//                                List itemList = items.where((item) => item.toLowerCase().startsWith(pattern.toLowerCase())).toList();
//                                print (itemList.toString());
          return suggestions.where((item) => item.toLowerCase().startsWith(pattern.toLowerCase())).toList();
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion),
            dense: true,
          );
        },
        transitionBuilder: (context, suggestionsBox, controller) {
          return suggestionsBox;
        },
        hideOnEmpty: true,
        suggestionsBoxDecoration: SuggestionsBoxDecoration(
            elevation: 2.0,
            constraints: BoxConstraints(maxHeight: 400.0)
        ),
        onSuggestionSelected: (suggestion) {
          this.controller.text = suggestion;
        },
        validator: validator,
        onSaved: (string) {onSaved(string);},
      );
  }
}