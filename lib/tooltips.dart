import 'package:meta/meta.dart';

class ToolTip {
  final String title;
  final String tip;
  final String subtip;

  ToolTip ({
    @required
    this.title,
    @required
    this.tip,
    @required
    this.subtip
  });
}

class Tip {
  // SAMPLE/PRESUME
  static final sample = new ToolTip(
    title: 'Sample',
    tip: 'The material in this room will be sampled for analysis.',
    subtip: 'For demolition and refurbishment surveys, ALL materials should be sampled if possible. If the survey is a mix of management/refurbishment, the materials that are likely to be disturbed by planned refurbishment should be sampled. For management surveys, damaged or high risk materials should be sampled, while the sampling of undamaged materials should be discussed with the client prior to sampling.',
  );
  static final presume = new ToolTip(
    title: 'Presume',
    tip: 'The material must be presumed to contain asbestos.',
    subtip: 'The "default" situation. Item cannot be presumed to be asbestos-free, or area or item was inaccessible. Examples: Jointing compound, HardieGlaze, Non-fibrous vinyl, Bakelite.',
  );
  static final stronglypresume = new ToolTip(
    title: 'Strongly Presume',
    tip: 'The material is likely to contain asbestos but will not be sampled.',
    subtip: 'Material is visually consistent with known ACM materials. Material has the appearance of asbestos. Asbestos was commonly used in material at time of installation. Examples: cement roofing, walls, drainpipes, water tanks, etc. Paper-backed vinyl, Bituminous fuse boards. Textured plaster ceilings (pre-1990). Millboard.'
  );
  // MATERIAL RISK

  // ACCESSIBILITY
  static final accessibility_easy = new ToolTip(
    title: 'Accessibility: Easy',
    tip: 'May be disturbed during normal occupancy. Does not require any equipment to access.',
    subtip: 'Ground floor wall cladding, floor coverings, etc.',
  );

  static final accessibility_medium = new ToolTip(
    title: 'Accessibility: Medium',
    tip: 'Requires equipment (e.g. a ladder) to access. Within fuse boxes.',
    subtip: 'Ground floor soffits, fuse box lining, interior ceilings, etc.',
  );

  static final accessibility_difficult = new ToolTip(
    title: 'Accessibility: Difficult',
    tip: 'Requires specialist equipment, dismantling of machinery or modification of the building to access.',
    subtip: 'Above false ceilings, within walls, upper floor soffits and gables, cylinder insulation, etc.',
  );

  // PRODUCT
  static final material_product_1 = new ToolTip(
    title: 'Product Type: 1',
    tip: 'Non-friable or low friability. Asbestos-reinforced composites.',
    subtip: 'Cement, vinyl tiles, plaster, plastics, resins, mastics, roofing felts etc.',
  );

  static final material_product_2 = new ToolTip(
    title: 'Product Type: 2',
    tip: 'Medium friability.',
    subtip: 'AIB, millboards, other low-density insulation boards, asbestos rope and textiles, paper-backed vinyl, gaskets, etc.',
  );

  static final material_product_3 = new ToolTip(
    title: 'Product Type: 3',
    tip: 'Highly friable.',
    subtip: 'Asbestos-contaminated dust or soil, loose asbestos, thermal insulation (e.g. boiler and pipe lagging), sprayed asbestos, etc.',
  );

  // DAMAGE
  static final material_damage_0 = new ToolTip(
    title: 'Damage: 0',
    tip: 'Good condition.',
    subtip: 'No visible damage.',
  );

  static final material_damage_1 = new ToolTip(
    title: 'Damage: 1',
    tip: 'Low damage.',
    subtip: 'A few scratches or surface marks, broken edges on boards, tiles, etc.',
  );

  static final material_damage_2 = new ToolTip(
    title: 'Damage: 2',
    tip: 'Medium damage.',
    subtip: 'Significant breakage of materials or several small areas where material has been damaged revealing loose asbestos fibres.',
  );

  static final material_damage_3 = new ToolTip(
    title: 'Damage: 3',
    tip: 'High damage',
    subtip: 'High damage or delamination of materials, sprays and thermal insulation. Visible asbestos debris.',
  );

  // SURFACE
  static final material_surface_0 = new ToolTip(
    title: 'Surface Treatment: 0',
    tip: 'Composite materials.',
    subtip: 'Reinforced plastics, resins, vinyl tiles, Bakelite, etc.',
  );

