import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

/// This class holds basic header information for a job
/// It syncs with WFM to keep all address information etc. accurate

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'user.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

/// Every json_serializable class must have the serializer mixin.
/// It makes the generated toJson() method to be usable for the class.
/// The mixin's name follows the source class, in this case, User.
class User extends Object with _$UserSerializerMixin {
  String
  email,
  displayName,
  tertiaryQualification,
  asbestosAssessorNumber;
  DateTime maskExpiry;
  bool ip402;
  int wfmStaffId;

  User({
    @required this.email,
    this.displayName,
    this.tertiaryQualification,
    this.asbestosAssessorNumber,
    this.maskExpiry,
    this.ip402,
    this.wfmStaffId
  });

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated _$UserFromJson constructor.
  /// The constructor is named after the source class, in this case User.
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

}