library autocomplete_textfield;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef Widget AutoCompleteOverlayItemBuilder<T>(
    BuildContext context, T suggestion);

typedef bool Filter<T>(T suggestion, String query);

typedef InputEventCallback<T>(T data);

typedef StringCallback(String data);

class AutoCompleteTextField<T> extends StatefulWidget {
  List<T> suggestions;
  Filter<T> itemFilter;
  Comparator<T> itemSorter;
  StringCallback textChanged, textSubmitted;
  InputEventCallback<T> itemSubmitted;
  AutoCompleteOverlayItemBuilder<T> itemBuilder;
  int suggestionsAmount;
  GlobalKey<AutoCompleteTextFieldState<T>> key;
  bool submitOnSuggestionTap, clearOnSubmit;
  List<TextInputFormatter> inputFormatters;

  InputDecoration decoration;
  TextStyle style;
  TextInputType keyboardType;
  TextInputAction textInputAction;
  TextCapitalization textCapitalization;
  String initialValue;
  TextEditingController controller;
  ScrollController scrollController;

  AutoCompleteTextField({
    this.itemSubmitted, //Callback on item selected, this is the item selected of type <T>
    @required
        this.key, //GlobalKey used to enable addSuggestion etc
    @required
        this.suggestions, //Suggestions that will be displayed
    @required
        this.itemBuilder, //Callback to build each item, return a Widget
    @required
        this.itemSorter, //Callback to sort items in the form (a of type <T>, b of type <T>)
    @required
        this.itemFilter, //Callback to filter item: return true or false depending on input text
    this.inputFormatters,
    this.style,
    this.decoration: const InputDecoration(),
    this.textChanged,
    @required //Callback on input text changed, this is a string
        this.textSubmitted, //Callback on input text submitted, this is also a string
    this.keyboardType: TextInputType.text,
    this.suggestionsAmount:
        5, //The amount of suggestions to show, larger values may result in them going off screen
    this.submitOnSuggestionTap:
        true, //Call textSubmitted on suggestion tap, itemSubmitted will be called no matter what
    this.clearOnSubmit: false, //Clear autoCompleteTextfield on submit
    this.textInputAction: TextInputAction.done,
    this.textCapitalization: TextCapitalization.sentences,
    this.initialValue,
    this.scrollController,
  }) : super(key: key);

  void clear() {
    key.currentState.clear();
  }

  void addSuggestion(T suggestion) {
    key.currentState.addSuggestion(suggestion);
  }

  void removeSuggestion(T suggestion) {
    key.currentState.removeSuggestion(suggestion);
  }

  void updateSuggestions(List<T> suggestions) {
    key.currentState.updateSuggestions(suggestions);
  }

  TextField get textField => key.currentState.textField;

  @override
  State<StatefulWidget> createState() => new AutoCompleteTextFieldState<T>(
        initialValue,
        suggestions,
        textChanged,
        textSubmitted,
        itemSubmitted,
        itemBuilder,
        itemSorter,
        itemFilter,
        suggestionsAmount,
        submitOnSuggestionTap,
        clearOnSubmit,
        scrollController,
        inputFormatters,
        textCapitalization,
        decoration,
        style,
        keyboardType,
        textInputAction,
      );
}

class AutoCompleteTextFieldState<T> extends State<AutoCompleteTextField> {
  TextField textField;
  List<T> suggestions;
  StringCallback textChanged, textSubmitted;
  InputEventCallback<T> itemSubmitted;
  AutoCompleteOverlayItemBuilder<T> itemBuilder;
  Comparator<T> itemSorter;
  OverlayEntry listSuggestionsEntry;
  List<T> filteredSuggestions;
  Filter<T> itemFilter;
  int suggestionsAmount;
  bool submitOnSuggestionTap, clearOnSubmit;
  TextEditingController controller;
  ScrollController scrollController;
  String initialValue;
  RelativeRect position;

  String currentText = "";

  @override
  void initState() {
    super.initState();
    initialValue = widget.initialValue;
  }

