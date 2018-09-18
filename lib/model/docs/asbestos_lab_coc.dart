import 'package:k2e/model/docs/asbestos_lab_report_row.dart';
import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

/// This class holds basic header information for a job
/// It syncs with WFM to keep all address information etc. accurate

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'asbestos_lab_coc.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

/// Every json_serializable class must have the serializer mixin.
/// It makes the generated toJson() method to be usable for the class.
/// The mixin's name follows the source class, in this case, User.
class AsbestosLabCoc extends Object with _$AsbestosLabCocSerializerMixin {
  String
  jobnumber,
      client,
      orderNumber,
      address,
      date,
      version;
  List<String> personnel,
      assessors;
  List<AsbestosLabReportRow> samples;

  AsbestosLabCoc({
    this.jobnumber,
    this.client,
    this.orderNumber,
    this.address,
    this.date,
    this.version,
    this.personnel,
    this.assessors,
    this.samples
  });

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated _$UserFromJson constructor.
  /// The constructor is named after the source class, in this case User.
  factory AsbestosLabCoc.fromJson(Map<String, dynamic> json) => _$AsbestosLabCocFromJson(json);

}