  static final material_surface_1 = new ToolTip(
    title: 'Surface Treatment: 1',
    tip: 'Non-friable material, sealed moderately friable product or enclosed highly friable product.',
    subtip: 'Enclosed sprays and lagging, AIB with exposed face painted, all cement and plaster materials.',
  );

  static final material_surface_2 = new ToolTip(
    title: 'Surface Treatment: 2',
    tip: 'Encapsulated highly friable product or unsealed moderately friable product.',
    subtip: 'Unsealed AIB or encapsulated lagging and sprays.',
  );

  static final material_surface_3 = new ToolTip(
    title: 'Surface Treatment: 3',
    tip: 'Unsealed highly friable material',
    subtip: 'Unsealed lagging and sprays.',
  );

  // ASBESTOS
  static final material_asbestos_1 = new ToolTip(
    title: 'Asbestos Type: 1',
    tip: 'Only chrysotile asbestos detected',
    subtip: '',
  );

  static final material_asbestos_2 = new ToolTip(
    title: 'Asbestos Type: 2',
    tip: 'Amphibole asbestos detected, excluding crocidolite',
    subtip: '',
  );

  static final material_asbestos_3 = new ToolTip(
    title: 'Asbestos Type: 3',
    tip: 'Asbestos type unknown or crocidolite asbestos detected',
    subtip: '',
  );

  //
  // PRIORITY RISK
  //

  //ACTIVITY
  static final priority_activity_main_0 = new ToolTip(
    title: 'Main Activity: 0',
    tip: 'Rare disturbance activity',
    subtip: '(e.g. little use store room)',
  );

  static final priority_activity_main_1 = new ToolTip(
    title: 'Main Activity: 1',
    tip: 'Low disturbance activity',
    subtip: '(e.g. general office activity)',
  );

  static final priority_activity_main_2 = new ToolTip(
    title: 'Main Activity: 2',
    tip: 'Periodic disturbance',
    subtip: '(e.g. industrial or vehicular activity which may contact ACMs)',
  );

  static final priority_activity_main_3 = new ToolTip(
    title: 'Main Activity: 3',
    tip: 'High levels of disturbance',
    subtip: '(e.g. fire door with AIB sheet in constant use)',
  );

  static final priority_activity_secondary_0 = new ToolTip(
    title: 'Secondary Activity: 0',
    tip: 'Rare disturbance activity',
    subtip: '(e.g. little use store room)',
  );

  static final priority_activity_secondary_1 = new ToolTip(
    title: 'Secondary Activity: 1',
    tip: 'Low disturbance activity',
    subtip: '(e.g. general office activity)',
  );

  static final priority_activity_secondary_2 = new ToolTip(
    title: 'Secondary Activity: 2',
    tip: 'Periodic disturbance',
    subtip: '(e.g. industrial or vehicular activity which may contact ACMs)',
  );

  static final priority_activity_secondary_3 = new ToolTip(
    title: 'Secondary Activity: 3',
    tip: 'High levels of disturbance',
    subtip: '(e.g. fire door with AIB sheet in constant use)',
  );

  static final priority_disturbance_location_0 = new ToolTip(
    title: 'Location: 0',
    tip: 'Outdoors',
    subtip: '',
  );

  static final priority_disturbance_location_1 = new ToolTip(
    title: 'Location: 1',
    tip: 'Large rooms or well-ventilated areas',
    subtip: '',
  );

  static final priority_disturbance_location_2 = new ToolTip(
    title: 'Location: 2',
    tip: 'Rooms up to 100m2',
    subtip: '',
  );

  static final priority_disturbance_location_3 = new ToolTip(
    title: 'Location: 3',
    tip: 'Confined spaces',
    subtip: '',
  );

  static final priority_disturbance_accessibility_0 = new ToolTip(
    title: 'Accessibility: 0',
    tip: 'Usually inaccessible or unlikely to be disturbed',
    subtip: '',
  );

  static final priority_disturbance_accessibility_1 = new ToolTip(
    title: 'Accessibility: 1',
    tip: 'Occassionally likely to be disturbed',
    subtip: '',
  );

  static final priority_disturbance_accessibility_2 = new ToolTip(
    title: 'Accessibility: 2',
    tip: 'Easily disturbed',
    subtip: '',
  );

