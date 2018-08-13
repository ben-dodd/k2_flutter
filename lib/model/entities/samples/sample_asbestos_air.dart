import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'sample_asbestos_air.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

/// Every json_serializable class must have the serializer mixin.
/// It makes the generated toJson() method to be usable for the class.
/// The mixin's name follows the source class, in this case, User.
class SampleAsbestosAir extends Object with _$SampleAsbestosAirSerializerMixin {
//
//  var uuid = new Uuid();
  String uuid,
      description,
      taskUuid,
      sampleNumber,
      jobNumber,

      setupBy, // user uuid
      pickupBy,// user uuid

      pumpStartTime,
      pumpEndTime,
      pumpRunTime,
      pumpPickupTime,

      siteNotes;

  double startFlowRate,
      endFlowRate,

      reportFibreCount;

  int resultVersion,
      hasSynced; // make it an int to fit in with sqlite (Sqlite doesn't use booleans, 0 = false, 1 = true

  SampleAsbestosAir({
    @required this.uuid,
    this.description,
    @required this.taskUuid,
    this.sampleNumber,
    this.jobNumber,
    this.setupBy,
    this.pickupBy,

    this.pumpStartTime,
    this.pumpEndTime,
    this.pumpRunTime,
    this.pumpPickupTime,

    this.siteNotes,

    this.startFlowRate,
    this.endFlowRate,

    this.reportFibreCount,

    this.resultVersion,
    this.hasSynced,
  });

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated _$UserFromJson constructor.
  /// The constructor is named after the source class, in this case User.
  factory SampleAsbestosAir.fromJson(Map<String, dynamic> json) => _$SampleAsbestosAirFromJson(json);
}