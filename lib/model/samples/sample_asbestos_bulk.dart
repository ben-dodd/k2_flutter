class SampleAsbestosBulk {
//
//  var uuid = new Uuid();
  String
      asbestosItemUuid,
      siteVisitUuid,
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
    this.asbestosItemUuid,
    this.siteVisitUuid,
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

  SampleAsbestosBulk fromMap(Map<String, dynamic> map){
    SampleAsbestosBulk sampleAsbestosBulk = new SampleAsbestosBulk(
      asbestosItemUuid: map['asbestosItemUuid'],
      siteVisitUuid: map['siteVisitUuid'],
      description: map['description'],
      material: map['material'],
      jobNumber: map['jobNumber'],
      sampleNumber: map['sampleNumber'],
      clientName: map['clientName'],
      address: map['address'],
      samplerUuid: map['samplerUuid'],
      siteNotes: map['siteNotes'],
      sampleDateTime: map['sampleDateTime'],

      analysisResultUuid: map['analysisResultUuid'],
      analysisResult: map['analysisResult'],
      resultVersion: map['resultVersion'],

      imagePath: map['imagePath'],

      receivedWeight: map['receivedWeight'],
      dryWeight: map['dryWeight'],
      hasSynced: map['hasSynced'],

    );
    return sampleAsbestosBulk;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map();
    map['asbestosItemUuid'] = asbestosItemUuid;
    map['siteVisitUuid'] = siteVisitUuid;
    map['description'] = description;
    map['material'] = material;
    map['jobNumber'] = jobNumber;
    map['sampleNumber'] = sampleNumber;
    map['clientName'] = clientName;
    map['address'] = address;
    map['samplerUuid'] = samplerUuid;
    map['siteNotes'] = siteNotes;
    map['sampleDateTime'] = sampleDateTime;

    map['analysisResultUuid'] = analysisResultUuid;
    map['analysisResult'] = analysisResult;
    map['resultVersion'] = resultVersion;

    map['imagePath'] = imagePath;

    map['receivedWeight'] = receivedWeight;
    map['dryWeight'] = dryWeight;

    map['hasSynced'] = hasSynced;

    return map;
  }

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated _$UserFromJson constructor.
  /// The constructor is named after the source class, in this case User.
//  factory SampleAsbestosBulk.fromJson(Map<String, dynamic> json) => _$SampleAsbestosBulkFromJson(json);
}