import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'acm.g.dart';
/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.


/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

/// Every json_serializable class must have the serializer mixin.
/// It makes the generated toJson() method to be usable for the class.
/// The mixin's name follows the source class, in this case, User.
class ACM extends Object with _$ACMSerializerMixin {
//
//  var uuid = new Uuid();
  String uuid,
      displayName, // can be auto generated from item and material or altered to something less verbose
      item,
      material,
      roomUuid,
      taskUuid,
      sampleUuid, // 'presume as' if presumed
      privateNote, // note about item, not to be included in report
      reportNote, // comment or note to put in report
      reasonForNotSampling; // note if a presumed item

  int
      // Report settings
      includeInReport,
      genericInReport,

      // Presumed
      idLevel, // 0 presumed, 1 strongly presumed, 2 sampled
      canBeIdentified,
      isNoAccess;

  String
      presumeAsbestosType,
      // Accessibility
      accessibility,

      // Extent
      extentDesc,
      extentAmount,

      // Damage/Surface
      damageDesc,
      surfaceDesc;
  int mrProductScore,
      mrDamageScore,
      mrSurfaceScore,

      // priority risk assessment
      // activity
      prActivityMain,
      prActivitySecond,

      // disturbance
      prDisturbanceLocation,
      prDisturbanceAccessibility,
      prDisturbanceExtent,

      // exposure
      prExposureOccupants,
      prExposureUseFreq,
      prExposureAvgTime,

      // maintenance
      prMaintenanceType,
      prMaintenanceFreq,

      hasSynced; // make it an int to fit in with sqlite (Sqlite doesn't use booleans, 0 = false, 1 = true

  ACM({
    @required this.uuid,
    this.displayName, // can be auto generated from item and material or altered to something less verbose
    this.item,
    this.material,
    this.roomUuid,
    this.taskUuid,
    this.sampleUuid, // 'presume as' if presumed
    this.privateNote, // note about item, not to be included in report
    this.reportNote, // comment or note to put in report
    this.reasonForNotSampling, // note if a presumed item

    // Report settings
    this.includeInReport,
    this.genericInReport,

    // Presumed
    this.idLevel, // 0 presumed, 1 strongly presumed, 2 sampled
    this.canBeIdentified,
    this.isNoAccess,
    this.presumeAsbestosType,

    // Accessibility
    this.accessibility,

    // Extent
    this.extentDesc,
    this.extentAmount,

    // Damage/Surface
    this.damageDesc,
    this.surfaceDesc,

    this.mrProductScore,
    this.mrDamageScore,
    this.mrSurfaceScore,

    // priority risk assessment
    // activity
    this.prActivityMain,
    this.prActivitySecond,

    // disturbance
    this.prDisturbanceLocation,
    this.prDisturbanceAccessibility,
    this.prDisturbanceExtent,

    // exposure
    this.prExposureOccupants,
    this.prExposureUseFreq,
    this.prExposureAvgTime,

    // maintenance
    this.prMaintenanceType,
    this.prMaintenanceFreq,
    this.hasSynced,
  });

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated _$UserFromJson constructor.
  /// The constructor is named after the source class, in this case User.
  factory ACM.fromJson(Map<String, dynamic> json) => _$ACMFromJson(json);
}