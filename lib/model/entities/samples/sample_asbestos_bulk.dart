import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'sample_asbestos_bulk.g.dart';
/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.


/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

/// Every json_serializable class must have the serializer mixin.
/// It makes the generated toJson() method to be usable for the class.
/// The mixin's name follows the source class, in this case, User.
class SampleAsbestosBulk extends Object with _$SampleAsbestosBulkSerializerMixin {
//
//  var uuid = new Uuid();
  String uuid,
      asbestosItemUuid,
      description,
      material,
      jobNumber;
  int
      sampleNumber;
  String
      clientName,
      address,
      samplerUuid,    // uuid of user who sampled, 0 if Client
      siteNotes,
      sampleDateTime, // time that sample was logged first

      analysisResultUuid, // analysis to be reported
      analysisResult, // ch, am, cr, no, umf

      imagePath;

  double receivedWeight,
      dryWeight;

  int resultVersion,  // used if result has changed (e.g. if lab reassesses)
      hasSynced;      // make it an int to fit in with sqlite (Sqlite doesn't use booleans, 0 = false, 1 = true

  SampleAsbestosBulk({
    @required this.uuid,
    @required this.asbestosItemUuid,
    this.description,
    this.material,
    this.jobNumber,
    this.sampleNumber,
    this.clientName,
    this.address,
    this.samplerUuid,
    this.siteNotes,
    this.sampleDateTime,

    this.analysisResultUuid,
    this.analysisResult,
    this.resultVersion,

    this.imagePath,

    this.receivedWeight,
    this.dryWeight,

    this.hasSynced,
  });

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated _$UserFromJson constructor.
  /// The constructor is named after the source class, in this case User.
  factory SampleAsbestosBulk.fromJson(Map<String, dynamic> json) => _$SampleAsbestosBulkFromJson(json);
}