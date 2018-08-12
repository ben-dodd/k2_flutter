import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'job_object.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

/// Every json_serializable class must have the serializer mixin.
/// It makes the generated toJson() method to be usable for the class.
/// The mixin's name follows the source class, in this case, User.
class Job extends Object with _$JobSerializerMixin {
  static final db_job_number = "jobNumber";
  static final db_address = "address";
  static final db_description = "description";
  static final db_client_name = "clientName";
  static final db_state = "state";
  static final db_type = "type";
  static final db_last_modified = "lastModified";

  String
      jobNumber,
      address,
      description,
      clientName,
      state,
      type;
  var lastModified;

  Job({
    @required this.jobNumber,
    this.address,
    this.description,
    this.clientName,
    this.state,
    this.type,
    this.lastModified,
  });

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated _$UserFromJson constructor.
  /// The constructor is named after the source class, in this case User.
  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  // Get from Database
  Job.fromMap(Map<String, dynamic> map): this(
    jobNumber: map[db_job_number],
    address: map[db_address],
    description: map[db_description],
    clientName: map[db_client_name],
    state: map[db_state],
    type: map[db_type],
    lastModified: map[db_last_modified],
  );

  // Load to Database
  Map<String, dynamic> toMap() {
    return {
      db_job_number: jobNumber,
      db_address: address,
      db_description: description,
      db_client_name: clientName,
      db_state: state,
      db_type: type,
      db_last_modified: lastModified,
    };
  }
}