import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

/// This class holds basic header information for a job
/// It syncs with WFM to keep all address information etc. accurate

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'job_header.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

/// Every json_serializable class must have the serializer mixin.
/// It makes the generated toJson() method to be usable for the class.
/// The mixin's name follows the source class, in this case, User.
class JobHeader extends Object with _$JobHeaderSerializerMixin {
  String
      jobNumber,
      address,
      description,
      clientName,
      state,
      type,
      imagePath,
      lastModified,
      lastSynced;

  JobHeader({
    @required this.jobNumber,
    this.address,
    this.description,
    this.clientName,
    this.state,
    this.type,
    this.imagePath,
    this.lastModified,
    this.lastSynced,
  });

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated _$UserFromJson constructor.
  /// The constructor is named after the source class, in this case User.
  factory JobHeader.fromJson(Map<String, dynamic> json) => _$JobHeaderFromJson(json);

}