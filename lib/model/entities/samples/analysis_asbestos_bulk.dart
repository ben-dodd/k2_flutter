import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'analysis_asbestos_bulk.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

/// Every json_serializable class must have the serializer mixin.
/// It makes the generated toJson() method to be usable for the class.
/// The mixin's name follows the source class, in this case, User.
class AnalysisAsbestosBulk extends Object with _$AnalysisAsbestosBulkSerializerMixin {
//
//  var uuid = new Uuid();
  String uuid,
      sampleUuid,
      analysisDateTime,
      analystUuid,
      result,
      labNotes,
      analysisState; // final, average, void?

  int hasSynced; // make it an int to fit in with sqlite (Sqlite doesn't use booleans, 0 = false, 1 = true

  AnalysisAsbestosBulk({
    @required this.uuid,
    @required this.sampleUuid,
    this.analysisDateTime,
    this.analystUuid,
    this.result,
    this.labNotes,
    this.analysisState,

    this.hasSynced,
  });

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated _$UserFromJson constructor.
  /// The constructor is named after the source class, in this case User.
  factory AnalysisAsbestosBulk.fromJson(Map<String, dynamic> json) => _$AnalysisAsbestosBulkFromJson(json);
}