  AutoCompleteTextFieldState(
      this.initialValue,
      this.suggestions,
      this.textChanged,
      this.textSubmitted,
      this.itemSubmitted,
      this.itemBuilder,
      this.itemSorter,
      this.itemFilter,
      this.suggestionsAmount,
      this.submitOnSuggestionTap,
      this.clearOnSubmit,
      this.scrollController,
      List<TextInputFormatter> inputFormatters,
      TextCapitalization textCapitalization,
      InputDecoration decoration,
      TextStyle style,
      TextInputType keyboardType,
      TextInputAction textInputAction) {
    textField = new TextField(
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      decoration: decoration,
      style: style,
      keyboardType: keyboardType,
      focusNode: new FocusNode(),
      controller: new TextEditingController(text: this.initialValue),
      textInputAction: textInputAction,
      onChanged: (newText) {
        currentText = newText;
        updateOverlay(newText);

        if (textChanged != null) {
          textChanged(newText);
        }
      },
      onSubmitted: (submittedText) {
        if (clearOnSubmit) {
          clear();
        }

        if (textSubmitted != null) {
          textSubmitted(submittedText);
        }
      },
    );

    textField.focusNode.addListener(() {
      if (!textField.focusNode.hasFocus) {
        filteredSuggestions = [];
      }
    });

    // TODO make overlay scroll with textfield
  }

  void clear() {
    textField.controller.clear();
    updateOverlay("");
  }

  void addSuggestion(T suggestion) {
    suggestions.add(suggestion);
    updateOverlay(currentText);
  }

  void removeSuggestion(T suggestion) {
    suggestions.contains(suggestion)
        ? suggestions.remove(suggestion)
        : throw "List does not contain suggestion and therefore cannot be removed";
    updateOverlay(currentText);
  }

  void updateSuggestions(List<T> suggestions) {
    this.suggestions = suggestions;
  }

