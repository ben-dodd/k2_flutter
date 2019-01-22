library autocomplete_textfield;

import 'dart:async';

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
  TextEditingController controller;

  AutoCompleteTextField(
      {@required
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
        this.textChanged, //Callback on input text changed, this is a string
        this.textSubmitted, //Callback on input text submitted, this is also a string
        this.keyboardType: TextInputType.text,
        this.suggestionsAmount:
        5, //The amount of suggestions to show, larger values may result in them going off screen
        this.submitOnSuggestionTap:
        true, //Call textSubmitted on suggestion tap, itemSubmitted will be called no matter what
        this.clearOnSubmit: true, //Clear autoCompleteTextfield on submit
        this.textInputAction: TextInputAction.done,
        this.textCapitalization: TextCapitalization.sentences,
        this.controller,
      })
      : super(key: key);

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

  String currentText = "";

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
  }

  AutoCompleteTextFieldState(
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
      controller: this.controller,
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
    updateOverlay(currentText);
  }

  void updateOverlay(String query) {
    if (listSuggestionsEntry == null) {
      final RenderBox textFieldRenderBox = context.findRenderObject();
      final RenderBox overlay = Overlay.of(context).context.findRenderObject();
      final width = textFieldRenderBox.size.width;
      final RelativeRect position = new RelativeRect.fromRect(
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
      suggestions, textChanged, textSubmitted, itemSubmitted,
          (context, item) {
        return new Padding(padding: EdgeInsets.all(8.0), child: new Text(item));
      }, (a, b) {
    return a.compareTo(b);
  }, (item, query) {
    return item.toLowerCase().startsWith(query.toLowerCase());
  }, suggestionsAmount, submitOnSuggestionTap, clearOnSubmit, [],
      textCapitalization, decoration, style, keyboardType, textInputAction);
}


typedef Widget SuggestionsBuilder(BuildContext context, List<Widget> items);
typedef String ItemToString<T>(T item);
typedef T ItemFromString<T>(String string);

/// Wraps a [TextFormField] and shows a list of suggestions below it.
///
/// As the user types, a list of suggestions is shown using [onSearch] and
/// [itemBuilder]. The default suggestions container has a fills the available
/// height but can be overridden by using [suggestionsHeight] or by using a
/// custom [suggestionsBuilder].
///
/// It is recommended to provide an [itemFromString] argument so that a
/// suggestion can be selected if the user types in the value instead of tapping
/// on it.
///
/// It is also recommended that the Widget tree containing a
/// SimpleAutocompleteFormField include a [ListView] or other scrolling
/// container such as a [SingleChildScrollView]. This prevents the suggestions
/// from overflowing other UI elements like the keyboard.
class SimpleAutocompleteFormField<T> extends FormField<T> {
  final Key key;

  /// Minimum search length that shows suggestions.
  final int minSearchLength;

  /// Maximum number of suggestions shown.
  final int maxSuggestions;

  /// Container for the list of suggestions. Defaults to a scrollable `Column`
  /// that fills the available space.
  final SuggestionsBuilder suggestionsBuilder;

  /// The height of the suggestions container. Has no effect if a custom
  ///  [suggestionsBuilder] is specified.
  final double suggestionsHeight;

  /// Represents an autocomplete suggestion.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// How the text field is filled in when an item is selected. If omitted, the
  /// item's `toString()` method is used.
  final ItemToString<T> itemToString;

  /// Called before `onChanged` when the input loses focus and a suggestion was
  /// not selected, for example if the user typed in an entire suggestion value
  /// without tapping on it. The default implementation simply returns `null`.
  final ItemFromString<T> itemFromString;

  /// Called to fill the autocomplete list's data.
  final Future<List<T>> Function(String search) onSearch;

  /// Called when an item is tapped or the field loses focus.
  final ValueChanged<T> onChanged;

  /// If not null, the TextField [decoration]'s suffixIcon will be
  /// overridden to reset the input using the icon defined here.
  final IconData resetIcon;

  // TextFormField properties
  final FormFieldValidator<T> validator;
  final FormFieldSetter<T> onSaved;
  final ValueChanged<T> onFieldSubmitted;
  final TextEditingController controller;
  final FocusNode focusNode;
  final InputDecoration decoration;
  final TextInputType keyboardType;
  final TextStyle style;
  final TextAlign textAlign;
  final T initialValue;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final bool maxLengthEnforced;
  final int maxLines;
  final int maxLength;
  final List<TextInputFormatter> inputFormatters;
  final bool enabled;

  SimpleAutocompleteFormField(
      {this.key,
        this.minSearchLength: 0,
        this.maxSuggestions: 3,
        @required this.itemBuilder,
        @required this.onSearch,
        SuggestionsBuilder suggestionsBuilder,
        this.suggestionsHeight,
        this.itemToString,
        this.itemFromString,
        this.onChanged,
        this.resetIcon: Icons.close,
        bool autovalidate: false,
        this.validator,
        this.onFieldSubmitted,
        this.onSaved,

        // TextFormField properties
        TextEditingController controller,
        FocusNode focusNode,
        this.initialValue,
        this.decoration: const InputDecoration(),
        this.keyboardType: TextInputType.text,
        this.style,
        this.textAlign: TextAlign.start,
        this.autofocus: false,
        this.obscureText: false,
        this.autocorrect: true,
        this.maxLengthEnforced: true,
        this.enabled,
        this.maxLines: 1,
        this.maxLength,
        this.inputFormatters})
      : controller = controller ??
      TextEditingController(
          text: _toString<T>(initialValue, itemToString)),
        focusNode = focusNode ?? FocusNode(),
        suggestionsBuilder =
            suggestionsBuilder ?? _defaultSuggestionsBuilder(suggestionsHeight),
        super(
          key: key,
          autovalidate: autovalidate,
          validator: validator,
          onSaved: onSaved,
          builder: (FormFieldState<T> field) {
            // final _SimpleAutocompleteTextFieldState<T> state = field;
          });

  @override
  _SimpleAutocompleteFormFieldState<T> createState() =>
      _SimpleAutocompleteFormFieldState<T>(this);
}

class _SimpleAutocompleteFormFieldState<T> extends FormFieldState<T> {
  final SimpleAutocompleteFormField<T> parent;
  List<T> suggestions;
  bool showSuggestions = false;
  bool showResetIcon = false;
  T tappedSuggestion;

  _SimpleAutocompleteFormFieldState(this.parent);

  @override
  void initState() {
    super.initState();
    parent.focusNode.addListener(inputChanged);
    parent.controller.addListener(inputChanged);
  }

  @override
  void dispose() {
    parent.controller.removeListener(inputChanged);
    parent.focusNode.removeListener(inputChanged);
    super.dispose();
  }

  void inputChanged() {
    if (parent.focusNode.hasFocus) {
      setState(() {
        showSuggestions =
            parent.controller.text.trim().length >= parent.minSearchLength;
        if (parent.resetIcon != null &&
            parent.controller.text.trim().isEmpty == showResetIcon) {
          showResetIcon = !showResetIcon;
        }
      });
    } else {
      setState(() => showSuggestions = false);
      setValue(_value);
    }
  }

  T get _value => _toString<T>(tappedSuggestion, parent.itemToString) ==
      parent.controller.text
      ? tappedSuggestion
      : _toObject<T>(parent.controller.text, parent.itemFromString);

  @override
  void setValue(T value) {
    super.setValue(value);
    if (parent.onChanged != null) parent.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextFormField(
        controller: parent.controller,
        focusNode: parent.focusNode,
        decoration: parent.resetIcon == null
            ? parent.decoration
            : parent.decoration.copyWith(
          suffixIcon: showResetIcon
              ? IconButton(
            icon: Icon(parent.resetIcon),
            onPressed: () {
              parent.controller.clear();
              // parent.focusNode.unfocus();
            },
          )
              : Container(width: 0.0, height: 0.0),
        ),
        keyboardType: parent.keyboardType,
        style: parent.style,
        textAlign: parent.textAlign,
        autofocus: parent.autofocus,
        obscureText: parent.obscureText,
        autocorrect: parent.autocorrect,
        maxLengthEnforced: parent.maxLengthEnforced,
        maxLines: parent.maxLines,
        maxLength: parent.maxLength,
        inputFormatters: parent.inputFormatters,
        enabled: parent.enabled,
        onFieldSubmitted: (value) {
          if (parent.onFieldSubmitted != null) {
            return parent.onFieldSubmitted(_value);
          }
        },
        validator: (value) {
          if (parent.validator != null) {
            return parent.validator(_value);
          }
        },
        onSaved: (value) {
          if (parent.onSaved != null) {
            return parent.onSaved(_value);
          }
        },
      ),
      showSuggestions
          ? FutureBuilder<List<Widget>>(
        future: _buildSuggestions(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return parent.suggestionsBuilder(context, snapshot.data);
          } else if (snapshot.hasError) {
            return new Text('${snapshot.error}');
          }
          return Center(child: CircularProgressIndicator());
        },
      )
          : Container(height: 0.0, width: 0.0),
    ]);
  }

  Future<List<Widget>> _buildSuggestions() async {
    final list = List<Widget>();
    final suggestions = await parent.onSearch(parent.controller.text);
    suggestions
        ?.take(parent.maxSuggestions)
        ?.forEach((suggestion) => list.add(InkWell(
      child: parent.itemBuilder(context, suggestion),
      onTap: () {
        tappedSuggestion = suggestion;
        parent.controller.text =
            _toString<T>(suggestion, parent.itemToString);
        parent.focusNode.unfocus();
      },
    )));
    return list;
  }
}

String _toString<T>(T value, ItemToString<T> fn) =>
    (fn == null ? value?.toString() : fn(value)) ?? '';

T _toObject<T>(String s, ItemFromString fn) => fn == null ? null : fn(s);

SuggestionsBuilder _defaultSuggestionsBuilder(double height) =>
    // ((context, items) => ListView(children: items));
((context, items) => Container(
    height: height,
    child: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: items))));