  static final priority_disturbance_accessibility_3 = new ToolTip(
    title: 'Accessibility: 3',
    tip: 'Routinely disturbed',
    subtip: '',
  );

  static final priority_disturbance_extent_0 = new ToolTip(
    title: 'Extent: 0',
    tip: 'Small amounts or items',
    subtip: '(e.g. strings, gaskets)',
  );

  static final priority_disturbance_extent_1 = new ToolTip(
    title: 'Extent: 1',
    tip: '<10m2 or <10m pipe run',
    subtip: '',
  );

  static final priority_disturbance_extent_2 = new ToolTip(
    title: 'Extent: 2',
    tip: '10-50m2 or 10-50m pipe run',
    subtip: '',
  );

  static final priority_disturbance_extent_3 = new ToolTip(
    title: 'Extent: 3',
    tip: '>50m2 or >50m pipe run',
    subtip: '',
  );

  static final priority_exposure_occupants_0 = new ToolTip(
    title: 'Occupants: 0',
    tip: 'None',
    subtip: '',
  );

  static final priority_exposure_occupants_1 = new ToolTip(
    title: 'Occupants: 1',
    tip: '1 to 3',
    subtip: '',
  );

  static final priority_exposure_occupants_2 = new ToolTip(
    title: 'Occupants: 2',
    tip: '4 to 10',
    subtip: '',
  );

  static final priority_exposure_occupants_3 = new ToolTip(
    title: 'Occupants: 3',
    tip: 'More than 10',
    subtip: '',
  );

  static final priority_exposure_usefreq_0 = new ToolTip(
    title: 'Use Frequency: 0',
    tip: 'Infrequent',
    subtip: '',
  );

  static final priority_exposure_usefreq_1 = new ToolTip(
    title: 'Use Frequency: 1',
    tip: 'Monthly',
    subtip: '',
  );

  static final priority_exposure_usefreq_2 = new ToolTip(
    title: 'Use Frequency: 2',
    tip: 'Weekly',
    subtip: '',
  );

  static final priority_exposure_usefreq_3 = new ToolTip(
    title: 'Use Frequency: 3',
    tip: 'Daily',
    subtip: '',
  );

  static final priority_exposure_avgtime_0 = new ToolTip(
    title: 'Average Time: 0',
    tip: '<1 hour per day',
    subtip: '',
  );

  static final priority_exposure_avgtime_1 = new ToolTip(
    title: 'Average Time: 1',
    tip: '1-3 hours per day',
    subtip: '',
  );

  static final priority_exposure_avgtime_2 = new ToolTip(
    title: 'Average Time: 2',
    tip: '3-6 hours per day',
    subtip: '',
  );

  static final priority_exposure_avgtime_3 = new ToolTip(
    title: 'Average Time: 3',
    tip: '>6 hours per day',
    subtip: '',
  );

  static final priority_maint_type_0 = new ToolTip(
    title: 'Maintenance Type: 0',
    tip: 'Minor disturbance',
    subtip: '(e.g. possibility of contact when gaining access)',
  );

  static final priority_maint_type_1 = new ToolTip(
    title: 'Maintenance Type: 1',
    tip: 'Low disturbance',
    subtip: '(e.g. changing light bulbs in AIB ceiling)',
  );

  static final priority_maint_type_2 = new ToolTip(
    title: 'Maintenance Type: 2',
    tip: 'Medium disturbance',
    subtip: '(e.g. lifting one or two AIB ceiling tiles to access a valve)',
  );

  static final priority_maint_type_3 = new ToolTip(
    title: 'Maintenance Type: 3',
    tip: 'High levels of disturbance',
    subtip: '(e.g. removing a number of AIB ceiling tiles to replace a valve or for recabling)',
  );

  static final priority_maint_freq_0 = new ToolTip(
    title: 'Maintenance Frequency: 0',
    tip: 'ACM unlikely to be disturbed for maintenance',
    subtip: '',
  );

  static final priority_maint_freq_1 = new ToolTip(
    title: 'Maintenance Frequency: 1',
    tip: 'Less than once per year',
    subtip: '',
  );

  static final priority_maint_freq_2 = new ToolTip(
    title: 'Maintenance Frequency: 2',
    tip: 'Greater than once per year',
    subtip: '',
  );

  static final priority_maint_freq_3 = new ToolTip(
    title: 'Maintenance Frequency: 3',
    tip: 'Greater than once per month',
    subtip: '',
  );

}