  void updateOverlay(String query) {
    if (listSuggestionsEntry == null) {
      final RenderBox textFieldRenderBox = context.findRenderObject();
      final RenderBox overlay = Overlay.of(context).context.findRenderObject();
      final width = textFieldRenderBox.size.width;
      position = new RelativeRect.fromRect(
        new Rect.fromPoints(
          textFieldRenderBox.localToGlobal(
              textFieldRenderBox.size.bottomLeft(Offset.zero),
              ancestor: overlay),
          textFieldRenderBox.localToGlobal(
              textFieldRenderBox.size.bottomRight(Offset.zero),
              ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      );

      listSuggestionsEntry = new OverlayEntry(builder: (context) {
        print(position.toString());
        return new Positioned(
            top: position.top,
            left: position.left,
            child: new Container(
                width: width,
                child: new Card(
                    child: new Column(
                  children: filteredSuggestions.map((suggestion) {
                    return new Row(children: [
                      new Expanded(
                          child: new InkWell(
                              child: itemBuilder(context, suggestion),
                              onTap: () {
                                setState(() {
                                  if (submitOnSuggestionTap) {
                                    String newText = suggestion.toString();
                                    textField.controller.text = newText;
                                    textField.focusNode.unfocus();
                                    itemSubmitted(suggestion);
                                    if (clearOnSubmit) {
                                      clear();
                                    }
                                  } else {
                                    String newText = suggestion.toString();
                                    textField.controller.text = newText;
                                    textChanged(newText);
                                  }
                                });
                              }))
                    ]);
                  }).toList(),
                ))));
      });
      Overlay.of(context).insert(listSuggestionsEntry);
    }

    filteredSuggestions = getSuggestions(
        suggestions, itemSorter, itemFilter, suggestionsAmount, query);

    listSuggestionsEntry.markNeedsBuild();
  }

  List<T> getSuggestions(List<T> suggestions, Comparator<T> sorter,
      Filter<T> filter, int maxAmount, String query) {
    if (query == "") {
      return [];
    }

    suggestions.sort(sorter);
    suggestions = suggestions.where((item) => filter(item, query)).toList();
    if (suggestions.length > maxAmount) {
      suggestions = suggestions.sublist(0, maxAmount);
    }
    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return textField;
  }
}

class SimpleAutoCompleteTextField extends AutoCompleteTextField<String> {
  final StringCallback textChanged, textSubmitted;

  SimpleAutoCompleteTextField(
      {TextStyle style,
      InputDecoration decoration: const InputDecoration(),
      this.textChanged,
      this.textSubmitted,
      TextInputType keyboardType: TextInputType.text,
      @required GlobalKey<AutoCompleteTextFieldState<String>> key,
      @required List<String> suggestions,
      int suggestionsAmount: 5,
      bool submitOnSuggestionTap: true,
      bool clearOnSubmit: true,
      TextInputAction textInputAction: TextInputAction.done,
      TextCapitalization textCapitalization: TextCapitalization.sentences})
      : super(
            style: style,
            decoration: decoration,
            textChanged: textChanged,
            textSubmitted: textSubmitted,
            itemSubmitted: textSubmitted,
            keyboardType: keyboardType,
            key: key,
            suggestions: suggestions,
            itemBuilder: null,
            itemSorter: null,
            itemFilter: null,
            suggestionsAmount: suggestionsAmount,
            submitOnSuggestionTap: submitOnSuggestionTap,
            clearOnSubmit: clearOnSubmit,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization);

  @override
  State<StatefulWidget> createState() => new AutoCompleteTextFieldState<String>(
        initialValue,
        suggestions,
        textChanged,
        textSubmitted,
        itemSubmitted,
        (context, item) {
          return new Padding(
              padding: EdgeInsets.all(8.0), child: new Text(item));
        },
        (a, b) {
          return a.compareTo(b);
        },
        (item, query) {
          return item.toLowerCase().startsWith(query.toLowerCase());
        },
        suggestionsAmount,
        submitOnSuggestionTap,
        clearOnSubmit,
        scrollController,
        [],
        textCapitalization,
        decoration,
        style,
        keyboardType,
        textInputAction,
      );
}

class AutoCompleteFormField<T> extends StatefulWidget {
  List<T> suggestions;
  Filter<T> itemFilter;
  Comparator<T> itemSorter;
  StringCallback textChanged, textSubmitted, onFieldSubmitted, validator;
  InputEventCallback<T> itemSubmitted;
  AutoCompleteOverlayItemBuilder<T> itemBuilder;
  int suggestionsAmount;
  GlobalKey<AutoCompleteFormFieldState<T>> key;
  bool submitOnSuggestionTap, clearOnSubmit;
  List<TextInputFormatter> inputFormatters;

  InputDecoration decoration;
  TextStyle style;
  TextInputType keyboardType;
  TextInputAction textInputAction;
  TextCapitalization textCapitalization;
  String initialValue;
  TextEditingController controller;
  ScrollController scrollController;

  AutoCompleteFormField({
    this.itemSubmitted, //Callback on item selected, this is the item selected of type <T>
    @required
        this.key, //GlobalKey used to enable addSuggestion etc
    @required
        this.suggestions, //Suggestions that will be displayed
    @required
        this.itemBuilder, //Callback to build each item, return a Widget
    @required
        this.itemSorter, //Callback to sort items in the form (a of type <T>, b of type <T>)
    @required
        this.itemFilter, //Callback to filter item: return true or false depending on input text
    this.inputFormatters,
    this.style,
    this.decoration: const InputDecoration(),
    this.textChanged,
    @required //Callback on input text changed, this is a string
        this.textSubmitted, //Callback on input text submitted, this is also a string
    this.keyboardType: TextInputType.text,
    this.suggestionsAmount:
        5, //The amount of suggestions to show, larger values may result in them going off screen
    this.submitOnSuggestionTap:
        true, //Call textSubmitted on suggestion tap, itemSubmitted will be called no matter what
    this.clearOnSubmit: false, //Clear autoCompleteTextfield on submit
    this.textInputAction: TextInputAction.done,
    this.textCapitalization: TextCapitalization.sentences,
    this.initialValue,
    this.scrollController,
  }) : super(key: key);

  void clear() {
    key.currentState.clear();
  }

  void addSuggestion(T suggestion) {
    key.currentState.addSuggestion(suggestion);
  }

  void removeSuggestion(T suggestion) {
    key.currentState.removeSuggestion(suggestion);
  }

  void updateSuggestions(List<T> suggestions) {
    key.currentState.updateSuggestions(suggestions);
  }

  TextFormField get textField => key.currentState.textField;

  @override
  State<StatefulWidget> createState() => new AutoCompleteFormFieldState<T>(
        initialValue,
        suggestions,
        textChanged,
        textSubmitted,
        itemSubmitted,
        itemBuilder,
        itemSorter,
        itemFilter,
        suggestionsAmount,
        submitOnSuggestionTap,
        clearOnSubmit,
        scrollController,
        inputFormatters,
        textCapitalization,
        decoration,
        style,
        keyboardType,
        textInputAction,
        onFieldSubmitted,
        validator,
      );
}

class AutoCompleteFormFieldState<T> extends State<AutoCompleteFormField> {
  TextFormField textField;
  List<T> suggestions;
  StringCallback textChanged, textSubmitted, onFieldSubmitted, validator;
  InputEventCallback<T> itemSubmitted;
  AutoCompleteOverlayItemBuilder<T> itemBuilder;
  Comparator<T> itemSorter;
  OverlayEntry listSuggestionsEntry;
  List<T> filteredSuggestions;
  Filter<T> itemFilter;
  int suggestionsAmount;
  bool submitOnSuggestionTap, clearOnSubmit;
  final TextEditingController _controller = new TextEditingController();
  final FocusNode _focusNode = new FocusNode();
  ScrollController scrollController;
  String initialValue;
  RelativeRect position;

  String currentText = "";

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue;
    _controller.addListener(_onChanged);
    _focusNode.addListener(() {
      print("Listened to focus " + _focusNode.hasFocus.toString());
      if (!_focusNode.hasFocus) {
        print("REMOVE");
        filteredSuggestions = [];
//        listSuggestionsEntry.remove();
      }
    });
//    initialValue = widget.initialValue;
//    controller.addListener(_onChanged);
  }

  _onChanged() {
    print("Text CHANGED");
    currentText = _controller.text;
    updateOverlay(_controller.text);

    if (textChanged != null) {
      textChanged(_controller.text);
    }
  }

  AutoCompleteFormFieldState(
      this.initialValue,
      this.suggestions,
      this.textChanged,
      this.textSubmitted,
      this.itemSubmitted,
      this.itemBuilder,
      this.itemSorter,
      this.itemFilter,
      this.suggestionsAmount,
      this.submitOnSuggestionTap,
      this.clearOnSubmit,
      this.scrollController,
      List<TextInputFormatter> inputFormatters,
      TextCapitalization textCapitalization,
      InputDecoration decoration,
      TextStyle style,
      TextInputType keyboardType,
      TextInputAction textInputAction,
      this.onFieldSubmitted,
      this.validator) {
    textField = new TextFormField(
//      initialValue: initialValue,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      decoration: decoration,
      style: style,
      keyboardType: keyboardType,
      focusNode: _focusNode,
      controller: _controller,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      onSaved: (submittedText) {
        if (clearOnSubmit) {
          clear();
        }

        if (textSubmitted != null) {
          textSubmitted(submittedText);
        }
      },
    );

    // TODO make overlay scroll with textfield
  }

  void clear() {
    textField.controller.clear();
    updateOverlay("");
  }

  void addSuggestion(T suggestion) {
    suggestions.add(suggestion);
    updateOverlay(currentText);
  }

  void removeSuggestion(T suggestion) {
    suggestions.contains(suggestion)
        ? suggestions.remove(suggestion)
        : throw "List does not contain suggestion and therefore cannot be removed";
    updateOverlay(currentText);
  }

  void updateSuggestions(List<T> suggestions) {
    this.suggestions = suggestions;
  }

  void updateOverlay(String query) {
    if (listSuggestionsEntry == null) {
      final RenderBox textFieldRenderBox = context.findRenderObject();
      final RenderBox overlay = Overlay.of(context).context.findRenderObject();
      final width = textFieldRenderBox.size.width;
      position = new RelativeRect.fromRect(
        new Rect.fromPoints(
          textFieldRenderBox.localToGlobal(
              textFieldRenderBox.size.bottomLeft(Offset.zero),
              ancestor: overlay),
          textFieldRenderBox.localToGlobal(
              textFieldRenderBox.size.bottomRight(Offset.zero),
              ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      );

      listSuggestionsEntry = new OverlayEntry(builder: (context) {
        print(position.toString());
        return new Positioned(
            top: position.top,
            left: position.left,
            child: new Container(
                width: width,
                child: new Card(
                    child: new Column(
                  children: filteredSuggestions.map((suggestion) {
                    return new Row(children: [
                      new Expanded(
                          child: new InkWell(
                              child: itemBuilder(context, suggestion),
                              onTap: () {
                                setState(() {
                                  if (submitOnSuggestionTap) {
                                    String newText = suggestion.toString();
                                    textField.controller.text = newText;
                                    _focusNode.unfocus();
                                    itemSubmitted(suggestion);
                                    if (clearOnSubmit) {
                                      clear();
                                    }
                                  } else {
                                    String newText = suggestion.toString();
                                    textField.controller.text = newText;
                                    textChanged(newText);
                                  }
                                });
                              }))
                    ]);
                  }).toList(),
                ))));
      });
      Overlay.of(context).insert(listSuggestionsEntry);
    }

    filteredSuggestions = getSuggestions(
        suggestions, itemSorter, itemFilter, suggestionsAmount, query);

    listSuggestionsEntry.markNeedsBuild();
  }

  List<T> getSuggestions(List<T> suggestions, Comparator<T> sorter,
      Filter<T> filter, int maxAmount, String query) {
    if (query == "") {
      return [];
    }

    suggestions.sort(sorter);
    suggestions = suggestions.where((item) => filter(item, query)).toList();
    if (suggestions.length > maxAmount) {
      suggestions = suggestions.sublist(0, maxAmount);
    }
    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return textField;
  }
}
